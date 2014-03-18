# This class presenters opinionated filter controls for a platform list.
class FilterPresenter < ListPresenter
  FILTER_TYPES = [:btn_group, :btn_dropdowns]

  # Create a new FilterPresenter.
  # See ListPresenter for description of +params+ and +template+ args.
  # +filter_info+ array of hashes containing the filters this list subscribed to
  # +filter_type+ type of filter (btn)group or btn_dropdowns)
  def initialize(params, template, filter_info, filter_type)
    raise(ArgumentError, "invalid filter_type: #{filter_type}") if filter_type && !FILTER_TYPES.include?(filter_type)
    @filter_info = filter_info
    @filter_type = filter_type
    super(params, template)
  end

  def filter_tags(filter_location = :inner, params_options = nil)
    case @filter_type
    when :btn_group then filter_btn_group(filter_location, params_options)
    end
  end

  def filter_btn_group(filter_location = :inner, params_options = nil)
    filter_info = @filter_info.try(:[], filter_location) || {}
    location_class = filter_location == :outer ? 'btn-group-justified' : ''
    content_tag(:div, class: 'filter-group') do
      content_tag(:div, class: "btn-group #{location_class}") do
        filter_info.map do |filter_info_hash|
          filter_info = filter_info_hash.with_indifferent_access
          filter_icon = filter_info[:filter_icon].try(:downcase)
          href = url_for_params(@params.merge(filter_by: filter_info[:filter_value], page: 1), params_options)
          klasses = %w(btn btn-default)
          klasses += %w(disabled) if filter_info[:filter_count].try(:to_i) == 0
          klasses += %w(btn-inverse disabled selected) if @params[:filter_by] == filter_info[:filter_value]

          body = ''
          body << content_tag(:i, nil, class: "mcc-icon-#{filter_icon}") unless filter_icon == 'all' || filter_info[:no_icon]
          body << " #{filter_info[:filter_label]}"
          body << " (#{filter_info[:filter_count].to_i})" if filter_info[:filter_count]
          id = "#{(filter_info[:filter_id] || filter_info[:filter_value]).downcase.gsub(' ', '-')}-filter".downcase
          link_to(body.html_safe, href, id: id, class: klasses)
        end.join.html_safe
      end
    end
  end
end
