# encoding : utf-8
module BeautifulHelper

  def visible_column(model_name, field_name, display_default = 'table-cell', other_css = "")
    return ('style="display:' + ((session[:fields][model_name.to_sym].to_a.include?(field_name))  ? display_default : 'none') + ';' + other_css + '"').html_safe
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

    cap = attribute_name
    cap = "number-attr" if attribute_name == "number"

    caption =   t(cap, :default => default_caption).capitalize
    strpath = model_name.pluralize + "_url"
    strpath = namespace + '_' + strpath if not namespace.blank?

    return link_to(
        "#{csort} #{caption}".html_safe,
        eval(strpath) + "?" +
            CGI.unescape({:sorting => {:attribute => attribute_name.downcase,:sorting => opposite_sortstr}}.to_query)
    ).html_safe
  end

  def ransack_field(path_of_model, attribute_name, f, caption = nil)
    model_path = path_of_model.split("/")
    model_name = model_path.last
    model_path.delete(model_path.first)
    model_name_for_ransack = model_path.join("_")

    ar_model = model_name.camelize.constantize

    default_caption = caption
    if default_caption.blank? then
      default_caption = attribute_name.capitalize
      if is_belongs_to_column?(default_caption) then
        default_caption = get_belongs_to_model(default_caption)
      end
    end

    name_field    = attribute_name
    name_field_bk = attribute_name
    label_field   = attribute_name

    if is_belongs_to_column?(name_field_bk) then
      label_field = get_belongs_to_model(attribute_name)
    end

    name_field = model_name_for_ransack + "_" + name_field unless model_name_for_ransack.blank?


    cap = label_field
    cap = "number-attr" if label_field == "number"

    response   = '<div class="control-group">'
    response += f.label name_field, t(cap, :default => default_caption).capitalize, :class => "control-label"
    response += '<div class="controls">'

    type_of_column = ar_model.columns_hash[attribute_name].type unless ar_model.columns_hash[attribute_name].nil?
    type_of_column ||= :other
    case type_of_column
      when :date, :datetime then
        dt = (type_of_column == :datetime)
        interval = (dt ? (1..5) : (1..3))

        # Greater than
        response += '<div class="input-prepend input-append input-' + type_of_column.to_s + '">'
        response += '<span class="add-on"><i class="icon-chevron-right"></i></span>'
        response += f.text_field(
            (name_field + "_dp_gt").to_sym,
            :value => (begin params[:q][(name_field + "_dp_gt").to_sym] rescue '' end),
            :class => "span9 dpicker",
            "data-id" => ("q_" + name_field + "_gteq"))
        response += '<span class="add-on"><i class="icon-calendar"></i></span>'
        response += '</div>'

        if dt then
          response += '<div class="input-prepend input-append input-' + type_of_column.to_s + '">'
          response += '<span class="add-on"><i class="icon-chevron-right"></i></span>'
          response += f.text_field(
              (name_field + "_tp_gt").to_sym,
              :value => (begin params[:q][(name_field + "_tp_gt").to_sym] rescue '' end),
              :class => "span9 tpicker",
              "data-id" => ("q_" + name_field + "_gteq"))
          response += '<span class="add-on"><i class="icon-time"></i></span>'
          response += '</div>'
        end

        for i in interval
          response += f.hidden_field(name_field + "_gteq(#{i}i)",
                                     :value => (begin params[:q][(name_field + "_gteq(#{i}i)").to_sym] rescue '' end),
                                     :id => ('q_' + name_field + "_gteq_#{i}i"))
        end

        # Less than
        response += '<div class="input-prepend input-append input-' + type_of_column.to_s + '">'
        response += '<span class="add-on"><i class="icon-chevron-left"></i></span>'
        response += f.text_field(
            (name_field + "_dp_lt").to_sym,
            :value => (begin params[:q][(name_field + "_dp_lt").to_sym] rescue '' end),
            :class => "span9 dpicker",
            "data-id" => ("q_" + name_field + "_lteq"))
        response += '<span class="add-on"><i class="icon-calendar"></i></span>'
        response += '</div>'

        if dt then
          response += '<div class="input-prepend input-append input-' + type_of_column.to_s + '">'
          response += '<span class="add-on"><i class="icon-chevron-left"></i></span>'
          response += f.text_field(
              (name_field + "_tp_lt").to_sym,
              :value => (begin params[:q][(name_field + "_tp_lt").to_sym] rescue '' end),
              :class => "span9 tpicker",
              "data-id" => ("q_" + name_field + "_lteq"))
          response += '<span class="add-on"><i class="icon-time"></i></span>'
          response += '</div>'
        end

        for i in interval
          response += f.hidden_field(name_field + "_lteq(#{i}i)",
                                     :value => (begin params[:q][(name_field + "_lteq(#{i}i)").to_sym] rescue '' end),
                                     :id => ('q_' + name_field + "_lteq_#{i}i"))
        end
      when :boolean then
        # Specify a default value (false) in rails migration
        response += f.label name_field + "_eq_true",   raw(f.radio_button((name_field + "_eq").to_sym, true))   + " " + h(t(:yes, :default => "Yes")), :class => "checkbox inline"
        response += f.label name_field + "_eq_false",  raw(f.radio_button((name_field + "_eq").to_sym, false))  + " " + h(t(:no, :default => "No")),   :class => "checkbox inline"
        response += f.label name_field + "_eq",        raw(f.radio_button((name_field + "_eq").to_sym, nil))    + " " + h(t(:all, :default => "All")), :class => "checkbox inline"
      when :string then
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter span12")
      when :integer, :float, :decimal then
        if is_belongs_to_column?(name_field_bk) then
          btmodel = get_belongs_to_model(name_field_bk).camelize.constantize
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

  def build_treeview(obj, child_relation, caption_method = "caption")
    out = '
      <li id="treeelt_' + obj.id.to_s + '" data-id="' + obj.id.to_s + '">
        <a href="#" class="nopjax">' + obj.send(caption_method).to_s + '</a>
        <ul>'
    ar = obj.send(child_relation.to_sym)
    ar = ar.order('position') if obj.class.column_names.include?("position")
    for o in ar.all
      out += build_treeview(o, child_relation, caption_method)
    end
    out += '
        </ul>
      </li>'
    return out.html_safe
  end

  def clean_params
    params.delete :q
    params.delete :fields
  end
end
