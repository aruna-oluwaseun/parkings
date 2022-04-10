namespace :roles do
  task seed_data: :environment do
    Role.transaction do
      RolesPermissionsCommand.execute
    end
  end
end
