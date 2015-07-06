require 'rails_helper'

RSpec.describe TvShowsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in :user, user
    request.accept = 'application/json'
  end

  describe 'GET #index' do
    before do
      5.times { FactoryGirl.create(:tv_show) }
      get :index
    end

    it { expect(response).to be_success }
    it { expect(response).to have_http_status(200) }
    it 'returns all tv shows' do
      expect(JSON.parse(response.body)['tv_shows'].length).to eq(5)
    end
  end

  describe 'GET #show' do
    context 'when tv show exists' do
      let(:tv_show_with_episodes) { FactoryGirl.create(:tv_show_with_episodes, episodes_count: 3) }
      let(:response_body) { JSON.parse(response.body) }
      before { get :show, id: tv_show_with_episodes.id }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it { expect(response_body).to have_key('episodes') }
      it { expect(response_body['episodes']).to be_an(Array) }
      it { expect(response_body['episodes'].length).to eq(3) }
      it { expect(response_body['id']).to eq(1) }
    end

    context 'when tv show does not exist' do
      before do
        assert_raises(ActiveRecord::RecordNotFound) { TvShow.find(666) }
        get :show, id: 666
      end

      it { expect(response).not_to be_success }
      it { expect(response).to have_http_status(404) }
      it { expect(response.body).to eq("{\"message\":\"Couldn't find TvShow with id=666!\"}") }
    end
  end

  describe 'POST #create' do
    let(:valid_params) { FactoryGirl.attributes_for(:tv_show) }

    context 'when params are valid' do
      let(:valid_params_2) { FactoryGirl.attributes_for(:tv_show) }
      before { post :create, tv_show: valid_params }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(201) }
      it { expect(response.body).to include(valid_params[:title]) }
      it { expect {post :create, tv_show: valid_params_2}.to change(TvShow, :count).from(1).to(2) }
    end

    context 'when params are invalid' do
      let(:invalid_params) { { description: 'Params need title to be valid!' } }
      before { post :create, tv_show: invalid_params }

      it { expect(response).not_to be_success }
      it { expect(response).to have_http_status(422) }
      it { expect(response.body).to eq("{\"title\":[\"can't be blank\"]}") }
      it 'fails if title is not unique' do
        expect {post :create, tv_show: valid_params}.to change(TvShow, :count).by(1)
        post :create, tv_show: valid_params
        expect(response.body).to eq("{\"title\":[\"has already been taken\"]}")
      end
    end
  end

  describe 'PUT #update' do
    context 'when params are invalid' do
      context 'when tv show does not exist' do

        it do
          assert_raises(ActiveRecord::RecordNotFound) { TvShow.find(666) }
          put :update, id: 666
          expect(response.body).to eq("{\"message\":\"Couldn't find TvShow with id=666!\"}")
        end
      end

      context 'when title is not unique' do
        let(:tv_show_1) { FactoryGirl.create(:tv_show) }
        let(:tv_show_2) { FactoryGirl.create(:tv_show) }
        let(:tv_show_params) { FactoryGirl.attributes_for(:tv_show) }

        it do
          put :update, id: tv_show_1.id, tv_show: tv_show_params
          put :update, id: tv_show_2.id, tv_show: tv_show_params
          expect(response.body).to eq("{\"title\":[\"has already been taken\"]}")
        end
      end
    end

    context 'when params are valid' do
      let(:tv_show_1) { FactoryGirl.create(:tv_show) }
      let(:tv_show_params) { FactoryGirl.attributes_for(:tv_show) }
      before { put :update, id: tv_show_1.id, tv_show: tv_show_params }

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(200) }
      it 'updates the tv show' do
        expect(TvShow.find(tv_show_1.id).title).to eq(tv_show_params[:title])
      end
      it 'responds with the updated tv show' do
        expect(JSON.parse(response.body)['title']).to eq(tv_show_params[:title])
        expect(JSON.parse(response.body)['id']).to eq(tv_show_1.id)
        expect(JSON.parse(response.body)['episodes']).to eq(tv_show_1.episodes)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when tv show does not exist' do
      it do
        assert_raises(ActiveRecord::RecordNotFound) { TvShow.find(666) }
        delete :destroy, id: 666
        expect(response.body).to eq("{\"message\":\"Couldn't find TvShow with id=666!\"}")
      end
    end

    context 'when tv show exists' do
      let(:tv_show) { FactoryGirl.create(:tv_show) }
      before do
        refute_nil(TvShow.find(tv_show.id))
        delete :destroy, id: tv_show.id
      end

      it { expect(response).to be_success }
      it { expect(response).to have_http_status(204) }
      it { expect(response.body).to include(tv_show.title) }
      it { expect { TvShow.find(tv_show.id) }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
