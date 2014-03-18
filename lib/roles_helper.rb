# module to get all roles, and store them in an instance variable for the current request
module RolesHelper
  # Returns the medidata roles, also saving them to an instance variable
  def config_type_roles(config_type_uuid)
    safe_fetch('ConfigurationTypeRole', :all, params: {configuration_type_uuid: config_type_uuid, per_page: 90000})
  end

  def study_roles(study_uuid)
    config_type_uuid = Study.find_by_uuid(study_uuid).configuration_type_uuid
    config_type_roles(config_type_uuid)
  end
  
  def roles_hash_with_exceptions(study_uuid)
    roles = roles_hash(study_uuid)
    @error ? raise(@error) : roles
  end

  # Returns a hash of the medidata roles, keyed on role name
  def roles_hash(study_uuid)
    @roles_hash ||= {}
    @roles_hash[study_uuid] ||= study_roles(study_uuid).reduce({}) { |h, role| h[role.name] = role; h }
  end
  
  # list of role names
  def study_role_names(study_uuid)
    @role_names ||= {}
    @role_names[study_uuid] ||= study_roles(study_uuid).map { |x| x.name }
  end

  def find_role_by_name(study_uuid, role_name)
    study_roles(study_uuid).find do |role|
      role.name.downcase == role_name.downcase
    end.try(:uuid)
  end
end
