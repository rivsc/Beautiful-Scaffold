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

    do_select_fields(model_sym.to_sym) #TODO vérifier si nécessaire

    render :nothing => true
  end

  # TODO session use key string because json serializer don't know the type of key.

  def do_select_fields(model_sym)
    # Fields
    session['fields'] ||= {}
    session['fields'][model_sym.to_s] ||= nil
    params[:fields] ||= session['fields'][model_sym.to_s]
    session['fields'][model_sym.to_s] = params[:fields]
  end

  def do_sort_and_paginate(model_sym)
    # Sort
    session['sorting'] ||= {}
    session['sorting'][model_sym.to_s] ||= { 'attribute' => "id", 'sorting' => "DESC" }
    params[:sorting] ||= session['sorting'][model_sym.to_s]
    session['sorting'][model_sym.to_s] = params[:sorting]

    # Search and Filter
    session['search'] ||= {}
    session['search'][model_sym.to_s] = nil if not params[:nosearch].blank?
    params[:page] = 1 if not params[:q].nil?
    params[:q] ||= session['search'][model_sym.to_s]
    session['search'][model_sym.to_s] = params[:q] if params[:skip_save_search].blank?

    # Scope
    session['scope'] ||= {}
    session['scope'][model_sym.to_s] ||= nil
    params[:page] = 1 if not params[:scope].nil?
    params[:scope] ||= session['scope'][model_sym.to_s]
    session['scope'][model_sym.to_s] = params[:scope]

    # Paginate
    session['paginate'] ||= {}
    session['paginate'][model_sym.to_s] ||= nil
    params[:page] ||= session['paginate'][model_sym.to_s]
    session['paginate'][model_sym.to_s] = params[:page]
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

    if modelclass.column_names.include?("position") then
      new_pos = 0
      modelclass.transaction do
        all_elt = modelclass.where(foreignkey => parent_id).order("position ASC").to_a

        #begin
          if index == 0 then
            new_pos = (begin (all_elt.first.position - 1) rescue 1 end)
          elsif index == all_elt.length then
            new_pos = (begin (all_elt.last.position + 1) rescue 1 end)
          else
            new_pos = all_elt[index].position

            end_of_array = all_elt[index..-1]
            end_of_array.each{ |g|
              next if g == elt
              g.position = g.position.to_i + 1
              g.save!

              next_elt = end_of_array[end_of_array.index(g) + 1]
              break if not next_elt.nil? and next_elt.position > g.position
            }
          end
        #rescue
        #  new_pos = 0
        #end
      end
      elt.position = new_pos
    end
    return elt.save!
  end
end
