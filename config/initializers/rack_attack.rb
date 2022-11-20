# frozen_string_literal: true

unless Rails.env.development? || ENV.fetch('THROTTLE_OFF', 'false') == 'true'
  Rack::Attack.throttle('requests by ip', limit: 20, period: 60, &:ip)
end
