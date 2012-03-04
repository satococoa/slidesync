class Room < ActiveRecord::Base
  belongs_to :user
  has_many :guests, class_name: 'User'
end
