require 'digest'
class User < ActiveRecord::Base

	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation


  #Account settings
  has_many :microposts, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id",
                          :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                  :class_name => "Relationship",
                                  :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower


  #Player statistics
  has_many :favors, dependent: :destroy, foreign_key: 'user_id'
  has_many :gods, through: :favors



  #Validations
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :name, :presence => true,
										:length => { :maximum => 50 }
	validates :email, :presence => true,
										:format => { :with => email_regex },
										:uniqueness => { :case_sensitive => false }
	validates :password, :presence => true,
										:confirmation => true,
										:length => { :within => 6..40 }

	before_save :encrypt_password


  #methods
	def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end

	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
    (user && user.has_password?(submitted_password)) ? user : nil
	end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  #player data

  def worship!(god)
    favors.create!(god_id: god.id)
  end

  def add_experience(amount, god)
    @favor = self.favors.find_by_god_id(god)
    if @favor.experience?
      @favor.experience -= amount
      self.level_up if @favor.experience <= 0
    else
      @favor.experience = 40
      @favor.level = 1
    end
    @favor.save!
  end


  private

		def encrypt_password
			self.salt = make_salt if new_record?
			self.encrypted_password = encrypt(password)
		end

		def encrypt(string)
			secure_hash("#{salt}--#{string}")
		end

		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")
		end

		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
    end

    def level_up
      @favor.level += 1
      @favor.experience= experience_required - @favor.experience
    end

    def experience_required
      40 * (1.2 ** (@favor.level - 1))
    end

    def experience_gained(challenge_level)
      10 * (1.15 ** (challenge_level - 1)) / (1.1 ** (@favor.level - challenge_level))
    end
end
