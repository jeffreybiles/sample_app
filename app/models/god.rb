class God < ActiveRecord::Base
  has_many :favors, foreign_key: 'god_id'
  has_many :users, through: :favors

  def worshipped_by?(user)
    favors.find_by_user_id(user)
  end
end
