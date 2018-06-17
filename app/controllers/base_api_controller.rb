class BaseApiController < ApplicationController
  after_filter :set_content_type
  protect_from_forgery with: :null_session
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

  def set_content_type
    cb = params['callback']
    headers['Content-Type'] = 'application/javascript' unless cb.blank?
  end

  def record_not_found(error = nil)
    render json: { message: error&.message }, status: :not_found
  end

  def unprocesssable_entity(error = nil)
    render json: { message: error&.message }, status: :unprocesssable_entity
  end
end
