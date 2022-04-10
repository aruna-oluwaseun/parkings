module AdminManagedUsers
  def managed_by_system_admin
    managed_by_super_admin
  end

  def managed_by_super_admin
    Admin.where.not(id: id)
  end

  def managed_by_town_manager
    lots = ParkingLot
            .includes({ agency: :officers }, :town_managers)
            .where(id: admins_parking_lot_ids)

    [
      lots.map(&:agency).compact.map(&:officers),
      lots.map(&:parking_admins).compact
    ].flatten
  end

  def managed_by_parking_admin
    lots = ParkingLot
            .includes({ agency: [:officers, :managers] })
            .where(id: admins_parking_lot_ids)

    [
      lots.map(&:agency).map(&:officers)
    ].flatten
  end

  def managed_by_manager
    if agency_manager?
      Agency.includes(:officers).
        where(id: admins_agencies_id).map do |agency|
          agency.officers
        end.flatten
    else
      []
    end
  end

  def managed_by_officer
    []
  end

  private

  def admins_parking_lot_ids
    ::Admin::Right.where(
      subject_type: 'ParkingLot', admin_id: id
    ).select(:subject_id)
  end

  def admins_agencies_id
    ::Admin::Right.where(
      subject_type: 'Agency', admin_id: id
    ).select(:subject_id)
  end

  def agency_manager?
    admins_agencies_id.any?
  end
end
