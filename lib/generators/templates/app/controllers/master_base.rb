# encoding : utf-8
class BeautifulController < ApplicationController
  
  layout "beautiful_layout"

  # That clear cookie to avoid cookie overflow
  # if you want to keep all in memory and you use ARCookieStore, just comment next line
  before_action :delete_session_for_others_models_scaffold

  def dashboard
    render :layout => "beautiful_layout"
  end

  def delete_session_for_others_models_scaffold
    current_model = params[:controller].split('/').last.singularize

    ['fields','sorting','search','scope','paginate'].each{ |k|
      session[k] = session[k].delete_if {|key, v| key != current_model } if not session[k].blank?
    }
  end

  # Call in AJAX
  def select_fields
    model_sym = params[:model_sym]

    do_select_fields(model_sym.to_s)

    head :ok
  end

  def do_select_fields(model_str)
    # Fields
    session['fields'] ||= {}
    session['fields'][model_str] ||= nil
    params[:fields] ||= session['fields'][model_str]
    session['fields'][model_str] = params[:fields]
  end

  def do_sort_and_paginate(model_str)
    # Sort
    session['sorting'] ||= {}
    session['sorting'][model_str] ||= { 'attribute' => "id", 'sorting' => "DESC" }
    params[:sorting] ||= session['sorting'][model_str]
    session['sorting'][model_str] = params[:sorting]

    # Search and Filter
    session['search'] ||= {}
    session['search'][model_str] = nil if not params[:nosearch].blank?
    params[:page] = 1 if not params[:q].nil?
    params[:q] ||= session['search'][model_str]
    session['search'][model_str] = params[:q] if params[:skip_save_search].blank?

    # Scope
    session['scope'] ||= {}
    session['scope'][model_str] ||= nil
    params[:page] = 1 if not params[:scope].nil?
    params[:scope] ||= session['scope'][model_str]
    session['scope'][model_str] = params[:scope]

    # Paginate
    session['paginate'] ||= {}
    session['paginate'][model_str] ||= nil
    params[:page] ||= session['paginate'][model_str]
    session['paginate'][model_str] = params[:page]
  end
  
  def boolean(string)
    return true if string == true || string =~ (/(true|t|yes|y|1)$/i)
    return false if string == false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
  end

  def update_treeview(modelclass, foreignkey)
    parent_id    = (params[foreignkey].to_i == 0 ? nil : params[foreignkey].to_i)
    index        = params[:position].to_i

    elt          = modelclass.find(params[:id])
    elt.attributes = { foreignkey => parent_id }

    if modelclass.column_names.include?("position")
      new_pos = 0
      modelclass.transaction do
        all_elt = modelclass.where(foreignkey => parent_id).order("position ASC").to_a

        if index == 0
          new_pos = (begin (all_elt.first.position - 1) rescue 1 end)
        elsif index == (all_elt.length - 1)
          new_pos = (begin (all_elt.last.position + 1) rescue 1 end)
        else
          new_pos = all_elt[index].position

          end_of_array = all_elt[index..-1]
          end_of_array.each do |g|
            next if g == elt
            g.position = g.position.to_i + 1
            g.save!

            next_elt = end_of_array[end_of_array.index(g) + 1]
            break if !next_elt.nil? && next_elt.position > g.position
          end
        end
      end
      elt.position = new_pos
    end
    return elt.save!
  end
end
