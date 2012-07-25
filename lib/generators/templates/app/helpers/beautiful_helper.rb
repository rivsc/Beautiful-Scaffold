# encoding : utf-8
module BeautifulHelper

  def visible_column(model_name, field_name)
    return ('style="display:' + ((session[:fields][model_name.to_sym].to_a.include?(field_name))  ? 'table-cell' : 'none') + ';"').html_safe
  end

  def dropdown_submenu(link_caption, &block)
    the_link = link_to((link_caption + ' <b class="caret"></b>').html_safe, "#", :class => "dropdown-toggle", "data-toggle" => "dropdown")
    contents = (block_given?) ? content_tag_string(:ul, capture(&block), :class => "dropdown-menu") : ''
    content_tag_string :li, the_link + contents, :class => "dropdown"
  end

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
    csort = '' # <i class="icon-stop"></i>
    if attribute_name == attr then
      if sortstr == "asc" then
        csort = '<i class="icon-chevron-up"></i>'
        opposite_sortstr = "desc"
      elsif sortstr == "desc" then
        csort = '<i class="icon-chevron-down"></i>'
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
    strpath = model_name.pluralize + "_url"
    strpath = namespace + '_' + strpath if not namespace.blank?

    return link_to(
        "#{csort} #{caption}".html_safe,
        eval(strpath) + "?" +
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
    response   = '<div class="control-group">'
    response += f.label name_field, t(attribute_name, :default => default_caption), :class => "control-label"
    response += '<div class="controls">'


    type_of_column = ar_model.columns_hash[attribute_name].type unless ar_model.columns_hash[attribute_name].nil?
    type_of_column ||= :other
    case type_of_column
      when :date, :datetime then
        # DatePicker
        response += '<div class="input-prepend input-append">'
        response += '<span class="add-on"><i class="icon-chevron-right"></i></span>'
        response += f.date_select((name_field + "_gteq").to_sym)
        response += '<span class="add-on"><i class="icon-calendar"></i></span>'
        response += '</div>'
        response += '<div class="input-prepend input-append">'
        response += '<span class="add-on"><i class="icon-chevron-left"></i></span>'
        response += f.date_select((name_field + "_lteq").to_sym)
        response += '<span class="add-on"><i class="icon-calendar"></i></span>'
        response += '</div>'
      when :boolean then
        # Specify a default value (false) in rails migration
        response += f.label name_field + "_eq_true",   raw(f.radio_button((name_field + "_eq").to_sym, true))   + " " + h(t(:yes, :default => "Yes")), :class => "checkbox inline"
        response += f.label name_field + "_eq_false",  raw(f.radio_button((name_field + "_eq").to_sym, false))  + " " + h(t(:no, :default => "No")),   :class => "checkbox inline"
        response += f.label name_field + "_eq",        raw(f.radio_button((name_field + "_eq").to_sym, nil))    + " " + h(t(:all, :default => "All")), :class => "checkbox inline"
      when :string then
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter span12")
      when :integer, :float then
        if is_belongs_to_column?(name_field) then
          btmodel = get_belongs_to_model(name_field).classify.constantize
          response += f.collection_select((name_field + "_eq").to_sym, btmodel.all, :id, :caption, { :include_blank => t(:all, :default => "All") }, { :class => "span12" })
        elsif name_field == "id" then
          response += f.text_field((name_field + "_eq").to_sym, :class => "filter span12")
        else
          response += '<div class="input-prepend">'
          response += '<span class="add-on" rel="tooltip" title="' + t(:greater_than, :default => "Greater than") + '"><i class="icon-chevron-right"></i></span>'
          response += f.text_field((name_field + "_gteq").to_sym, :class => "#{align_attribute("integer")} filter-min span10")
          response += '</div>'
          response += '<div class="input-prepend">'
          response += '<span class="add-on" rel="tooltip" title="' + t(:smaller_than, :default => "Smaller than") + '"><i class="icon-chevron-left"></i></span>'
          response += f.text_field((name_field + "_lteq").to_sym, :class => "#{align_attribute("integer")} filter-max span10")
          response += '</div>'
        end
      else
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter span12")
    end

    response += "</div>"
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
