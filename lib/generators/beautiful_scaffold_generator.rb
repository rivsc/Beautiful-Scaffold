# encoding : utf-8
class BeautifulScaffoldGenerator < Rails::Generators::Base
  require 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  # Resources
  # Generator : http://guides.rubyonrails.org/generators.html
  # ActiveAdmin with MetaSearch : https://github.com/gregbell/active_admin/tree/master/lib/active_admin
  # MetaSearch and ransack : https://github.com/ernie/meta_search & http://erniemiller.org/projects/metasearch/#description & http://github.com/ernie/ransack
  # Generator of rails : https://github.com/rails/rails/blob/master/railties/lib/rails/generators/erb/scaffold/scaffold_generator.rb

  #include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :model, :type => :string, :desc => "Name of model (downcase singular)"
  argument :myattributes, :type => :array, :default => [], :banner => "field:type field:type"
  
  class_option :namespace, :default => nil

  def install_gems
    require_gems
  end

  def add_field_for_fulltext
    @beautiful_attributes = myattributes.dup
    @fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['richtext', 'wysiwyg'].include?(t) then
        # _typetext = {bbcode|html|text|wiki|textile|markdown}
        # _fulltext = text without any code
        @fulltext_field << [a + '_typetext', 'string'].join(':')
        @fulltext_field << [a + '_fulltext', 'text'].join(':')
      end
    }
  end

  def mimetype
    if not File.exist?("app/controllers/beautiful_controller.rb") then
      inject_into_file("config/initializers/mime_types.rb", 'Mime::Type.register_alias "application/pdf", :pdf' + "\n", :before => "# Be sure to restart your server when you modify this file." )
    end
  end
  
  def generate_assets
    stylesheetspath = "app/assets/stylesheets/"
    
    # Css
    reset            = "#{stylesheetspath}reset.css"
    bc_css           = [
                        "#{stylesheetspath}bootstrap.css",
                        "#{stylesheetspath}bootstrap.min.css",
                        "#{stylesheetspath}bootstrap-responsive.css",
                        "#{stylesheetspath}bootstrap-responsive.min.css",
                        "#{stylesheetspath}datepicker.css",
                        "#{stylesheetspath}timepicker.css",
                        "#{stylesheetspath}beautiful-scaffold.css.scss",
                        "#{stylesheetspath}tagit-dark-grey.css",
                        "#{stylesheetspath}colorpicker.css",
                        "#{stylesheetspath}bootstrap-wysihtml5.css"
                       ]
        
    javascriptspath = "app/assets/javascripts/"
    
    # Js
    bc_js            = [
                        "#{javascriptspath}beautiful_scaffold.js",
                        "#{javascriptspath}bootstrap.js",
                        "#{javascriptspath}bootstrap.min.js",
                        "#{javascriptspath}bootstrap-alert.js",
                        "#{javascriptspath}bootstrap-dropdown.js",
                        "#{javascriptspath}bootstrap-modal.js",
                        "#{javascriptspath}bootstrap-tooltip.js",
                        "#{javascriptspath}bootstrap-datepicker.js",
                        "#{javascriptspath}bootstrap-datetimepicker-for-beautiful-scaffold.js",
                        "#{javascriptspath}bootstrap-timepicker.js",
                        "#{javascriptspath}jquery.livequery.js",
                        "#{javascriptspath}jquery.jstree.js",
                        "#{javascriptspath}tagit.js",
                        "#{javascriptspath}bootstrap-colorpicker.js",
                        "#{javascriptspath}a-wysihtml5-0.3.0.min.js",
                        "#{javascriptspath}bootstrap-wysihtml5.js"
                       ]
    pjax_js          = "#{javascriptspath}jquery.pjax.js"

    [reset, bc_css, bc_js, pjax_js].flatten.each{ |path|
      copy_file path, path
    }

    # Jstree theme
    directory "app/assets/stylesheets/themes", "app/assets/stylesheets/themes"

    # Inject jquery-ui
    appjs = "app/assets/javascripts/application.js"
    if not File.read(appjs)[/\/\/= require jquery-ui/] then
      inject_into_file(appjs, "//= require jquery-ui\n", :after => "//= require jquery\n")
    end
    
    # Images
    dir_image = "app/assets/images"
    directory dir_image, dir_image
  end
  
  def generate_layout
    template  "app/views/layout.html.erb", "app/views/layouts/beautiful_layout.html.erb"
    if not File.exist?("app/views/layouts/_beautiful_menu.html.erb") then
      template  "app/views/_beautiful_menu.html.erb", "app/views/layouts/_beautiful_menu.html.erb"
    end

    empty_directory "app/views/beautiful"
    template  "app/views/dashboard.html.erb", "app/views/beautiful/dashboard.html.erb"
    copy_file "app/views/_modal_columns.html.erb",  "app/views/layouts/_modal_columns.html.erb"
    copy_file "app/views/_mass_inserting.html.erb", "app/views/layouts/_mass_inserting.html.erb"
    
    inject_into_file("app/views/layouts/_beautiful_menu.html.erb",'
      <li class="<%= "active" if params[:controller] == "' + namespace_for_url + model.pluralize + '" %>">
        <%= link_to t(:' + model.pluralize + ', :default => "' + model.pluralize + '").capitalize, ' + namespace_for_route + model.pluralize + '_path %>
      </li>', :after => "<!-- Beautiful Scaffold Menu Do Not Touch This -->")
  end

  def install_markitup
    # CSS
    directory "markitup/skins",              "app/assets/stylesheets/markitup/skins"
    # JS
    copy_file "markitup/jquery.markitup.js", "app/assets/javascripts/jquery.markitup.js"
    # JS and CSS
    directory "markitup/sets",               "app/assets/stylesheets/markitup/sets"
    directory "markitup/sets",               "app/assets/javascripts/markitup/sets"
  end

  def generate_model
    generate("model", "#{model} #{beautiful_attr_to_rails_attr.join(' ')} #{@fulltext_field.join(' ')}")
    
    inject_into_file("app/models/#{model}.rb",'
  scope :sorting, lambda{ |options|
    attribute = options[:attribute]
    direction = options[:sorting]

    attribute ||= "id"
    direction ||= "DESC"

    order("#{attribute} #{direction}")
  }
    # You can OVERRIDE this method used in model form and search form (in belongs_to relation)
  def caption
    (self["name"] || self["label"] || self["description"] || "##{id}")
  end', :after => "class #{model_camelize} < ActiveRecord::Base")
    
     inject_into_file("app/models/#{model}.rb",'
  include BeautifulScaffoldModule      

  before_save :fulltext_field_processing

  def fulltext_field_processing
    # You can preparse with own things here
    generate_fulltext_field([' + fulltext_attribute.map{ |e| ('"' + e + '"') }.join(",") + '])
  end', :after => "class #{model_camelize} < ActiveRecord::Base")

    inject_into_file("config/application.rb", '    config.autoload_paths += %W(#{config.root}/app/modules)' + "\n", :after => "< Rails::Application\n")

    directory  "modules", "app/modules"
    copy_file  "app/models/pdf_report.rb", "app/models/pdf_report.rb"
  end

  def add_to_model
    # Add relation and foreign_key in attr_accessible
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['references', 'reference'].include?(t) then
        inject_into_file("app/models/#{model}.rb", ":#{a}_id, ", :after => "attr_accessible ")
        begin
          inject_into_file("app/models/#{a}.rb", "\n  has_many :#{model_pluralize}, :dependent => :nullify", :after => "ActiveRecord::Base")
          inject_into_file("app/models/#{a}.rb", ":#{model}_ids, ", :after => "attr_accessible ")
        rescue
        end
      end
    }
  end

  def generate_controller
    copy_file  "app/controllers/master_base.rb", "app/controllers/beautiful_controller.rb"
    dirs = ['app', 'controllers', options[:namespace]].compact
    empty_directory File.join(dirs)
    template   "app/controllers/base.rb", File.join([dirs, "#{model_pluralize}_controller.rb"].flatten)
  end
  
  def generate_helper
    copy_file  "app/helpers/beautiful_helper.rb", "app/helpers/beautiful_helper.rb"
    dirs = ['app', 'helpers', options[:namespace]].compact
    empty_directory File.join(dirs)
    template   "app/helpers/model_helper.rb", File.join([dirs, "#{model_pluralize}_helper.rb"].flatten)
  end

  def generate_views
    namespacedirs = ["app", "views", options[:namespace]].compact
    empty_directory File.join(namespacedirs)
    
    dirs = [namespacedirs, model_pluralize]
    empty_directory File.join(dirs)
    
    [available_views, 'treeview'].flatten.each do |view|
      filename = view + ".html.erb"
      current_template_path = File.join([dirs, filename].flatten)
      empty_template_path   = File.join(["app", "views", filename].flatten)
      
      template empty_template_path, current_template_path
    end

    copy_file  "app/views/_treeview_js.html.erb",    "app/views/layouts/_treeview_js.html.erb"
    copy_file  "app/views/_form_habtm_tag.html.erb", "app/views/layouts/_form_habtm_tag.html.erb"
  end

  def install_willpaginate_renderer_for_bootstrap
    copy_file  "app/initializers/link_renderer.rb", "config/initializers/beautiful_helper.rb"
  end

  def routes
    routes_in_text = File.read("config/routes.rb")

    if not routes_in_text[/beautiful#dashboard/] and not routes_in_text[/beautiful#select_fields/] then
      myroute = "root :to => 'beautiful#dashboard'\n"
      myroute += "  match ':model_sym/select_fields' => 'beautiful#select_fields'\n"
      route(myroute)
    end

    search_namespace = namespace_alone + "/" if not namespace_alone.blank?
    search_namespace ||= ""

    myroute = 'match "' + search_namespace + model_pluralize + '/search_and_filter" => "' + search_namespace + model_pluralize + '#index", :via => [:get, :post], :as => :' + namespace_for_route + 'search_' + model_pluralize + "\n  "
    myroute += "namespace :#{namespace_alone} do\n  " if not namespace_alone.blank?
    myroute += "resources :#{model_pluralize} do\n    collection do\n      post :batch\n      get  :treeview\n    end\n    member do\n      post :treeview_update\n    end\n  end\n"
    myroute += "end\n"                                if not namespace_alone.blank?
    route(myroute)
  end
end
