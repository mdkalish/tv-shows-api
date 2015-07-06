require 'rails_helper'

RSpec.describe 'mark episode watched', type: :request do
  let(:user) { FactoryGirl.create(:user) }
  let(:tv_show_with_episodes) { FactoryGirl.create(:tv_show_with_episodes, episodes_count: 5) }

  it do
    post '/users/sign_in', user: { email: user.email, password: user.password }
    put "/episodes/#{tv_show_with_episodes.episodes.first.id}", episode: { watched: true }, format: :json
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['watched']).to eq(true)
  end
end
