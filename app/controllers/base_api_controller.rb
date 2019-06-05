# frozen_string_literal: true

class BaseApiController < ApplicationController
  protect_from_forgery with: :null_session
  layout false
  respond_to :json
  before_filter :set_cache_time
  after_filter :set_jsonp_format

  rescue_from StandardError do |error|
    notify_airbrake(error)
    unprocessable_entity(error)
  end

  rescue_from ActiveRecord::RecordNotFound do |error|
    record_not_found(error)
  end

  private

  def set_cache_time
    @cache_time = if Match.in_progress.count.positive?
                    30.seconds
                  else
                    1.minute
    end
  end

  def set_jsonp_format
    return unless params[:callback] && request.get?

    self.response_body = "#{params[:callback]}(#{response.body})"
    headers['Content-Type'] = 'application/javascript'
  end

  def record_not_found(error = nil)
    render json: { message: error&.message }, status: :not_found
  end

  def unprocessable_entity(error = nil)
    render json: { message: error&.message }, status: :unprocesssable_entity
  end
end
