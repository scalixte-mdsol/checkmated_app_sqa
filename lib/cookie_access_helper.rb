module CookieAccessHelper
  
  attr_accessor :primary_key, :secondary_key
  
  # Removes a level of nesting from the obj and returns the result
  def get_user_cookie(user_uuid)
    user_settings = super(user_uuid)
    user_settings[primary_key] ||= default_primary_key_value
  end

  # Adds a level of nesting and submits the obj
  def update_user_cookie(user_uuid, obj)
    obj = {primary_key => obj}
    super(user_uuid, obj)
  end
  
  # Loads user list settings based on primary_key and secondary_key and overwrites info referenced by primary_key 
  # if the secondary_key is different from the earlier one referenced by primary_key. Example structure of user_setting storage is below
  # {list_name: { study_uuid: { page: 1, sort_by: 'email,ASC'}}}
  def load_and_set_list_settings(prim_key, sec_key, list_settings)
    self.primary_key = prim_key
    self.secondary_key = sec_key
    user_settings = get_user_cookie(current_user_uuid)
    unless secondary_key_exists?(user_settings)
      user_settings = default_primary_key_value
    end
    update_user_cookie(current_user_uuid, user_settings)
    unless secondary_key_exists?(session[primary_key])
      session[primary_key] = default_primary_key_value
    end
    @session_ = session[primary_key]
    determine_list_settings(secondary_key, list_settings)
  end
  
  # A value exists for secondary level key
  def secondary_key_exists?(hsh)
    hsh && hsh.respond_to?(:keys) && hsh.keys.first == secondary_key
  end
  
  # initial value of primary level key of cookie/sesion storage for storing list info
  def default_primary_key_value
    {secondary_key => {}}
  end
end
