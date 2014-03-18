# This class presenters opinionated search controls for a platform list.
class SearchPresenter < ListPresenter
  
  # Create a new SearchPresenter.
  # See ListPresenter for description of +params+ and +template+ args.
  # +search_info+ hash of attributes list can be searched on
  # +filter_info+ array of hashes containing the filters this list subscribed to
  # +total_items_in_list+ is the total number of items in the rendered list when pagination is not taken into account.
  def initialize(params, template, options = {})
    @search_info = options[:search_info]
    @total_items_in_list = options[:total_items_in_list] || 0
    @total_items_in_existence = options[:total_items_in_existence] || 0
    @remote = options[:remote]
    @form_path = options[:form_path] || ''
    raise "Cannot have more items in the list than items in existence" if @total_items_in_list > @total_items_in_existence
    super(params, template)
  end
  
  # Show search results in a nice colored bar.
  def search_results
    search_by = @params[:search_by]
    if search_by
      content_tag(:div, class: "#{:alert} clearfix", id: "search-results") do
        content_tag(:span, class: '') do
          t('search.search_results', search_by: content_tag(:b, search_by), count: @total_items_in_list).html_safe
        end <<
        "&nbsp;".html_safe <<
        content_tag(:span) do
          href = url_for_params(@params, 'except' => %w(search_by search_by_attribute page))
          href = "#{request.path}#{href}" if @remote
          link_to t('search.clear_search').html_safe, href, id: 'clear-search', remote: @remote
        end <<
        clearfix
      end
    else
      ""
    end
  end

  # Make new search tags
  def search_tags(options = {})
    options = options.with_indifferent_access
    placeholder_text = options[:placeholder_text] || ""
    tooltip_text = if options[:tooltip_text]
      t(options[:tooltip_text] + (@params[:search_by_attribute] || "all"))
    end
    search_by_attribute = @params[:search_by_attribute] || @search_info.values.first
    search_by = @params[:search_by]
    
    disable_submit = search_by.blank?
    submit_button_classes = %w(btn btn-default submit)
    submit_button_classes << 'disabled' if disable_submit
    text_input_disabled = @total_items_in_existence == 0
    form_options = {method: 'get', id: 'search-list-form'}
    form_options.merge!(data: {remote: true}) if @remote
    form_tag(@form_path, form_options) do
      hidden_fields_for_params(@params.merge(page: 1), 'except' => %w(search_by search_by_attribute)) <<
      hidden_fields_for_params(search_by_attribute: search_by_attribute) <<
      content_tag(:div, nil, class: 'input-group') do
        content_tag(:div, nil, class: 'input-group-btn', id: 'search-by-attribute') do
          content_tag(:button, nil, class: 'btn btn-default dropdown-toggle', name: 'search_by_attribute', data: {toggle: 'dropdown'}) do
            "#{@search_info.invert[search_by_attribute]} ".html_safe << caret_icon
          end <<
          content_tag(:ul, class: 'dropdown-menu' ) do
            @search_info.map do |attribute_name, attribute_value|
              content_tag(:li) do
                link_to(attribute_name, '#', data: {value: attribute_value})
              end
            end.join.html_safe
          end
        end <<
        text_field_tag(:search_by, search_by, {
          disabled: text_input_disabled,
          maxlength: 255,
          placeholder: placeholder_text,
          title: tooltip_text,
          autofocus: "autofocus",
          "data-tooltip-key" => options[:tooltip_text],
          class: 'form-control'
        }) <<
        content_tag(:div, class: 'input-group-btn') do
          button_tag(nil, {class: submit_button_classes, type: 'submit', id: 'search-list-submit', disabled: disable_submit}) do
            content_tag(:i, nil, class: 'glyphicon glyphicon-search')
          end
        end
      end
    end.html_safe
  end
  
  # Highlights the matching text of an attributes value if the attribute is one among the search attribute list
  def highlight_matched_column_value(value, attr, max_length, options)
    return '' if value.nil?
    tooltip = value unless options[:no_tooltip_text]
    content_tag(:span, title: tooltip) do
      value = value.truncate(max_length)
      if @params[:search_by] && [:all, attr.to_sym].include?(@params[:search_by_attribute].to_sym)
        highlight_matching_text(value)
      else
        value
      end
    end
  end

  # Highlights the part of the string matching the search term
  def highlight_matching_text(text)
    highlighter = '<span class="search-result"><span class="highlighted">\1</span></span>'
    highlight(text, @params[:search_by], highlighter: highlighter)
  end
end
