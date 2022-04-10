class ApplicationSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  def utc(datetime)
    datetime ? datetime.utc.to_i : nil
  end

  def created_at
    utc(object&.created_at)
  end

  def updated_at
    utc(object&.updated_at)
  end

  def admin_name(id)
    admin = ::Admin.find_by(id: id)
    admin ? admin.name : 'Anonymous user'
  end
end
