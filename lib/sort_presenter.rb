# This class presenters opinionated sort controls for a platform list.
class SortPresenter < ListPresenter

  def initialize(params, template, options = {})
    @remote = options[:remote]
    super(params, template)
  end

  # Make a link which'll sort the list by the given attribute.
  # +body+ is the body of the sort link
  # +sort_by_attribute+ is the code-facing name of the attribute by which to sort
  def sort_by_link(body, sort_by_attribute, html_options = {}, params_options = {})
    raise(ArgumentError, 'body must not be nil.') if body.nil?
    raise(ArgumentError, 'sort_by_attribute must not be blank.') if sort_by_attribute.blank?
    raise(ArgumentError, '@params[:sort_by] must not be nil.') if @params[:sort_by].nil?
    
    html_options.stringify_keys!
    sort_by_attribute = sort_by_attribute.to_s
    
    sort_dir = 'ASC' # ascending is the default sort direction
    
    # Do certain things if sort_by_attribute is the current sort
    current_sort_attr, current_sort_direction = @params[:sort_by].split(',')
    selected = false
    if current_sort_attr.strip == sort_by_attribute
      selected = true
      sort_dir = 'DESC' if current_sort_direction.blank? || current_sort_direction.strip == 'ASC'
    end
    
    html_options['class'] ||= []
    html_options['class'] << 'sort-link'
    html_options['class'] << 'selected' if selected
    sort_by_value = "#{sort_by_attribute},#{sort_dir}"
    icon_classes = ''
    icon_classes << (sort_dir == 'DESC' ? 'fa fa-sort-asc' : 'fa fa-sort-desc') if selected
    href = url_for_params(@params.merge(sort_by: sort_by_value, page: 1), params_options)
    href = "#{request.path}#{href}"
    html_options[:remote] = @remote
    link_to((body << content_tag(:i, nil, class: icon_classes)).html_safe, href, html_options)
  end
end
