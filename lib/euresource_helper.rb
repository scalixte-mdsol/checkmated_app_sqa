# module to get all roles, and store them in an instance variable for the current request
module EuresourceHelper

  # Loop through all pages of a resource, and return all of them
  # TODO: move this to Eureka client.
  def get_all(resource_name, params = {})
    query_params = {params: params}
    page = 1
    total_resources = Euresource.class_for_resource(resource_name).get(:all, query_params).page(1)
    # TODO: fix eureka_tools to properly respond to include_count.
    while true
      page += 1
      resources = Euresource.class_for_resource(resource_name).get(:all, query_params).page(page)
      if resources.empty?
        return total_resources
      end
      total_resources.concat(resources)
    end
  end

  # Safely fetches a resource, catching any Errors and returning an empty array on failure.
  # Also logs the error and sets the @error instance variable to the exception if one is raised by the call.
  def safe_fetch(resource_name, scope_or_id, options = {})
    begin
      "Euresource::#{resource_name}".constantize.get(scope_or_id, options).load
    rescue => e
      @error = e
      error_msg = "Error fetching #{resource_name} with parameters (#{scope_or_id}, #{options}): "
      error_msg << "#{e.class.name}: #{e.message}"
      Rails.logger.error(error_msg)
      scope_or_id == :all ? [] : nil
    end
  end
end
