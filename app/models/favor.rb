class Favor < ActiveRecord::Base
  attr_accessible :level, :experience

  belongs_to :user
  belongs_to :god

  validates :user_id, presence: true
  validates :god_id, presence: true



end
