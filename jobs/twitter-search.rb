require 'twitter'
 
Twitter.configure do |config|
  config.consumer_key = 'gZEOiOV33GBAmstyKTXg'
  config.consumer_secret = 'PY7KhSvCESmE3UsS0ONuDtTAKPso4VBw3TPawW1HrB0'
  config.oauth_token = '55024627-ufsqCU51FfzWTYrfqjrnniwKyDC4Df0oX2liu7CA9'
  config.oauth_token_secret = 'B2XHNZjYAxbpIIxs9ONF7Y1CbbCjXLUVom67hLxfjO34t'
end
 
search_term = URI::encode('@svc_dosomuch')
 
SCHEDULER.every '10m', :first_in => 0 do |job|
  tweets = Twitter.search("#{search_term}").results
  if tweets
    tweets.map! do |tweet|
      { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
    end
    send_event('twitter_mentions', comments: tweets)
  end
end