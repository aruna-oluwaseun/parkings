module Build
  class UserWalletsBuilder
    attr_reader :users

    def initialize
      @users = User.without_wallets
    end

    def call
      users.each { |user| user.create_wallet }
    end
  end
end
