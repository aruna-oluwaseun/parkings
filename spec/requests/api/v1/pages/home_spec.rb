require 'rails_helper'

describe Api::V1::PagesController, type: :request do
  let(:user) { create(:user, :confirmed) }

  describe 'GET #home' do
    subject { get '/api/v1/pages/home', headers: { Authorization: get_auth_token(user) } }

    let(:json_response) do
      JSON.parse(response.body).symbolize_keys
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'respond with homepage video' do
      subject
      expect(json_response[:homepage_video]).to eq 'https://youtu.be/Q_90ZlygfGI'
    end
  end
end