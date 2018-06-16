if ENV['REDISTOGO_URL']
  redis_client = Redis.new(url: ENV['REDISTOGO_URL'])
  Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(redis_client)
end

Rack::Attack.throttle('requests by ip', limit: 5, period: 2, &:ip)

Rack::Attack.throttled_response = lambda do |env|
  now = Time.now
  match_data = env['rack.attack.match_data']

  headers = {
    'X-RateLimit-Limit' => match_data[:limit].to_s,
    'X-RateLimit-Remaining' => '0',
    'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
  }

  [429, headers, ["Throttled\n"]]
end

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  if req.env["rack.attack.match_type"] == :throttle
    request_headers = { "CF-RAY" => req.env["HTTP_CF_RAY"],
                        "X-Amzn-Trace-Id" => req.env["HTTP_X_AMZN_TRACE_ID"] }

    Rails.logger.info "[Rack::Attack][Blocked]" <<
                      "remote_ip: \"#{req.remote_ip}\"," <<
                      "path: \"#{req.path}\", " <<
                      "headers: #{request_headers.inspect}"
  end
end
