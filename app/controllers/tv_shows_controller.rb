class TvShowsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: TvShow.all
  end

  def show
    render json: TvShow.find(params[:id])
  end

  def create
    tv_show = TvShow.new(tv_show_params)
    tv_show.user_id = current_user.id
    if tv_show.save
      render json: tv_show, status: 201
    else
      render json: tv_show.errors.messages, status: 422
    end
  end

  def update
    tv_show = TvShow.find(params[:id])
    if tv_show.update_attributes(tv_show_params)
      render json: tv_show
    else
      render json: tv_show.errors.messages, status: 422
    end
  end

  def destroy
    render json: TvShow.find(params[:id]).delete, status: 204
  end

  private

  def tv_show_params
    params.require(:tv_show).permit(:title, :description)
  end
end
