require 'slideshare/slideshare'

Slideshare.configure do |c|
  c.key = Settings.slideshare.key
  c.secret = Settings.slideshare.secret
end
