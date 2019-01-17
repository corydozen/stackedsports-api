module RateLimitHelper
#   # NOTE: For Twitter Rate Limit info see: https://developer.twitter.com/en/docs/basics/rate-limits
#
  def self.get_rate_limits(oauth_token, oauth_token_secret, resources=nil, node=nil)
    # NOTE: can pass a comma delimited list of resources to get specific limits instead of all
    resources_params = "?resources=#{resources}" if resources.present?
    response = RequestHelper.request(oauth_token, oauth_token_secret, "/application/rate_limit_status.json#{resources_params}", 'get')

    if node.present?
      if resources.count(',') > 0
          ErrorHelper.format('{"errors":[{"message":"Can\'t return single node for multiple resources, only request a single resource or remove specific node","code":422}]}')
      else
        node_result = response['resources'][resources]["/#{resources}/#{node}"]
        if node_result.present?
          node_result
        else
          ErrorHelper.format('{"errors":[{"message":"Can\'t find specific node requested, please try a different node","code":422}]}')
        end
      end
    else
      response
    end
  end

  def self.wait_progress(wait_time, id = '')
    note = "Rate Limited for #{wait_time} seconds"
    note = "#{id} is #{note}" if id.present?
    wait_time.times_with_progress(note) do |i|
      # do something with i if needed
      sleep 1
    end
  end
end
