module Api
  module V1
    class ThinUserSerializer < ::ApplicationSerializer
      attributes :email, :first_name, :last_name, :phone, :created_at
    end
  end
end
