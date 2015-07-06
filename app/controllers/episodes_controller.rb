class EpisodesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:tv_show_id]
      render json: Episode.where(tv_show_id: params[:tv_show_id])
    else
      render json: Episode.all
    end
  end

  def show
    render json: Episode.find(params[:id])
  end

  def create
    episode = Episode.new(episode_params)
    if episode.save
      render json: episode
    else
      render json: episode.errors.messages, status: 422
    end
  end

  def update
    episode = Episode.find(params[:id])
    if episode.update_attributes(episode_params)
      render json: episode
    else
      render json: episode.errors.messages, status: 422
    end
  end

  def destroy
    render json: Episode.find(params[:id]).delete
  end

  private

  def episode_params
    params.require(:episode).permit(:tv_show_id, :title, :episode, :watched)
  end
end
