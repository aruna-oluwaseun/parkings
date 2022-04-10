require 'rails_helper'

describe Api::V1::PagesController, type: :request do
  let(:user) { create(:user, :confirmed) }

  describe 'GET #meo_contact_details' do
    subject { get '/api/v1/pages/meo_contact_details', headers: { Authorization: get_auth_token(user) } }

    let(:json_response) do
      JSON.parse(response.body).symbolize_keys
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'respond with meo contact details content' do
      subject
      expect(json_response).to eq I18n.t("pages.meo_contact_details")
    end
  end
end