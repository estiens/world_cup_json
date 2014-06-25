class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  protected
  
  def set_content_type
    if !params['callback'].blank?
      headers['Content-Type'] = "application/javascript"
    end
  end
end
