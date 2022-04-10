class ApplicationPolicy < ActionPolicy::Base

  def index?
    permission.read?
  end

  def show?
    record_is_permissable? ?
    permission.read? : true
  end

  def create?
    record_is_permissable? ?
    permission.create? : true
  end

  def update?
    record_is_permissable? ?
    permission.update? : true
  end

  def destroy?
    record_is_permissable? ?
    permission.delete? : true
  end

  def search?
    record_is_permissable? ?
    permission.read? : true
  end

  private

  def record_is_permissable?
    entity = case record
             when Class
              record.name
             else
              record.class.name
             end
    Role::Permission::PERMISSIONS_AVAILABLE.include? entity
  end

  def permission
    @permission ||= case record
    when Class
      Access::Model.new(user, record)
    else
      Access::Model.new(user, record.class.name)
    end
  end

  def super_admin?
    user.admin?
  end

  def town_manager?
    user.town_manager?
  end

  def parking_operator?
    user.parking_admin?
  end
end
