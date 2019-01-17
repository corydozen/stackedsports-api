module Jwt::UserAuthenticator
  module_function

  def call(request_headers, use_cookie = false)
    @request_headers = request_headers
    @use_cookie = use_cookie

    begin
      payload, header = Jwt::TokenDecryptor.call(token)
      return User.find(payload['user_id'])
    rescue StandardError => e
      # log error here
      return nil
    end
  end

  def token
    # @request_headers['Authorization'].split(' ').last
    @use_cookie ? @request_headers : @request_headers['X-Auth-Token'].split(' ').last
  end
end
