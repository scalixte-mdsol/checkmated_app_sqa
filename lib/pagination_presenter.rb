# This class presenters opinionated pagination controls for a platform list.
class PaginationPresenter < ListPresenter
  DEFAULT_PER_PAGE_CHOICES = [10, 25, 50, 100]
    
  # Create a new PaginationPresenter.
  # See ListPresenter for description of +params+ and +template+ args.
  # options: "total_in_list" the total number of items in the rendered list when pagination is not taken into account.
  # options: "remote" boolean if true, generated pagination links/text box/per-page buttons are all ajax enabled.
  # options: "per_page_choices" is an array of per page values (e.g. [10, 25, 50, 100])
  def initialize(params, template, options = {})
    raise(ArgumentError, "params[:page] must be present to paginate!") unless params[:page]
    raise(ArgumentError, "params[:per_page] must be present to paginate!") unless params[:per_page]
    @remote = options[:remote]
    @total_items_in_list = options[:total_in_list] || 0
    @per_page_choices = options[:per_page_choices] || DEFAULT_PER_PAGE_CHOICES
    super(params, template)
  end
  
  def total_pages
    @total_pages ||= (@total_items_in_list.to_f / @params[:per_page].to_i).ceil
  end

  def pagination_tags
    return '' if @total_items_in_list == 0
    content = content_tag(:div, t('pagination.total_results_html', count: @total_items_in_list), class: 'total-results')
    content << per_page_section if @total_items_in_list > @per_page_choices.min
    content << pagination_controls if total_pages > 1

    content_tag(:div, content, class: %w(paginate clearfix))
  end

  protected
    
  # Markup for per page selections
  def per_page_section
    
    # get the selected per_page
    selected_per_page = begin
      if @params[:per_page] && @per_page_choices.include?(@params[:per_page].to_i)
        @params[:per_page].to_i
      else
        @per_page_choices.min
      end
    end
    
    # render the section
    content_tag(:div, nil, class: %(per-page)) do
      content_tag(:span) do
        I18n.t("pagination.per_page")
      end <<
      content_tag(:ul) do
        @per_page_choices.map do |pp_choice|
          per_page_link(pp_choice, selected_per_page)
        end.join.html_safe
      end
    end
  end
  
  # Make individual per_page link
  # +params+ is a hash of params in place right now.
  def per_page_link(per_page_value, selected_per_page)
    id = "per-page-#{per_page_value}"
    klasses = per_page_value == selected_per_page ? %w(selected disabled) : []
    content_tag(:li) do
      href = url_for_params(@params.merge(per_page: per_page_value, page: 1))
      link_to("#{request.path}#{href}", id: id, class: klasses, remote: @remote) do
        I18n.t("pagination.#{id.gsub('-','_')}")
      end
    end
  end
  
  # Make pagination controls (first, previous, page num. input box, next, last)
  def pagination_controls
    raise(ArgumentError, "params[:page] must be set!") unless @params[:page]
    
    current_page = @params[:page].to_i
    
    content_tag(:ul, nil, class: %w(controls)) do
      ctrls = %w(first previous).map do |pc|
        pagination_link(pc, current_page)
      end <<
      [pagination_counter] <<
      %w(next last).map do |pc|
        pagination_link(pc, current_page)
      end
      
      ctrls.join.html_safe
    end
  end
  
  # +control_name+ is one of 'first', 'previous', 'next' or 'last'
  # +current_page+ the current page of the list the user is viewing
  def pagination_link(control_name, current_page)
    # Determine which page this link should take us to, and determine the icon for this link
    go_to_page, icon_class = case control_name
    when 'first'
      [1, 'fa-angle-double-left']
    when 'previous'
      [current_page - 1 > 0 ? current_page - 1 : 1, 'fa-angle-left']
    when 'next'
      [current_page + 1 < total_pages ? current_page + 1 : total_pages, 'fa-angle-right']
    when 'last'
      [total_pages, 'fa-angle-double-right']
    else
      raise(ArgumentError, "don't recognize control_name #{control_name}")
    end
    href = url_for_params(@params.merge(:page => go_to_page))
    icon_classes = ['fa', icon_class]
    
    # Determine whether this link is disabled or not
    klasses = begin
      if %w(first previous).include?(control_name) && current_page <= 1
        %w(disabled)
      elsif %w(next last).include?(control_name) && current_page >= total_pages
        %w(disabled)
      else
        []
      end
    end
    klasses << control_name
    
    # Render the link
    content_tag(:li) do
      icon = "#{content_tag(:i, nil, class: icon_classes)}#{control_name}".html_safe
      link_to(icon, "#{request.path}#{href}", class: klasses, remote: @remote)
    end
  end
    
  # Generates html to display the page text-input and the total number of pages
  def pagination_counter
    current_page = @params[:page].to_i
    text_field_classes = %w(current-page validPageNumber)
    text_field_disabled = total_pages == 1
    
    content_tag(:li, class: 'counter') do
      form_tag(request.path, remote: @remote, method: :get, id: 'page-form') do
        hidden_fields_for_params(@params, {'except' => %w(page)}) <<
        text_field_tag(:page, current_page,
          disabled: text_field_disabled,
          autocomplete: 'off',
          size: total_pages.to_s.length,
          maxlength: total_pages.to_s.length,
          id: 'current-page',
          class: text_field_classes) <<
        " #{I18n.t('pagination.of')} " <<
        content_tag(:span, total_pages, class: 'total-pages', id: 'total-pages')
      end
    end
  end
       
end
