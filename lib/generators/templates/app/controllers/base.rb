# encoding : utf-8
class <%= namespace_for_class %><%= model_camelize.pluralize %>Controller < BeautifulController

  before_action :load_<%= model %>, :only => [:show, :edit, :update, :destroy]

  # Uncomment for check abilities with CanCan
  #authorize_resource

  def index
    session[:fields] ||= {}
    session[:fields]["<%= model %>"] ||= (<%= model_camelize %>.columns.map(&:name) - ["id"])[0..4]
    do_select_fields("<%= model %>")
    do_sort_and_paginate("<%= model %>")
    
    @q = <%= model_camelize %>.search(
      params[:q]
    )

    @<%= model %>_scope = @q.result(
      :distinct => true
    ).sorting(
      params[:sorting]
    )
    
    @<%= model %>_scope_for_scope = @<%= model %>_scope.dup
    
    unless params[:scope].blank?
      @<%= model %>_scope = @<%= model %>_scope.send(params[:scope])
    end
    
    @<%= model_pluralize %> = @<%= model %>_scope.paginate(
      :page => params[:page],
      :per_page => 20
    ).to_a

    respond_to do |format|
      format.html{
        render
      }
      format.json{
        render :json => @<%= model %>_scope.to_a
      }
      format.csv{
        require 'csv'
        csvstr = CSV.generate do |csv|
          csv << <%= model_camelize %>.attribute_names
          @<%= model %>_scope.to_a.each{ |o|
            csv << <%= model_camelize %>.attribute_names.map{ |a| o[a] }
          }
        end 
        render :text => csvstr
      }
      format.xml{ 
        render :xml => @<%= model %>_scope.to_a
      }             
      format.pdf{
        pdfcontent = PdfReport.new.to_pdf(<%= model_camelize %>,@<%= model %>_scope)
        send_data pdfcontent
      }
    end
  end

  def show
    respond_to do |format|
      format.html{
        render
      }
      format.json { render :json => @<%= model %> }
    end
  end

  def new
    @<%= model %> = <%= model_camelize %>.new

    respond_to do |format|
      format.html{
        render
      }
      format.json { render :json => @<%= model %> }
    end
  end

  def edit
    
  end

  def create
    @<%= model %> = <%= model_camelize %>.create(params_for_model)

    respond_to do |format|
      if @<%= model %>.save
        format.html {
          if params[:mass_inserting] then
            redirect_to <%= namespace_for_route %><%= model_pluralize %>_path(:mass_inserting => true)
          else
            redirect_to <%= namespace_for_route %><%= singular_table_name %>_path(@<%= model %>), :flash => { :notice => t(:create_success, :model => "<%= model %>") }
          end
        }
        format.json { render :json => @<%= model %>, :status => :created, :location => @<%= model %> }
      else
        format.html {
          if params[:mass_inserting] then
            redirect_to <%= namespace_for_route %><%= model_pluralize %>_path(:mass_inserting => true), :flash => { :error => t(:error, "Error") }
          else
            render :action => "new"
          end
        }
        format.json { render :json => @<%= model %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @<%= model %>.update_attributes(params_for_model)
        format.html { redirect_to <%= namespace_for_route %><%= singular_table_name %>_path(@<%= model %>), :flash => { :notice => t(:update_success, :model => "<%= model %>") }}
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @<%= model %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @<%= model %>.destroy

    respond_to do |format|
      format.html { redirect_to <%= namespace_for_route %><%= model_pluralize %>_url }
      format.json { head :ok }
    end
  end

  def batch
    attr_or_method, value = params[:actionprocess].split(".")

    @<%= model_pluralize %> = []    
    
    <%= model_camelize %>.transaction do
      if params[:checkallelt] == "all" then
        # Selected with filter and search
        do_sort_and_paginate(:<%= model %>)

        @<%= model_pluralize %> = <%= model_camelize %>.search(
          params[:q]
        ).result(
          :distinct => true
        )
      else
        # Selected elements
        @<%= model_pluralize %> = <%= model_camelize %>.find(params[:ids].to_a)
      end

      @<%= model_pluralize %>.each{ |<%= model %>|
        if not <%= model_camelize %>.columns_hash[attr_or_method].nil? and
               <%= model_camelize %>.columns_hash[attr_or_method].type == :boolean then
         <%= model %>.update_attribute(attr_or_method, boolean(value))
         <%= model %>.save
        else
          case attr_or_method
          # Set here your own batch processing
          # <%= model %>.save
          when "destroy" then
            <%= model %>.destroy
          end
        end
      }
    end
    
    redirect_to :back
  end

  def treeview

  end

  def treeview_update
    modelclass = <%= model_camelize %>
    foreignkey = :<%= model %>_id

    render :nothing => true, :status => (update_treeview(modelclass, foreignkey) ? 200 : 500)
  end
  
  private 
  
  def load_<%= model %>
    @<%= model %> = <%= model_camelize %>.find(params[:id])
  end

  def params_for_model
    params.require(:<%= model %>).permit(<%= model_camelize %>.permitted_attributes)
  end
end

