# encoding : utf-8
module BeautifulHelper
  
  def sorting_header(model_name, attribute_name, namespace)
    attr    = nil
    sort    = nil
    
    if not params[:sorting].blank? then
      attr = params[:sorting][:attribute]
      sort = params[:sorting][:sorting]
    end
    
    attr    = attr.to_s.downcase
    sortstr = sort.to_s.downcase
    opposite_sortstr = ""
    csort = "▪"
    if attribute_name == attr then
      if sortstr == "asc" then
        csort = "▲"
        opposite_sortstr = "desc"
      elsif sortstr == "desc" then
        csort = "▼"
        opposite_sortstr = "asc"
      end
    else
      opposite_sortstr = "asc"
    end
    
    default_caption = attribute_name.capitalize
    if is_belongs_to_column?(default_caption) then
      default_caption = get_belongs_to_model(default_caption)
    end
    
    caption =   t(attribute_name, :default => default_caption)
    return link_to(
        "#{csort} #{caption}",
        eval(namespace + '_' + model_name.pluralize + "_url") + "?" + 
        CGI.unescape({:sorting => {:attribute => attribute_name.downcase,:sorting => opposite_sortstr}}.to_query)
      ).html_safe
  end
  
  def ransack_field(model_name, attribute_name, f, caption = nil)
    ar_model = model_name.classify.constantize
    
    default_caption = caption
    if default_caption.blank? then
      default_caption = attribute_name.capitalize
      if is_belongs_to_column?(default_caption) then
        default_caption = get_belongs_to_model(default_caption)
      end
    end
    
    name_field = attribute_name
    response   = '<div class="ransack-filter-field">'
    
    response += f.label name_field, t(attribute_name, :default => default_caption)  
    
    type_of_column = ar_model.columns_hash[attribute_name].type unless ar_model.columns_hash[attribute_name].nil? 
    type_of_column ||= :other
    case type_of_column
      when :date then
        # DatePicker
        response += f.date_select((name_field + "_gteq").to_sym)
        response += f.date_select((name_field + "_lteq").to_sym)
      when :datetime then
        # DateTime Picker
        response += f.date_select((name_field + "_gteq").to_sym)
        response += f.date_select((name_field + "_lteq").to_sym)
      when :boolean then
        # Specify a default value (false) in rails migration
        response += f.label name_field + "_eq_true",   raw(f.radio_button((name_field + "_eq").to_sym, true))   + h(t(:yes, :default => "Yes"))
        response += f.label name_field + "_eq_false",  raw(f.radio_button((name_field + "_eq").to_sym, false))  + h(t(:no, :default => "No")) 
        response += f.label name_field + "_eq",        raw(f.radio_button((name_field + "_eq").to_sym, nil))    + h(t(:all, :default => "All")) 
      when :string then
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter")
      when :integer then
        if is_belongs_to_column?(name_field) then 
          btmodel = get_belongs_to_model(name_field).classify.constantize
          response += f.collection_select((name_field + "_eq").to_sym, btmodel.all, :id, :caption, { :include_blank => t(:all, :default => "All") })
        elsif name_field == "id" then
          response += f.text_field((name_field + "_eq").to_sym, :class => "filter")
        else
          response += f.text_field((name_field + "_gteq").to_sym, :class => "#{align_attribute("integer")} filter-min")
          response += f.text_field((name_field + "_lteq").to_sym, :class => "#{align_attribute("integer")} filter-max")
        end
      when :float then
        response += f.text_field((name_field + "_gteq").to_sym, :class => "#{align_attribute("integer")} filter-min")
        response += f.text_field((name_field + "_lteq").to_sym, :class => "#{align_attribute("integer")} filter-max")
      else
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter")
    end
    
    response += "</div>"
    
    return response.html_safe
  end
  
  def align_attribute(attribute_type)
    return case attribute_type
      when "string" then
        "al"
      when "integer", "float", "numeric" then
        "ar"
      when "boolean" then
        "ac"
      when "date", "datetime", "timestamp" then
        "ac"
      else
        "al"
    end
  end

  def exclude_richtext_field(array_of_attributes, only_fulltext = true)
    pattern = /$()_fulltext/
    richtext_attributes = []
    array_of_attributes.each{ |a| 
      richtext_attributes << a[pattern] if a[pattern]
    }
    array_of_attributes.reject!{ |a| richtext_attributes.include?(a) or richtext_attributes.include?(a + "_typetext") }
    return array_of_attributes
  end
  
  def is_belongs_to_column?(column)
    return true if column[-3,3] == "_id"
  end
  
  def get_belongs_to_model(column)
    return column[0..-4]
  end
end
