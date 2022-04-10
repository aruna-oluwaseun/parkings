require 'rails_helper'

RSpec.shared_examples 'valid logins' do
  it 'logs user in' do
    token = json[:token]
    expect(token.present?).to eq(true)
    expect(::Authorizer.authorize_by_token(token, Admin)).to eq(admin)
  end

  it_behaves_like 'response_201', :show_in_doc
end

RSpec.describe Api::Meo::V1::AuthController, type: :request do
  describe 'POST #sign_in' do
    let!(:password) { '12345678' }
    let!(:manager) { create(:admin, :manager, password: password) }
    let!(:town_manager) { create(:admin, :town_manager, password: password) }
    let!(:officer) { create(:admin, :officer, password: password) }
    let!(:admin) do
      create(:admin, username: 'ADminiStraTOR', password: password)
    end

    describe 'super admin' do
      let!(:valid_params) do
        {
          username: [admin.email, admin.username].sample,
          password: password
        }
      end

      context 'success' do
        subject do
          post '/api/meo/v1/auth/sign_in', params: { admin: valid_params }
        end

        it 'should create new admin token' do
          expect { subject }.to change(Admin::Token, :count).by(1)
        end

        it_behaves_like 'response_201', :show_in_doc

        it 'should answer with valid auth token' do
          subject
          token = json[:token]
          expect(token.present?).to eq(true)
          expect(::Authorizer.authorize_by_token(token, Admin)).to eq(admin)
        end
      end

      context 'citext username' do
        let(:valid_params) do
          {
            username: sample,
            password: password
          }
        end

        before do
          post '/api/meo/v1/auth/sign_in', params: { admin: valid_params }
        end

        context 'with all caps username' do
          let(:sample) { 'ADMINISTRATOR' }
          it_behaves_like 'valid logins'
        end

        context 'with all downcased username' do
          let(:sample) { 'administrator' }
          it_behaves_like 'valid logins'
        end

        context 'with all random case username' do
          let(:sample) { 'ADminiStraTOR' }
          it_behaves_like 'valid logins'
        end
      end

      context 'fail: invalid credentials' do
        context 'when invalid email' do
          subject do
            params = valid_params
            params[:username] = 'invalid@mail.com'
            post '/api/meo/v1/auth/sign_in', params: { admin: params }
          end

          it_behaves_like 'response_422', :show_in_doc

          it 'should have error about username' do
            subject
            expect(json[:errors][:username].present?).to eq(true)
          end
        end

        context 'when invalid password' do
          subject do
            params = valid_params
            params[:password] = 'invalid_password'
            post '/api/meo/v1/auth/sign_in', params: { admin: params }
          end

          it_behaves_like 'response_422', :show_in_doc

          it 'should have error about password' do
            subject
            expect(json[:errors][:password].present?).to eq(true)
          end
        end
      end

      context 'fail: suspended account' do
        subject do
          admin.suspended!
          post '/api/meo/v1/auth/sign_in', params: { admin: valid_params }
        end

        it 'should have error about suspended account' do
          subject
          expect(json[:errors][:base].present?).to eq(true)
        end

        it_behaves_like 'response_422', :show_in_doc
      end
    end

    describe 'manager' do
      let(:valid_params) do
        {
          username: [manager.email, manager.username].sample,
          password: password
        }
      end

      context 'success' do
        subject do
          post '/api/meo/v1/auth/sign_in', params: { admin: valid_params }
        end

        it 'should create new manager token' do
          expect { subject }.to change(Admin::Token, :count).by(1)
        end

        it_behaves_like 'response_201', :show_in_doc

        it 'should answer with valid auth token' do
          subject
          token = json[:token]
          expect(token.present?).to eq(true)
          expect(::Authorizer.authorize_by_token(token, Admin)).to eq(manager)
        end
      end
    end

    describe 'town manager' do
      let(:valid_params) do
        {
          username: [town_manager.email, town_manager.username].sample,
          password: password
        }
      end

      context 'success' do
        subject do
          post '/api/meo/v1/auth/sign_in', params: { admin: valid_params }
        end

        it 'should create new town manager token' do
          expect { subject }.to change(Admin::Token, :count).by(1)
        end

        it_behaves_like 'response_201', :show_in_doc

        it 'should answer with valid auth token' do
          subject
          token = json[:token]
          expect(token.present?).to eq(true)
          expect(::Authorizer.authorize_by_token(token, Admin)).to eq(town_manager)
        end
      end
    end

    describe 'officer' do
      let(:valid_params) do
        {
          username: [officer.email, officer.username].sample,
          password: password
        }
      end

      context 'success' do
        subject do
          post '/api/meo/v1/auth/sign_in', params: { admin: valid_params }
        end

        it 'should create new officer token' do
          expect { subject }.to change(Admin::Token, :count).by(1)
        end

        it_behaves_like 'response_201', :show_in_doc

        it 'should answer with valid auth token' do
          subject
          token = json[:token]
          expect(token.present?).to eq(true)
          expect(::Authorizer.authorize_by_token(token, Admin)).to eq(officer)
        end
      end
    end

  end
end
