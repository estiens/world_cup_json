# frozen_string_literal: true

class BaseApiController < ApplicationController
  protect_from_forgery with: :null_session
  layout false
  # before_action :set_cache_time
  before_action :set_request_format
  after_action :set_jsonp_format

  rescue_from StandardError do |error|
    # notify_airbrake(error)
    Rails.logger.error(error)
    unprocessable_entity(error)
  end

  rescue_from ActiveRecord::RecordNotFound do |error|
    Rails.logger.error(error)
    record_not_found(error)
  end

  private

  def set_cache_time
    @cache_time = if Match.in_progress.count.positive?
                    30.seconds
                  elsif Match.today.future.count.positive?
                    1.minute
                  else
                    5.minutes
                  end
  end

  def set_request_format
    request.format = :json
  end

  def set_jsonp_format
    return unless params[:callback] && request.get?

    self.response_body = "#{params[:callback]}(#{response.body})"
    headers['Content-Type'] = 'application/javascript'
  end

  def set_time_zone
    @time_zone = params[:timezone]
  end

  def record_not_found(error = nil)
    render json: { message: error&.message }, status: 404
  end

  def unprocessable_entity(error = nil)
    render json: { message: error&.message }, status: 421
  end
end
