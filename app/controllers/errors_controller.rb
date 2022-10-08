# frozen_string_literal: true

class ErrorsController
  def path_not_found
    render json: { message: "Path Not Found" }, status: 404
  end
end
