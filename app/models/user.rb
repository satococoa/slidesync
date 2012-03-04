class User < ActiveRecord::Base
  has_many :rooms
  
  def self.find_or_create_by_auth_hash(auth)
    user = User.find_or_create_by_provider_and_uid(auth['provider'], auth['uid'])
    user.update_attributes(
      name: auth['info']['name'],
      nickname: auth['info']['nickname'],
      icon_url: auth['extra']['raw_info']['avatar_url']
    )
    user
  end
end
