# frozen_string_literal: true

class ErrorsController < BaseApiController
  def path_not_found
    @requested_path = request.path
    render json: { message: "Path Not Found: #{@requested_path}" },
           status: :not_found
  end
end
