class ApplicationController < ActionController::Base
  respond_to :json
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: { message: not_found_error_message }, status: 404
  end

  def not_found_error_message
    "Couldn't find #{controller_name.classify} with id=#{params[:id]}!"
  end
end
