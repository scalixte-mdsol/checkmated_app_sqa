class ListCheckboxPresenter < ListPresenter
  
  attr_accessor :list, :selection_list

  def initialize(list, settings, template)
    @list = list || []
    @selection_list = settings[:list_selection] || {}
    @list_source = settings[:revalidation]
    @template = template
    @summary_panel = settings[:summary_panel]
    refresh if @list_source
  end 
  
  # Returns a hash that contains attributes necessary to create/delete a list_selection entry
  def attributes_for_selection_list_url
    {
      :'data-primary-key' => @template.instance_variable_get("@primary_key"),
      :'data-secondary-key' => @template.instance_variable_get("@secondary_key"),
      :'data-chkbx-url' => list_item_selection_path
    }
  end

  # Returns the number of individual item checkboxes that are checked in the list
  def selected_items_count
    return 0 if selection_list.empty?
    if selection_list[:unselect]
      total_count - selection_list[:unselect].count
    else
      selection_list[:select].count
    end
  end
  
  def refresh
    key = selection_list.keys.first 
    if key && selection_list[key].present? && @list_source.is_a?(Proc)
      valid_items = @list_source.call(selection_list[key].to_a)
      selection_list[key].replace(Set.new(valid_items))
    end
  end
  
  # total items in the list
  def total_count
    @list_total_count ||= list.respond_to?(:total_count) ? list.total_count : list.size
  end
  
  # Renders the selected items in the following format (in html), "0 of 200 selected"
  def selection_summary_panel
    if @summary_panel
      render '/selection_summary_panel', selected: selected_items_count.to_s, total_count: total_count.to_s
    end
  end

  # Renders the All checkbox for a checkbox list
  def all_checkbox
    options = {id: 'all', name: 'all', type: 'checkbox'}
    options[:checked] = :checked if selection_list && selection_list[:unselect] && selection_list[:unselect].length == 0
    options[:disabled] = total_count == 0
    content_tag(:input, nil, options)
  end

  # Renders checkbox based on session information of the list items
  def render_checkbox(item, disabled = false)
    item_id = get_id(item)
    if selection_list[:unselect]
      checked = !selection_list[:unselect].include?(item_id)
    elsif selection_list[:select]
      checked = selection_list[:select].include?(item_id)
    end
    content_tag(:input, nil, type: 'checkbox', checked: checked, name: item_id, id: item_id, disabled: disabled)
  end
end
