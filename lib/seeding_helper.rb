# This module is used for seeding a static set of uuids into external services and our local database tables
module SeedingHelper
  # Should be called before trying to seed users into the external users service or mccadmin's db
  def reset_user_counter
    @user_counter = 1
  end

  # Passed into the uuid attribute on creation/retrieval from the external users service
  def generate_new_user_uuid
    @user_counter ||= 1
    current_user_counter = @user_counter
    @user_counter += 1
    raise 'uuid invalid' if current_user_counter > 999
    "0f337640-2c55-11e3-8224-0800200c9#{'%03d' % current_user_counter}"
  end
end
