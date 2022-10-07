# frozen_string_literal: true

Rack::Attack.throttle('requests by ip', limit: 10, period: 60, &:ip) unless Rails.env.development?
