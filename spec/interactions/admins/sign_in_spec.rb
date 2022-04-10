require 'rails_helper'

describe Admins::SignIn do
  subject { described_class.run( { username: username, password: password, requester_type: requester_type } ) }
  let(:requester_type)  { "meo" }
  let(:username)        { "invalid_username" }
  let(:password)        { "invalid_password" }
  let(:status)          { "active" }
  let(:role)            { Role.find_by(name: :super_admin) }

  def expect_invalid_service error_message
    # Run service only once
    service = subject
    expect(service).to be_invalid
    expect(service.errors.messages).to match(error_message)
  end

  describe 'Service should' do

    before(:each) do
      create(:admin, email: "admin@example.com", username: "superadmin", password: "password", status: status, role: role)
    end

    context 'be invalid' do
      let(:requester_type) { 'invalid_requester' }
      it 'if requester type is invalid' do
        expect_invalid_service( { base: ["Invalid requester type"] } )
      end
    end

    context 'be invalid' do
      it 'if admin was not found' do
        expect_invalid_service( { username: [(I18n.t 'active_interaction.errors.models.admins/sign_in.attributes.username.invalid_username')] } )
      end
    end

    context 'be invalid' do
      let(:username) { "superadmin" }
      it 'if password is not valid' do
        expect_invalid_service( { password: [(I18n.t 'active_interaction.errors.models.admins/sign_in.attributes.password.invalid')] } )
      end
    end

    context 'be invalid' do
      let(:username) { "superadmin" }
      let(:password) { "password" }
      let(:status)   { "suspended" }
      it 'if admin is suspended' do
        expect_invalid_service( { base: ["Your account is suspended, please contact the admin"] } )
      end
    end

    context 'be valid and return token' do

      before do
        allow(Authorizer).to receive(:generate_token).and_wrap_original do |m, *args|
          m.call(*args)
          "token"
        end
      end

      let(:username) { "superadmin" }
      let(:password) { "password" }

      it 'if everything is ok' do
        expect do
          service = subject
          expect(service).to be_valid
          expect(service.result.token).to match("token")
        end.to change { Admin::Token.count }.by 1
      end
    end

  end

end
