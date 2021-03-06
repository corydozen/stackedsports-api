require 'stitches'

Stitches.configure do |configuration|
  # Regexp of urls that do not require ApiKeys or valid, versioned mime types
  configuration.allowlist_regexp = %r{\/|users|request_access|success|athletes|admin|dashboard|root|reset-password|password_resets|login|logout|activate|sessions|media-library|sms_events|sidekiq|resque|docs|assets|temp_athletes|temp_commit_offers|commit-offers|co_email_recipients|co_email_groupings|conferences|rails\/mailers|forest|inbox|messages}
  # |users\/.*\/activate|password_resets
  # Name of the custom Authorization scheme.  See http://www.ietf.org/rfc/rfc2617.txt for details,
  # but generally should be a string with no spaces or special characters.
  configuration.custom_http_auth_scheme = 'StackedSportsAuthKey'

  # Env var that gets the primary key of the authenticated ApiKey
  # for access in your controllers, so they don't need to re-parse the header
  # configuration.env_var_to_hold_api_client_primary_key = "YOUR_ENV_VAR"
end
