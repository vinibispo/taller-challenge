class Books::ReserveController < ApplicationController
  def execute
    case Books::Reserve.new(params[:book_id]).execute!(params[:email])
    in data, :ok, nil
      render json: data, status: :ok
    in data, status, error
      render json: { error: error }, status: status
    end
  rescue => e
    Rails.logger.error("Unhandled error reserving book: #{e.class} #{e.message}")
    render json: { error: "An unexpected error occurred" }, status: :internal_server_error
  end
end
