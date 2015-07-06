require 'rails_helper'

RSpec.describe EpisodesController, :type => :controller do
  let(:tv_show) { FactoryGirl.create(:tv_show) }
  let(:user) { FactoryGirl.create(:user) }
  let!(:episode_1) { FactoryGirl.create(:episode) }

  before do
    request.accept = 'application/json'
    sign_in :user, user
  end

  describe 'GET #index' do
    let!(:episode_2) { FactoryGirl.create(:episode, tv_show: tv_show) }

    context 'when requesting all episodes' do
      before { get :index }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'responses with all episodes' do
        expect(JSON.parse(response.body)['episodes'].length).to eq(2)
      end
    end

    context 'when requesting episodes of specific tv show' do
      before { get :index, tv_show_id: 1 }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'responses only with episodes with tv show id = 1' do
        expect(response.body).to include("\"tv_show_id\":1")
        expect(response.body).not_to include("\"tv_show_id\":#{tv_show.id}")
      end
    end
  end

  describe 'GET #show' do
    context 'when episode exists' do
      before { get :show, id: episode_1.id }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'returns proper episode' do
        expect(response.body).to include(episode_1.id.to_s)
        expect(response.body).to include(episode_1.title)
        expect(response.body).to include(episode_1.tv_show.id.to_s)
      end
    end

    context 'when episode does not exist' do
      before do
        assert_raises(ActiveRecord::RecordNotFound) { Episode.find(666) }
        get :show, id: 666
      end

      it { expect(response).not_to be_success }
      it { expect(response).to have_http_status(404) }
      it { expect(response.body).to eq("{\"message\":\"Couldn't find Episode with id=666!\"}") }
    end
  end

  describe 'POST #create' do
    context 'when params are invalid' do
      context 'when params are incomplete' do
        let(:incomplete_params) { { title: 'Needs episode id!' } }
        before { post :create, episode: incomplete_params }

        it { expect(response).not_to be_success }
        it { expect(response).to have_http_status(422) }
        it { expect(response.body).to eq("{\"tv_show\":[\"can't be blank\"],\"episode\":[\"can't be blank\"]}") }
      end

      context 'when title is not unique per tv show' do
        let(:valid_params) { FactoryGirl.attributes_for(:episode).merge({tv_show_id: 1}) }
        before { 2.times { post :create, episode: valid_params } }

        it { expect(response).not_to be_success }
        it { expect(response).to have_http_status(422) }
        it { expect(response.body).to eq("{\"title\":[\"has already been taken\"]}") }
      end
    end

    context 'when params are valid' do
      let(:valid_params) { FactoryGirl.attributes_for(:episode).merge({tv_show_id: 1}) }
      before { post :create, episode: valid_params }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'respond with created tv show' do
        expect(response.body).to include(valid_params[:tv_show_id].to_s)
        expect(response.body).to include(valid_params[:title])
        expect(response.body).to include(valid_params[:episode].to_s)
        expect(response.body).to include(valid_params[:watched].to_s)
      end
    end
  end

  describe 'PUT #update' do
    let(:valid_params) { FactoryGirl.attributes_for(:episode) }
    before do
      refute_nil(Episode.where(id: episode_1.id))
      put :update, id: episode_1.id, episode: valid_params
    end
    context 'with valid params' do

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'respond with updated episode' do
        expect(response.body).to include(valid_params[:tv_show_id].to_s)
        expect(response.body).to include(valid_params[:title])
        expect(response.body).to include(valid_params[:episode].to_s)
        expect(response.body).to include(valid_params[:watched].to_s)
      end
    end

    context 'with invalid params' do
      context 'when episode title is not unique per tv show' do
        let(:episode_2) { FactoryGirl.create(:episode, tv_show: episode_1.tv_show) }
        before { put :update, id: episode_2.id, episode: valid_params }

        it { expect(response).not_to be_success }
        it { expect(response).to have_http_status(422) }
        it { expect(response.body).to eq("{\"title\":[\"has already been taken\"]}") }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when episode does not exist' do
      before do
        assert_raises(ActiveRecord::RecordNotFound) { Episode.find(666) }
        delete :destroy, id: 666
      end

      it { expect(response).not_to be_success }
      it { expect(response).to have_http_status(404) }
      it { expect(response.body).to eq("{\"message\":\"Couldn't find Episode with id=666!\"}") }
    end

    context 'when episode exists' do
      before do
        refute_nil(Episode.find(episode_1.id))
        delete :destroy, id: episode_1.id
      end

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'responds with deleted episode' do
        expect(response.body).to include(episode_1.tv_show_id.to_s)
        expect(response.body).to include(episode_1.title)
        expect(response.body).to include(episode_1.episode.to_s)
        expect(response.body).to include(episode_1.watched.to_s)
      end
    end
  end
end
