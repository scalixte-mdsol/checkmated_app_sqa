module ParameterSettingForList
  # Based on the user's cookie and request, determine study list settings and save them to the user's cookie
  def determine_list_settings(key=nil, list_settings={})
    @list_template_settings = list_settings
    if key
      user_settings = get_user_cookie(current_user_uuid)
      get_list_params(key, user_settings)  if user_settings[key]
      clear_list_selections(key, user_settings) if @session_
      if @list_template_settings[:checkbox]
        if list_selection = @session_[key][:list_selection]
          @list_template_settings[:checkbox][:list_selection] = list_selection
          @session_[key][:perform_list_defaults] = false
        else
          @session_[key][:perform_list_defaults] = true
          @list_template_settings[:checkbox][:list_selection] = {}
        end
      end
      scrub_list_params
      remember_list_params(key, user_settings)
    else
      scrub_list_params
    end
  end

  # Populates params that are passed when calling Study.get(:all, params)
  def populate_get_params(params, search_attributes)
    get_params = {}
    if params[:search_by]
      if params[:search_by_attribute] == 'all'
        get_params['q'] = search_attributes.map do |attr|
          "include(#{attr},#{params[:search_by]})"
        end.join(" OR ")
      else
        get_params['q'] = "include(#{params[:search_by_attribute]},#{params[:search_by]})"
      end
    end
    get_params[:sort_by] = params[:sort_by]
    get_params
  end

  private

  # Clears the old list selection if list is queried with new terms
  def clear_list_selections(key, user_settings)
    #@session_ = session[key] unless @session_ ;  This has to be done in this line if study_list (list with one key) is going to have checkboxes
    hsh = user_settings[key] || {}
    if params[:search_by] != hsh['search_by'] || params[:search_by_attribute] != hsh['search_by_attribute']
      @session_[key][:list_selection] = {}
    end
  end

  # If none of the list params are set in the request (except for context), get them from the cookies if they are there
  def get_list_params(key, user_settings)
    if ListPresenter::LIST_PARAMS.all? { |s| params[s].nil? }
      ListPresenter::LIST_PARAMS_WITH_CONTEXT.map{ |p| p.to_s }.each do |param|
        params[param] = user_settings[key][param] if user_settings[key][param] #TODO take care of other lists
      end
    end
  end

  # Save the list params to the session
  def remember_list_params(key, user_settings)
    user_settings[key] ||= {}
    ListPresenter::LIST_PARAMS_WITH_CONTEXT.each do |param|
      user_settings[key][param] = list_params[param]
    end
    update_user_cookie(current_user_uuid, user_settings)
  end
  
  # Ensure that list params are valid before using them in index action.
  def scrub_list_params
    list_params = {}
    list_params[:page] = params[:page] == nil || params[:page].try(:to_i) <= 0 ? 1 : params[:page].to_i
    list_params[:per_page] = params[:per_page].try(:to_i)
    unless PaginationPresenter::DEFAULT_PER_PAGE_CHOICES.include?(list_params[:per_page])
      list_params[:per_page] = PaginationPresenter::DEFAULT_PER_PAGE_CHOICES.min
    end
    if @list_template_settings
      if @list_template_settings[:filter]
        list_params[:filter_by] =
          if @list_template_settings[:filter].include?(params[:filter_by])
            params[:filter_by]
          else
            @list_template_settings[:filter_default]
          end
      end
      if @list_template_settings[:sort]
        list_params[:sort_by] = params[:sort_by] || @list_template_settings[:sort]
      end
      if @list_template_settings[:search] && @list_template_settings[:search] != :skip_pruning
        list_params[:search_by] = params[:search_by]
        list_params[:search_by_attribute] =
          if @list_template_settings[:search].values.include?(params[:search_by_attribute])
            params[:search_by_attribute]
          else
            'all'
          end
      end
    end
    list_params[:context] = params[:context]
    ListPresenter::LIST_PARAMS_WITH_CONTEXT.each do |param|
      params.delete(param)
    end
    @list_params = ActionController::Parameters.new(list_params)
  end
end
