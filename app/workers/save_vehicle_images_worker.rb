class SaveVehicleImagesWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers
  sidekiq_options queue: :images

  def perform(record_id, images, unrecognized_lpn, parking_slot_id, uuid)
    record = Vehicle.find(record_id)
    PaperTrail.request.disable_model('Vehicle')
    images_url_alert = []
    images.each do |image|
      return if image.empty?
      unless stored_image = record.images.attach({ data: image })
        errors.merge!(image.errors)
        throw(:abort)
      end
      images_url_alert.push(url_for(stored_image.first))
    end
    if unrecognized_lpn
      message = format_message(parking_slot_id, uuid, images_url_alert, Rails.env)
      ::Ai::SlackNotifier.ping(message)
    end
  end

  def format_message(parking_slot_id, uuid, images_url_alert, env)
    images_list = ""
    images_url_alert.each do |image_url|
      images_list+= "\n- #{image_url}"
    end
    I18n.t('slack_notifier.ai.unrecognized_lpn',
      parking_slot_id: parking_slot_id,
      uuid: uuid,
      images_list: images_list,
      env: env
    )
  end
end
