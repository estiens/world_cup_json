Rack::Attack.throttle('requests by ip', limit: 10, period: 60, &:ip)

Rack::Attack.throttled_response = lambda do |env|
  now = Time.now
  match_data = env['rack.attack.match_data']

  reset = (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
  headers = {
    'X-RateLimit-Limit' => match_data[:limit].to_s,
    'X-RateLimit-Period' => '30 seconds',
    'X-RateLimit-Remaining' => '0',
    'X-RateLimit-Reset' => reset
  }

  message = "Throttled\nPlease limit your requests to 10 every 60 seconds\n"
  [429, headers, [message]]
end
