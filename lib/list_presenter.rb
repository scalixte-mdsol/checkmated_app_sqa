# Base class for pagination, sort, search and filter presenters.
class ListPresenter
  LIST_PARAMS = [:per_page, :page, :filter_by, :search_by, :search_by_attribute, :sort_by]
  LIST_PARAMS_WITH_CONTEXT = LIST_PARAMS + [:context]
  
  # Create a new ListPresenter.
  # +params+ are the request params sent by the user-agent making the request.  These should include :page and
  # :per_page values.
  # +template+ is the template rendering the list in which pagination controls are to be place.
  # +context+ a list of request parameter keys, which are unrelated to the list settings, that are
  # retained when using a list presenter
  def initialize(params, template)
    @params = params.symbolize_keys
    @template = template
  end
  
  protected
  
  # have the template invoke a method in a presenter if the presenter does not recognize the method
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
  
  # Make a url which includes selected elements from params hash in query string
  # so that all existing list-related params (for searching, filtering, pagination, etc.) are
  # passed with a given request
  # + options + can contain an 'only' key or an 'except' key, each of which takes an array of 
  # attributes to use (solely) or remove, respectively.
  def url_for_params(params, options = {})
    # TODO remove this line if/when grandmaster handles all links
    params.merge!(grandmaster_query_params) if @template.respond_to?(:grandmaster_query_params)
    params_to_use = params_to_use(options)
    uri = Addressable::URI.new
    uri.query_values = params.slice(*params_to_use)
    uri.to_s
  end

  # Make hidden form fields which include selected elements from params hash in query string
  # so that all existing list-related params (for searching, filtering, pagination, etc.) are
  # passed with a given form submission.
  # + options + can contain an 'only' key or an 'except' key, each of which takes an array of 
  # attributes to use (solely) or remove, respectively.
  def hidden_fields_for_params(params, options = {})
    # TODO remove this line if/when grandmaster handles all links
    params.merge!(grandmaster_query_params) if @template.respond_to?(:grandmaster_query_params)

    params_to_use = params_to_use(options)
    params_to_use.map do |lp|
      hidden_field_tag(lp, params[lp], id: nil) if params[lp]
    end.compact.join.html_safe
  end
  
  # Gather list of param keys to use based on options.
  def params_to_use(options)
    # TODO remove + [:c_selections] if/when grandmaster handles all links
    params_to_use = LIST_PARAMS_WITH_CONTEXT + [:c_selections]
    if options
      params_to_use -= options['except'].map(&:to_sym) if options['except']
      params_to_use = options['only'].map(&:to_sym) if options['only']
    end
    params_to_use += @params[:context].split(',').map(&:to_sym) if @params[:context]

    params_to_use
  end
  
  # Make the commonly used clearfix div
  def clearfix
    content_tag(:div, nil, class: 'clearfix')
  end
  
end
