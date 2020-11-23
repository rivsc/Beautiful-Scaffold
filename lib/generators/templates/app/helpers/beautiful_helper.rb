# encoding : utf-8
<%
if !engine_name.blank?
b_module = "module #{engine_camel}"
e_module = "end"
else
b_module = ""
e_module = ""
end
%>
<%= b_module %>
module BeautifulHelper

  def visible_column(model_name, field_name, display_default = 'table-cell', other_css = "")
    return ('style="display:' + ((session['fields'][model_name].to_a.include?(field_name))  ? display_default : 'none') + ';' + other_css + '"').html_safe
  end

  def dropdown_submenu(link_caption, &block)
    the_link = link_to((link_caption + ' <b class="caret"></b>').html_safe, "#", :class => "dropdown-toggle", "data-toggle" => "dropdown")
    contents = (block_given?) ? content_tag_string(:ul, capture(&block), :class => "dropdown-menu") : ''
    content_tag_string :li, the_link + contents, :class => "dropdown"
  end

  def sorting_header(model_name, attribute_name, namespace)
    attr    = nil
    sort    = nil

    if !params[:sorting].blank?
      attr = params[:sorting][:attribute]
      sort = params[:sorting][:sorting]
    end

    attr    = attr.to_s.downcase
    sortstr = sort.to_s.downcase
    opposite_sortstr = ""
    csort = '' # <i class="fa fa-stop"></i>
    if attribute_name == attr
      if sortstr == "asc"
        csort = '<i class="fa fa-chevron-up"></i>'
        opposite_sortstr = "desc"
      elsif sortstr == "desc"
        csort = '<i class="fa fa-chevron-down"></i>'
        opposite_sortstr = "asc"
      end
    else
      opposite_sortstr = "asc"
    end

    default_caption = attribute_name.capitalize
    if is_belongs_to_column?(default_caption)
      default_caption = get_belongs_to_model(default_caption)
    end

    cap = i18n_translate_path(model_name, attribute_name)

    caption = t(cap, :default => default_caption).capitalize
    strpath = model_name.pluralize + "_url"
    strpath = namespace + '_' + strpath if !namespace.blank?

    return link_to(
        "#{csort} #{caption}".html_safe,
        eval(strpath) + "?" +
            CGI.unescape({:sorting => {:attribute => attribute_name.downcase,:sorting => opposite_sortstr}}.to_query)
    ).html_safe
  end

  def ransack_field(path_of_model, attribute_name, f, caption = nil, engine = nil)
    model_path = path_of_model.split("/")
    model_name = model_path.last
    model_path.delete(model_path.first)
    model_name_for_ransack = model_path.join("_")

    ar_model = (engine.blank? ? model_name.camelize.constantize : "#{engine.camelize}::#{model_name.camelize}".constantize)

    default_caption = caption
    if default_caption.blank?
      default_caption = attribute_name.capitalize
      if is_belongs_to_column?(default_caption)
        default_caption = get_belongs_to_model(default_caption)
      end
    end

    name_field    = attribute_name
    name_field_bk = attribute_name
    label_field   = attribute_name

    if is_belongs_to_column?(name_field_bk)
      label_field = get_belongs_to_model(attribute_name)
    end

    name_field = model_name_for_ransack + "_" + name_field unless model_name_for_ransack.blank?

    cap = i18n_translate_path(model_name, attribute_name)

    type_of_column = ar_model.columns_hash[attribute_name].type unless ar_model.columns_hash[attribute_name].nil?
    type_of_column ||= :other

    infostr   = ''
    response  = '' # See at end
    response += '<div class="form-check form-check-inline">' if type_of_column == :boolean
    response += f.label name_field, t(cap, :default => default_caption).capitalize, :class => "control-label"
    response += '</div>' if type_of_column == :boolean

    case type_of_column
      when :date, :datetime
        dt = (type_of_column == :datetime)
        interval = (dt ? (1..5) : (1..3))

        html_id = "#{name_field}_dp_gt"
        filter = session['search'][model_name]
        filter ||= {}

        # Greater than
        response += '<div class="dpicker input-group input-' + type_of_column.to_s + ' mb-2" data-field="q_' + name_field + '_gteq" id="' + html_id + '_id" data-target-input="nearest">'
        response += '<div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-chevron-right"></i></span></div>'
        response += f.text_field(
            (html_id).to_sym,
            :value => ("#{filter["#{name_field}_gteq(3i)"]}/#{filter["#{name_field}_gteq(2i)"]}/#{filter["#{name_field}_gteq(1i)"]}"),
            :class => " form-control datetimepicker-input",
            "data-target" => "##{html_id}_id",
            "data-id" => ("q_" + name_field + "_gteq"))
        response += '<div class="input-group-append" data-target="' + html_id + '_id" data-toggle="datetimepicker"><span class="input-group-text"><i class="fa fa-calendar"></i></span></div>'
        response += '</div>'

        html_id = "#{name_field}_tp_gt"

        if dt
          response += '<div class="tpicker input-group input-' + type_of_column.to_s + ' mb-2" data-field="q_' + name_field + '_gteq" id="' + html_id + '_id" data-target-input="nearest">'
          response += '<div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-chevron-right"></i></span></div>'
          response += f.text_field(
              (name_field + "_tp_gt").to_sym,
              :value => ("#{filter["#{name_field}_gteq(4i)"]}/#{filter["#{name_field}_gteq(5i)"]}"),
              :class => " form-control datetimepicker-input",
              "data-target" => "##{html_id}_id",
              "data-id" => ("q_" + name_field + "_gteq"))
          response += '<div class="input-group-append" data-target="' + html_id + '_id" data-toggle="datetimepicker"><span class="input-group-text"><i class="fa fa-clock"></i></span></div>'
          response += '</div>'
        end

        for i in interval
          response += f.hidden_field(name_field + "_gteq(#{i}i)",
                                     :value => (filter["#{name_field}_gteq(#{i}i)"]),
                                     :id => ('q_' + name_field + "_gteq_#{i}i"))
        end

        html_id = "#{name_field}_dp_lt"

        # Less than
        response += '<div class="dpicker input-group input-' + type_of_column.to_s + ' mb-2" data-field="q_' + name_field + '_lteq" id="' + html_id + '_id" data-target-input="nearest">'
        response += '<div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-chevron-left"></i></span></div>'
        response += f.text_field(
            (name_field + "_dp_lt").to_sym,
            :value => ("#{filter["#{name_field}_lteq(3i)"]}/#{filter["#{name_field}_lteq(2i)"]}/#{filter["#{name_field}_lteq(1i)"]}"),
            :class => " form-control datetimepicker-input",
            "data-target" => "##{html_id}_id",
            "data-id" => ("q_" + name_field + "_lteq"))
        response += '<div class="input-group-append" data-target="' + html_id + '_id" data-toggle="datetimepicker"><span class="input-group-text"><i class="fa fa-calendar"></i></span></div>'
        response += '</div>'

        html_id = "#{name_field}_tp_lt"

        if dt
          response += '<div class="tpicker input-group input-' + type_of_column.to_s + ' mb-2" data-field="q_' + name_field + '_lteq" id="' + html_id + '_id" data-target-input="nearest">'
          response += '<div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-chevron-left"></i></span></div>'
          response += f.text_field(
              (name_field + "_tp_lt").to_sym,
              :value => ("#{filter["#{name_field}_lteq(4i)"]}/#{filter["#{name_field}_lteq(5i)"]}"),
              :class => " form-control datetimepicker-input",
              "data-target" => "##{html_id}_id",
              "data-id" => ("q_" + name_field + "_lteq"))
          response += '<div class="input-group-append" data-target="' + html_id + '_id" data-toggle="datetimepicker"><span class="input-group-text"><i class="fa fa-clock"></i></span></div>'
          response += '</div>'
        end

        for i in interval
          response += f.hidden_field(name_field + "_lteq(#{i}i)",
                                     :value => (filter["#{name_field}_lteq(#{i}i)"]),
                                     :id => ('q_' + name_field + "_lteq_#{i}i"))
        end

        infostr = info_input(model_name, [(name_field + "_dp_lt").to_sym, (name_field + "_tp_lt").to_sym, (name_field + "_dp_gt").to_sym, (name_field + "_tp_gt").to_sym])
      when :boolean
        # Specify a default value (false) in rails migration
        response += '<div class="form-check form-check-inline">'
        response += f.radio_button((name_field + "_eq").to_sym, true, { class: 'form-check-input'})
        response += f.label name_field + "_eq_true", h(t(:yes, default: "Yes")), class: "form-check-label"
        response += '</div>'

        response += '<div class="form-check form-check-inline">'
        response += f.radio_button((name_field + "_eq").to_sym, false, { class: 'form-check-input'})
        response += f.label name_field + "_eq_false", h(t(:no, default: "No")), class: "form-check-label"
        response += '</div>'

        response += '<div class="form-check form-check-inline">'
        response += f.radio_button((name_field + "_eq").to_sym, nil, { class: 'form-check-input'})
        response += f.label name_field + "_eq", h(t(:all, default: "All")), class: "form-check-label"
        response += '</div>'

        infostr = (begin session['search'][model_name][(name_field + "_eq").to_sym] == "on" ? "" : "info" rescue "" end)
      when :string
        response += f.text_field((name_field + "_cont").to_sym, :class => "filter col-md-12 form-control")

        infostr = info_input(model_name, (name_field + "_cont").to_sym)
      when :integer, :float, :decimal #, :other
        if is_belongs_to_column?(name_field_bk)
          bt_model_name = get_belongs_to_model(name_field_bk).camelize
          field = name_field + "_eq"

          if !engine.blank?
            bt_model_name = "#{engine.camelize}::#{bt_model_name}"
            #field = "#{engine.downcase}_#{field}"
          end

          btmodel = bt_model_name.constantize
          field = field.to_sym

          response += f.collection_select(field, btmodel.all, :id, :caption, { :include_blank => t(:all, :default => "All") }, { :class => "col-md-12 form-control" })

          infostr = info_input(model_name, field)
        elsif name_field == "id"
          response += f.text_field((name_field + "_eq").to_sym, :class => "filter col-md-12 form-control")

          infostr = info_input(model_name, (name_field + "_eq").to_sym)
        else
          response += '<div class="input-group">'
          response += '<div class="input-group-prepend" rel="tooltip" title="' + t(:greater_than, :default => "Greater than") + '"><span class="input-group-text"><i class="fa fa-chevron-right"></i></span></div>'
          response += f.text_field((name_field + "_gteq").to_sym, :class => "#{align_attribute("integer")} filter-min form-control")
          response += '</div>'
          response += '<div class="input-group">'
          response += '<div class="input-group-append" rel="tooltip" title="' + t(:smaller_than, :default => "Smaller than") + '"><span class="input-group-text"><i class="fa fa-chevron-left"></i></span></div>'
          response += f.text_field((name_field + "_lteq").to_sym, :class => "#{align_attribute("integer")} filter-max form-control")
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
    model_name = modname
    rep = false
    if !session['search'].blank? and !session['search'][model_name].blank?
      if attr.kind_of?(Array)
        rep = (attr.any? { |elt| (not session['search'][model_name][elt].blank?) })
      else
        rep = (!session['search'][model_name][attr].blank?)
      end
    end
    return (rep ? "info" : "")
  end

  def align_attribute(attribute_type)
    return case attribute_type
    when "string"
      "al"
    when "integer", "float", "numeric", "decimal"
      "ar"
    when "boolean"
      "ac"
    when "date", "datetime", "timestamp"
      "ac"
    else
      "al"
    end
  end

  # Encore utilisé avec wysihtml5 ?
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
    params.delete :scope
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
<%= e_module %>