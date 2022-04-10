class FillLawEnforcementAgencyType < ActiveRecord::Migration[5.2]
  def up
    AgencyType::DEFAULT_NAMES.each do |type_name|
      unless AgencyType.find_by(name: type_name)
        AgencyType.create(name: type_name)
      end
    end
  end

  def down
    AgencyType.where(name: AgencyType::DEFAULT_NAMES).delete_all
  end
end
