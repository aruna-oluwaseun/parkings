class LocationSerializer < ::ApplicationSerializer
  attributes :lng,
    :ltd,
    :street,
    :country,
    :state,
    :city,
    :full_address,
    :zip
end
