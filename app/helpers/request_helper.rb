module RequestHelper
  def self.request(oauth_token, oauth_token_secret, url, type='get', params=nil)

    access_token = OauthHelper.prepare_access_token(oauth_token, oauth_token_secret)
    if url.include? "media/upload.json?command=STATUS"
      # p base_url.gsub('api', 'upload')
      # p url
      access_token_response = access_token.request(type.to_sym, base_url.gsub('api', 'upload') + url)
    else
      access_token_response = access_token.request(type.to_sym, base_url + url)
    end
    # Make response a friendly error unless response is a 200
    unless access_token_response.code == '200'
      # p access_token_response.body
      ErrorHelper.format(access_token_response.body)
    else
      JSON.parse(access_token_response.body)
    end
  end

  def self.base_url
    "https://api.twitter.com/1.1"
  end
end
