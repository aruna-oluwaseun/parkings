
module Api
  module V1
    module Ai
      class CamerasController < ::Api::V1::Ai::ApplicationController

        api :PUT, '/api/v1/ai/cameras/down', 'Set a camera as down'
        param :parking_lot_id, Integer, 'Parking lot ID', required: false
        param :camera_number, Integer, 'Camera number', required: true
        header :Authorization, 'Auth token for AI module', required: true

        def down
          camera = Camera.find_by(number: params[:camera_number])
          if camera.up?
            ::Ai::ErrorReport.create(error_type: :camera_down)
            camera.update(status: :down)
            send_event(camera.number, 'down')
            head :no_content
          else
            head :ok
          end
        end

        api :PUT, '/api/v1/ai/cameras/up', 'Set a camera as up'
        param :parking_lot_id, Integer, 'Parking lot ID', required: false
        param :camera_number, Integer, 'Camera number', required: true
        header :Authorization, 'Auth token for AI module', required: true

        def up
          camera = Camera.find_by(number: params[:camera_number])
          if camera.down?
            send_event(camera.number, 'up')
          end
          camera.update(status: :up)
          head :no_content
        end

        private

        def send_event(number, status)
          message = I18n.t("slack_notifier.ai.camera_update", number: number, status: status, env: Rails.env)
          ::Ai::SlackNotifier.ping(message)
        end
      end
    end
  end
end
