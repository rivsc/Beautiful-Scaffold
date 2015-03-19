# encoding : utf-8
module BeautifulHelper

  def visible_column(model_name, field_name, display_default = 'table-cell', other_css = "")
    return ('style="display:' + ((session[:fields][model_name].to_a.include?(field_name))  ? display_default : 'none') + ';' + other_css + '"').html_safe
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
    csort = '' # <i class="fa fa-stop"></i>
    if attribute_name == attr then
      if sortstr == "asc" then
        csort = '<i class="fa fa-chevron-up"></i>'
        opposite_sortstr = "desc"
      elsif sortstr == "desc" then
        csort = '<i class="fa fa-chevron-down"></i>'
        opposite_sortstr = "asc"
      end
    else
      opposite_sortstr = "asc"
    end

    default_caption = attribute_name.capitalize
    if is_belongs_to_column?(default_caption) then
      default_caption = get_belongs_to_model(default_caption)
    end

    cap = i18n_translate_path(model_name, attribute_name)

    caption = t(cap, :default => default_caption).capitalize
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

    cap = i18n_translate_path(model_name, attribute_name)

    infostr   = ''
    response  = '' # See at end
    response += f.label name_field, t(cap, :default => default_caption).capitalize, :class => "control-label"

    type_of_column = ar_model.columns_hash[attribute_name].type unless ar_model.columns_hash[attribute_name].nil?
    type_of_column ||= :other
    case type_of_column
      when :date, :datetime then
        dt = (type_of_column == :datetime)
        interval = (dt ? (1..5) : (1..3))

        # Greater than
        response += '<div class="input-group input-' + type_of_column.to_s + '">'
        response += '<span class="input-group-addon"><i class="fa fa-chevron-right"></i></span>'
        response += f.text_field(
            (name_field + "_dp_gt").to_sym,
            :value => (begin params[:q][(name_field + "_dp_gt").to_sym] rescue '' end),
            :class => "col-md-9 dpicker form-control",
            "data-id" => ("q_" + name_field + "_gteq"))
        response += '<span class="input-group-addon"><i class="fa fa-calendar"></i></span>'
        response += '</div>'

        if dt then
          response += '<div class="input-group input-' + type_of_column.to_s + '">'
          response += '<span class="input-group-addon"><i class="fa fa-chevron-right"></i></span>'
          response += f.text_field(
              (name_field + "_tp_gt").to_sym,
              :value => (begin params[:q][(name_field + "_tp_gt").to_sym] rescue '' end),
              :class => "col-md-9 tpicker form-control",
              "data-id" => ("q_" + name_field + "_gteq"))
          response += '<span class="input-group-addon"><i class="fa fa-clock-o"></i></span>'
          response += '</div>'
        end

        for i in interval
          response += f.hidden_field(name_field + "_gteq(#{i}i)",
                                     :value => (begin params[:q][(name_field + "_gteq(#{i}i)").to_sym] rescue '' end),
                                     :id => ('q_' + name_field + "_gteq_#{i}i"))
        end

        # Less than
        response += '<div class="input-group input-' + type_of_column.to_s + '">'
        response += '<span class="input-group-addon"><i class="fa fa-chevron-left"></i></span>'
        response += f.text_field(
            (name_field + "_dp_lt").to_sym,
            :value => (begin params[:q][(name_field + "_dp_lt").to_sym] rescue '' end),
            :class => "col-md-9 dpicker form-control",
            "data-id" => ("q_" + name_field + "_lteq"))
        response += '<span class="input-group-addon"><i class="fa fa-calendar"></i></span>'
        response += '</div>'

        if dt then
          response += '<div class="input-group input-' + type_of_column.to_s + '">'
          response += '<span class="input-group-addon"><i class="fa fa-chevron-left"></i></span>'
          response += f.text_field(
              (name_field + "_tp_lt").to_sym,
              :value => (begin params[:q][(name_field + "_tp_lt").to_sym] rescue '' end),
              :class => "col-md-9 tpicker form-control",
              "data-id" => ("q_" + name_field + "_lteq"))
          response += '<span class="input-group-addon"><i class="fa fa-clock-o"></i></span>'
          response += '</div>'
        end

        for i in interval
          response += f.hidden_field(name_field + "_lteq(#{i}i)",
                                     :value => (begin params[:q][(name_field + "_lteq(#{i}i)").to_sym] rescue '' end),
                                     :id => ('q_' + name_field + "_lteq_#{i}i"))
        end

        infostr = info_input(model_name, [(name_field + "_dp_lt").to_sym, (name_field + "_tp_lt").to_sym, (name_field + "_dp_gt").to_sym, (name_field + "_tp_gt").to_sym])
      when :boolean then
        # Specify a default value (false) in rails migration
        response += f.label name_field + "_eq_true",   raw(f.radio_button((name_field + "_eq").to_sym, true))   + " " + h(t(:yes, :default => "Yes")), :class => "checkbox inline"
        response += f.label name_field + "_eq_false",  raw(f.radio_button((name_field + "_eq").to_sym, false))  + " " + h(t(:no, :default => "No")),   :class => "checkbox inline"
        response += f.label name_field + "_eq",        raw(f.radio_button((name_field + "_eq").to_sym, nil))    + " " + h(t(:all, :default => "All")), :class => "checkbox inline"

        infostr = (begin session[:search][model_name.to_sym][(name_field + "_eq").to_sym] == "on" ? "" : "info" rescue "" end)
      when :string then
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter col-md-12 form-control")

        infostr = info_input(model_name, (name_field + "_cont").to_sym)
      when :integer, :float, :decimal then
        if is_belongs_to_column?(name_field_bk) then
          btmodel = get_belongs_to_model(name_field_bk).camelize.constantize
          response += f.collection_select((name_field + "_eq").to_sym, btmodel.all, :id, :caption, { :include_blank => t(:all, :default => "All") }, { :class => "col-md-12 form-control" })

          infostr = info_input(model_name, (name_field + "_eq").to_sym)
        elsif name_field == "id" then
          response += f.text_field((name_field + "_eq").to_sym, :class => "filter col-md-12 form-control")

          infostr = info_input(model_name, (name_field + "_eq").to_sym)
        else
          response += '<div class="input-group">'
          response += '<span class="input-group-addon" rel="tooltip" title="' + t(:greater_than, :default => "Greater than") + '"><i class="fa fa-chevron-right"></i></span>'
          response += f.text_field((name_field + "_gteq").to_sym, :class => "#{align_attribute("integer")} filter-min col-md-10 form-control")
          response += '</div>'
          response += '<div class="input-group">'
          response += '<span class="input-group-addon" rel="tooltip" title="' + t(:smaller_than, :default => "Smaller than") + '"><i class="fa fa-chevron-left"></i></span>'
          response += f.text_field((name_field + "_lteq").to_sym, :class => "#{align_attribute("integer")} filter-max col-md-10 form-control")
          response += '</div>'

          infostr = info_input(model_name, [(name_field + "_lteq").to_sym, (name_field + "_gteq").to_sym])
        end
      else
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter col-md-12 form-control")
        infostr = info_input(model_name, (name_field + "_cont").to_sym)
    end

    response += '</div>'

    # Add info class
    response = '<div class="form-group ' + infostr + '">' + response

    return response.html_safe
  end

  def info_input(modname, attr)
    model_name = modname.to_sym
    rep = false
    if not session[:search].blank? and not session[:search][model_name].blank? then
      if attr.kind_of?(Array) then
        rep = (attr.any? { |elt| (not session[:search][model_name][elt].blank?) })
      else
        rep = (not session[:search][model_name][attr].blank?)
      end
    end
    return (rep ? "info" : "")
  end

  def align_attribute(attribute_type)
    return case attribute_type
             when "string" then
               "al"
             when "integer", "float", "numeric", "decimal" then
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
        <a href="#">' + obj.send(caption_method).to_s + '</a>
        <ul>'
    ar = obj.send(child_relation.to_sym)
    ar = ar.order('position') if obj.class.column_names.include?("position")
    for o in ar.to_a
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

  def i18n_translate_path(model, attr)
    "app.models.#{model}.bs_attributes.#{attr}"
  end

  def i18n_translate_path_model(model)
    "app.models.#{model}.bs_caption"
  end

  def i18n_translate_path_model_plural(model)
    "app.models.#{model}.bs_caption_plural"
  end
end
