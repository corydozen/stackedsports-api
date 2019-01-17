# # https://developer.twitter.com/en/docs/basics/response-codes.html
#
# # Example error: {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
module ErrorHelper
  def self.format(error)
    parsable_error = JSON.parse(error).as_json
    friendly_error = ['The following error(s) occurred: ']
    if parsable_error['errors'].present?
      # NOTE: If errors are present they should be in an array so we need to loop over them
      parsable_error['errors'].each do |individual_error|
        friendly_error << "#{individual_error['message']}, which #{is_permanent_failure?(individual_error['code']) ? 'was' : 'was not'} a permanent failure." if individual_error['message'].present?
      end
    end

    friendly_error.join("\n")
  end

  def self.html_format(error, style = 'br')
    # NOTE: can pass a style to get either new line breaks or an unordered list

    if style == 'br'
      format(error).to_s.gsub(/\n/, '<br/>').html_safe
    elsif style == 'ul'
      ul_errors = format(error).gsub('The following error(s) occurred: ', '')
      "The following error(s) occurred: <ul>#{ul_errors.gsub(/\n/, '<li>').gsub('permanent failure.', 'permanent failure.</li>')}</ul>"
    end
  end

  private

  def self.is_permanent_failure?(error_code)
    case error_code
    when 400
      true # Bad Request  The request was invalid or cannot be otherwise served. An accompanying error message will explain further. Requests without authentication are considered invalid and will yield this response.
    when  401
      true # Unauthorized  Missing or incorrect authentication credentials. This may also returned in other undefined circumstances.
    when  403
      true # Forbidden  The request is understood, but it has been refused or access is not allowed. An accompanying error message will explain why. This code is used when requests are being denied due to update limits . Other reasons for this status being returned are listed alongside the error codes in the table below.
    when  404
      true # Not Found  The URI requested is invalid or the resource requested, such as a user, does not exist.
    when  406
      true # Not Acceptable  Returned when an invalid format is specified in the request.
    when  410
      true # Gone  This resource is gone. Used to indicate that an API endpoint has been turned off.
    when  420
      false # Enhance Your Calm  Returned when an application is being rate limited for making too many requests.
    when  422
      true # Unprocessable Entity  Returned when the data is unable to be processed (for example, if an image uploaded to POST account / update_profile_banner is not valid, or the JSON body of a request is badly-formed).
    when  429
      false # Too Many Requests  Returned when a request cannot be served due to the application’s rate limit having been exhausted for the resource. See Rate Limiting.
    when  500
      true # Internal Server Error  Something is broken. This is usually a temporary error, for example in a high load situation or if an endpoint is temporarily having issues. Check in the developer forums in case others are having similar issues,  or try again later.
    when  502
      false # Bad Gateway  Twitter is down, or being upgraded.
    when  503
      false # Service Unavailable  The Twitter servers are up, but overloaded with requests. Try again later.
    when  504
      false # Gateway timeout  The Twitter servers are up, but the request couldn’t be serviced due to some failure within the internal stack. Try again later.
    when 3
      true # Invalid coordinates. Corresponds with HTTP 400. The coordinates provided as parameters were not valid for the request.
    when 13
      false # No location associated with the specified IP address. Corresponds with HTTP 404. It was not possible to derive a location for the IP address provided as a parameter on the geo search request.
    when 17
      true # No user matches for specified terms. Corresponds with HTTP 404. It was not possible to find a user profile matching the parameters specified.
    when 32
      true # Could not authenticate you  Corresponds with HTTP 401. There was an issue with the authentication data for the request.
    when 34
      true # Sorry, that page does not exist  Corresponds with HTTP 404. The specified resource was not found.
    when 36
      true # You cannot report yourself for spam.  Corresponds with HTTP 403. You cannot use your own user ID in a report spam call.
    when 44
      true # attachment_url parameter is invalid  Corresponds with HTTP 400. The URL value provided is not a URL that can be attached to this Tweet.
    when 50
      true # User not found.  Corresponds with HTTP 404. The user is not found.
    when 63
      true # User has been suspended.  Corresponds with HTTP 403 The user account has been suspended and information cannot be retrieved.
    when 64
      true # Your account is suspended and is not permitted to access this feature  Corresponds with HTTP 403. The access token being used belongs to a suspended user.
    when 68
      true # The Twitter REST API v1 is no longer active. Please migrate to API v1.1.  Corresponds to a HTTP request to a retired v1-era URL.
    when 87
      true # Client is not permitted to perform this action.  Corresponds with HTTP 403. The endpoint called is not a permitted URL.
    when 88
      false # Rate limit exceeded  The request limit for this resource has been reached for the current rate limit window.
    when 89
      false # Invalid or expired token  The access token used in the request is incorrect or has expired.
    when 92
      true # SSL is required  Only SSL connections are allowed in the API. Update the request to a secure connection. See how to connect using TLS
    when 93
      false # This application is not allowed to access or delete your direct messages  Corresponds with HTTP 403. The OAuth token does not provide access to Direct Messages.
    when 99
      false # Unable to verify your credentials.  Corresponds with HTTP 403. The OAuth credentials cannot be validated. Check that the token is still valid.
    when 120
      false # Account update failed: value is too long (maximum is nn characters). Corresponds with HTTP 403. Thrown when one of the values passed to the update_profile.json endpoint exceeds the maximum value currently permitted for that field. The error message will specify the allowable maximum number of nn characters.
    when 130
      false # Over capacity  Corresponds with HTTP 503. Twitter is temporarily over capacity.
    when 131
      true # Internal error  Corresponds with HTTP 500. An unknown internal error occurred.
    when 135
      false # Could not authenticate you  Corresponds with HTTP 401. Timestamp out of bounds (often caused by a clock drift when authenticating - check your system clock)
    when 139
      false # You have already favorited this status.  Corresponds with HTTP 403. A Tweet cannot be favorited (liked) more than once.
    when 144
      true # No status found with that ID.  Corresponds with HTTP 404. The requested Tweet ID is not found (if it existed, it was probably deleted)
    when 150
      true # You cannot send messages to users who are not following you.  Corresponds with HTTP 403. Sending a Direct Message failed.
    when 151
      true # There was an error sending your message: reason  Corresponds with HTTP 403. Sending a Direct Message failed. The reason value will provide more information.
    when 160
      false # You've already requested to follow user. Corresponds with HTTP 403. This was a duplicated follow request and a previous request was not yet acknowleged.
    when 161
      false # You are unable to follow more people at this time  Corresponds with HTTP 403. Thrown when a user cannot follow another user due to some kind of limit
    when 179
      true # Sorry, you are not authorized to see this status  Corresponds with HTTP 403. Thrown when a Tweet cannot be viewed by the authenticating user, usually due to the Tweet’s author having protected their Tweets.
    when 185
      false # User is over daily status update limit  Corresponds with HTTP 403. Thrown when a Tweet cannot be posted due to the user having no allowance remaining to post. Despite the text in the error message indicating that this error is only thrown when a daily limit is reached, this error will be thrown whenever a posting limitation has been reached. Posting allowances have roaming windows of time of unspecified duration.
    when 186
      false # Tweet needs to be a bit shorter.  Corresponds with HTTP 403. The status text is too long.
    when 187
      false # Status is a duplicate  The status text has already been Tweeted by the authenticated account.
    when 205
      false # You are over the limit for spam reports.  Corresponds with HTTP 403. The account limit for reporting spam has been reached. Try again later.
    when 215
      true # Bad authentication data  Corresponds with HTTP 400. The method requires authentication but it was not presented or was wholly invalid.
    when 220
      true # Your credentials do not allow access to this resource.  Corresponds with HTTP 403. The authentication token in use is restricted and cannot access the requested resource.
    when 226
      true # This request looks like it might be automated. To protect our users from spam and other malicious activity, we can’t complete this action right now.  We constantly monitor and adjust our filters to block spam and malicious activity on the Twitter platform. These systems are tuned in real-time. If you get this response our systems have flagged the Tweet or Direct Message as possibly fitting this profile. If you believe that the Tweet or DM you attempted to create was flagged in error, report the details by filing a ticket at https://help.twitter.com/forms/platform.
    when 231
      true # User must verify login  Returned as a challenge in xAuth when the user has login verification enabled on their account and needs to be directed to twitter.com to generate a temporary password. Note that xAuth is no longer an available option for authentication on the API.
    when 251
      true # This endpoint has been retired and should not be used.  Corresponds to a HTTP request to a retired URL.
    when 261
      true # Application cannot perform write actions.  Corresponds with HTTP 403. Thrown when the application is restricted from POST, PUT, or DELETE actions. Check the information on your application dashboard. You may also file a ticket at https://help.twitter.com/forms/platform.
    when 271
      false # You can’t mute yourself.  Corresponds with HTTP 403. The authenticated user account cannot mute itself.
    when 272
      false # You are not muting the specified user.  Corresponds with HTTP 403. The authenticated user account is not muting the account a call is attempting to unmute.
    when 323
      true # Animated GIFs are not allowed when uploading multiple images.  Corresponds with HTTP 400. Only one animated GIF may be attached to a single Tweet.
    when 324
      true # The validation of media ids failed.  Corresponds with HTTP 400. There was a problem with the media ID submitted with the Tweet.
    when 325
      true # A media id was not found.  Corresponds with HTTP 400. The media ID attached to the Tweet was not found.
    when 326
      false # To protect our users from spam and other malicious activity, this account is temporarily locked.  Corresponds with HTTP 403. The user should log in to https://twitter.com to unlock their account before the user token can be used.
    when 327
      true # You have already retweeted this Tweet. Corresponds with HTTP 403. The user cannot retweet the same Tweet more than once.
    when 354
      false # The text of your direct message is over the max character limit.  Corresponds with HTTP 403. The message size exceeds the number of characters permitted in a Direct Message.
    when 385
      true # You attempted to reply to a Tweet that is deleted or not visible to you.  Corresponds with HTTP 403. A reply can only be sent with reference to an existing public Tweet.
    when 386
      true # The Tweet exceeds the number of allowed attachment types.  Corresponds with HTTP 403. A Tweet is limited to a single attachment resource (media, Quote Tweet, etc.)
    when 407
      true # The given URL is invalid.  Corresponds with HTTP 400. A URL included in the Tweet could not be handled. This may be because a non-ASCII URL could not be converted, or for other reasons.
    when 415
      true # Callback URL not approved for this client application. Approved callback URLs can be adjusted in your application settings Corresponds with HTTP 403. The application callback URLs must be whitelisted via the application settings page on https://apps.twitter.com. Only approved callback URLs may be used by the application. See the Callback URL documentation.
    when 416
      true # Invalid / suspended application Corresponds with HTTP 401. The application has been suspended and cannot be used with Sign-in with Twitter.
    when 417
      true # Desktop applications only support the oauth_callback value 'oob' Corresponds with HTTP 401. The application is attempting to use out-of-band PIN-based OAuth, but a callback URL has been specified in the application settings.
    else
      false
    end
  end
end
