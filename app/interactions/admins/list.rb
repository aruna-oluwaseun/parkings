module Admins
  class List < ::ApplicationInteraction
    attr_reader :user
    integer :id

    set_callback :execute, :before, :set_user

    validates :id, presence: true

    def execute
      @admin.managed_users
    end

    private

    def set_user
      @admin = Admin.find(id)
    end
  end
end