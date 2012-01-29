if Rails.env.production?
  ENV['twitter_key'] = 'j4DeS7KiOa7AK8LGlP36mg'
  ENV['twitter_secret'] = 'I4ISDBDkkWtM7nIkbsuIWeE3kZIisdA7blOrXgnc'
else
  ENV['twitter_key'] = 'A6cjOKvKul4jxjwlCTxGw'
  ENV['twitter_secret'] = 'IKHPB1uplQyyMsNYuWTHT2TTbekGR9lLoiili35vt9Y'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, ENV['twitter_key'], ENV['twitter_secret']
end
