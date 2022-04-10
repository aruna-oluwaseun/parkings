require 'rails_helper'

RSpec.describe Api::V1::Ai::CamerasController, type: :request do
  let!(:auth_token) { create(:ai_token).value }
  describe 'PUT #down' do
    context 'success' do
      let!(:camera) { create(:camera, number: 1) }

      subject do
        put "/api/v1/ai/cameras/down", headers: { Authorization: auth_token }, params: { camera_number: 1 }
      end

      it 'should update status' do
        expect(camera.status).to eq("up")
        subject
        camera.reload
        expect(camera.status).to eq("down")
        expect(status).to eq(204)
      end

    end
    context 'failure' do
      let!(:camera) { create(:camera, number: 1) }

      subject do
        put "/api/v1/ai/cameras/down", headers: { Authorization: auth_token }
      end

      it 'should update status' do
        expect { subject }.to raise_error(NoMethodError)
      end

    end
  end

  describe 'PUT #up' do
    context 'success' do
      let!(:camera) { create(:camera, number: 1, status: :down) }

      subject do
        put "/api/v1/ai/cameras/up", headers: { Authorization: auth_token }, params: { camera_number: 1 }
      end

      it 'should update status' do
        expect(camera.status).to eq("down")
        subject
        camera.reload
        expect(camera.status).to eq("up")
        expect(status).to eq(204)
      end

    end
    context 'failure' do
      let!(:camera) { create(:camera, number: 1) }

      subject do
        put "/api/v1/ai/cameras/up", headers: { Authorization: auth_token }
      end

      it 'should update status' do
        expect { subject }.to raise_error(NoMethodError)
      end

    end
  end
end