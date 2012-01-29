class User < ActiveRecord::Base
  def self.find_or_create_by_auth_hash(auth)
    user = User.find_by_provider_and_uid(auth['provider'], auth['uid'])
    if user.nil?
      user = User.create do |u|
        u.uid = auth['uid']
        u.provider = auth['provider']
        u.name = auth['info']['name']
        u.nickname = auth['info']['nickname']
        u.icon_url = auth['info']['image']
      end
    end
    user
  end
end
