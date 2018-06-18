class BaseApiController < ApplicationController
  after_filter :set_content_type
  protect_from_forgery with: :null_session
  after_filter :set_jsonp_format
  layout false
  respond_to :json

  rescue_from StandardError do |error|
    notify_airbrake(error)
    unprocesssable_entity(error)
  end

  rescue_from ActiveRecord::RecordNotFound do |error|
    record_not_found(error)
  end

  private

  def set_jsonp_format
    return unless params[:callback] && request.get?
    self.response_body = "#{params[:callback]}(#{response.body})"
    headers["Content-Type"] = 'application/javascript'
  end

  def record_not_found(error = nil)
    render json: { message: error&.message }, status: :not_found
  end

  def unprocesssable_entity(error = nil)
    render json: { message: error&.message }, status: :unprocesssable_entity
  end
end
