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
      if t == 'richtext' then
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
    bc_css           = "#{stylesheetspath}beautiful_scaffold.css.scss"
        
    javascriptspath = "app/assets/javascripts/"
    
    # Js
    bc_js            = "#{javascriptspath}beautiful_scaffold.js"
    pjax_js          = "#{javascriptspath}jquery.pjax.js"

    [reset, bc_css, bc_js, pjax_js].each{ |path|
      copy_file path, path
    }
    
    # Images
    dir_image = "app/assets/images"
    directory dir_image, dir_image
  end
  
  def generate_layout
    template  "app/views/layout.html.erb", "app/views/layouts/beautiful_layout.html.erb"
    if not File.exist?("app/views/layouts/_beautiful_menu.html.erb") then
      template  "app/views/_beautiful_menu.html.erb", "app/views/layouts/_beautiful_menu.html.erb"
    end
    
    inject_into_file("app/views/layouts/_beautiful_menu.html.erb",'
      <p class="menuelt <%= "active" if params[:controller] == "' + namespace_for_url + model.pluralize + '" %>" data-id="sub-' + model + '">' + model.capitalize + '</p>
      <ul class="submenu <%= "hidden" if params[:controller] != "' + namespace_for_url + model.pluralize + '" %>" id="sub-' + model + '">
        <li><%= link_to "New ' + model.capitalize + '", new_' + namespace_for_route + model + '_path %></li>
        <li><%= link_to "Manage ' + model.capitalize.pluralize + '", ' + namespace_for_route + model.pluralize + '_path %></li>
      </ul>', :after => "<!-- Beautiful Scaffold Menu Do Not Touch This -->")    
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
   "#" + id.to_s
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
    
    available_views.each do |view|
      filename = view + ".html.erb"
      current_template_path = File.join([dirs, filename].flatten)
      empty_template_path   = File.join(["app", "views", filename].flatten)
      
      template empty_template_path, current_template_path
    end
  end

  def routes
    myroute = ""
    myroute += "namespace :#{namespace_alone} do\n  " if not namespace_alone.blank?
    myroute += "resources :#{model_pluralize} do\n    collection do\n      post :batch\n    end\n  end\n"
    myroute += "end\n"                                if not namespace_alone.blank?
    route(myroute)
  end
end
