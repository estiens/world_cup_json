class BaseApiController < ApplicationController
  after_filter :set_content_type
  protect_from_forgery with: :null_session
  layout false
  respond_to :json

  private

  def set_content_type
    cb = params['callback']
    headers['Content-Type'] = 'application/javascript' unless cb.blank?
  end
end
