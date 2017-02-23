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
  class_option :donttouchgem, :default => nil
  class_option :mountable_engine, :default => nil

  def install_gems
    if options[:donttouchgem].blank? then
      require_gems
    end

    #inside Rails.root do # Bug ?!
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def add_field_for_fulltext
    @beautiful_attributes = myattributes.dup
    @fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['wysiwyg'].include?(t) then
        # _typetext = {html|text}
        # _fulltext = text without any code
        @fulltext_field << [a + '_typetext', 'string'].join(':')
        @fulltext_field << [a + '_fulltext', 'text'].join(':')
      end
    }
  end

  def mimetype
    if not File.exist?("app/controllers/beautiful_controller.rb") then
      if File.exist?("config/initializers/mime_types.rb") then # For mountable engine
        inject_into_file("config/initializers/mime_types.rb", 'Mime::Type.register_alias "application/pdf", :pdf' + "\n", :before => "# Be sure to restart your server when you modify this file." )
      else
        puts "============> Engine : You must add `Mime::Type.register_alias \"application/pdf\", :pdf` to your config/initializers/mime_types.rb main app !"
      end
    end
  end
  
  def generate_assets
    stylesheetspath = "app/assets/stylesheets/"
    stylesheetspath_dest = "#{stylesheetspath}#{engine_name}"
    
    # Css
    reset            = "reset.css"
    bc_css           = [
                        "application-bs.css",
                        "datepicker.css",
                        "timepicker.css",
                        "beautiful-scaffold.css.scss",
                        "tagit-dark-grey.css",
                        "colorpicker.css",
                        "bootstrap-wysihtml5.css"
                       ]

    javascriptspath = "app/assets/javascripts/"
    javascriptspath_dest = "#{javascriptspath}#{engine_name}"

    [reset, bc_css].flatten.each{ |path|
      copy_file "#{stylesheetspath}#{path}", "#{stylesheetspath_dest}#{path}"
    }
    
    # Js
    bc_js            = [
                        "application-bs.js",
                        "beautiful_scaffold.js",
                        "bootstrap-datepicker.js",
                        "bootstrap-datetimepicker-for-beautiful-scaffold.js",
                        "bootstrap-timepicker.js",
                        "jquery.jstree.js",
                        "jquery-barcode.js",
                        "tagit.js",
                        "bootstrap-colorpicker.js",
                        "a-wysihtml5-0.3.0.min.js",
                        "bootstrap-wysihtml5.js",
                        "fixed_menu.js"
                       ]

    [bc_js].flatten.each{ |path|
      copy_file "#{javascriptspath}#{path}", "#{javascriptspath_dest}#{path}"
    }

    # Jstree theme
    directory "#{stylesheetspath}themes", "#{stylesheetspath}themes"

    # Images
    dir_image = "app/assets/images"
    dir_image_dest = "app/assets/images/#{engine_opt}"
    directory dir_image, dir_image_dest

    # Old method
    #generate("bootstrap:install","static")
    # New method
    copy_file "#{stylesheetspath}bootstrap_and_overrides.css.less",
              "#{stylesheetspath_dest}bootstrap_and_overrides.css.less"

    # Precompile BS assets
    if File.exist?("config/initializers/assets.rb") then # For mountable engine
      inject_into_file("config/initializers/assets.rb", "Rails.application.config.assets.precompile += ['#{engine_name}application-bs.css','#{engine_name}application-bs.js']", after: /\z/m)
    else
      puts "============> Engine : You must add `Rails.application.config.assets.precompile += ['#{engine_name}application-bs.css','#{engine_name}application-bs.js']` to your config/initializers/assets.rb main app !"
    end
  end
  
  def generate_layout
    template  "app/views/layout.html.erb", "app/views/layouts/beautiful_layout.html.erb"
    if not File.exist?("app/views/layouts/_beautiful_menu.html.erb") then
      template  "app/views/_beautiful_menu.html.erb", "app/views/layouts/_beautiful_menu.html.erb"
    end

    empty_directory "app/views/#{engine_name}beautiful"
    template  "app/views/dashboard.html.erb", "app/views/#{engine_name}beautiful/dashboard.html.erb"
    copy_file "app/views/_modal_columns.html.erb",  "app/views/layouts/_modal_columns.html.erb"
    copy_file "app/views/_mass_inserting.html.erb", "app/views/layouts/_mass_inserting.html.erb"
    
    inject_into_file("app/views/layouts/_beautiful_menu.html.erb",'
      <li class="<%= "active" if params[:controller] == "' + namespace_for_url + model.pluralize + '" %>">
        <%= link_to ' + i18n_t_m_p(model) + '.capitalize, ' + namespace_for_route + model.pluralize + '_path %>
      </li>', :after => "<!-- Beautiful Scaffold Menu Do Not Touch This -->")
  end

  def generate_model
    generate("model", "#{model} #{beautiful_attr_to_rails_attr.join(' ')} #{@fulltext_field.join(' ')}")

    directory  "app/models/concerns", "app/models/concerns"

    inject_into_file("app/models/#{engine_name}#{model}.rb",'

  include DefaultSortingConcern
  include FulltextConcern
  include CaptionConcern

  cattr_accessor :fulltext_fields do
    [' + fulltext_attribute.map{ |e| ('"' + e + '"') }.join(",") + ']
  end

  def self.permitted_attributes
    return ' + attributes_without_type.map{ |attr| ":#{attr}" }.join(",") + '
  end', :after => "class #{model_camelize} < ApplicationRecord")

    copy_file  "app/models/pdf_report.rb", "app/models/pdf_report.rb"
  end

  def add_to_model
    # Add relation
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['references', 'reference'].include?(t) then
        begin
          inject_into_file("app/models/#{engine_name}#{a}.rb", "\n  has_many :#{model_pluralize}, :dependent => :nullify", :after => "ApplicationRecord")
        rescue
        end
      end
    }
  end

  def generate_controller
    copy_file  "app/controllers/master_base.rb", "app/controllers/#{engine_name}beautiful_controller.rb"
    dirs = ['app', 'controllers', engine_name, options[:namespace]].compact
    # Avoid to remove app/controllers directory (https://github.com/rivsc/Beautiful-Scaffold/issues/6)
    empty_directory File.join(dirs) if not options[:namespace].blank?
    dest_ctrl_file = File.join([dirs, "#{model_pluralize}_controller.rb"].flatten)
    template "app/controllers/base.rb", dest_ctrl_file
  end
  
  def generate_helper
    dest_bs_helper_file = "app/helpers/#{engine_name}beautiful_helper.rb"
    template "app/helpers/beautiful_helper.rb", dest_bs_helper_file

    dirs = ['app', 'helpers', engine_name, options[:namespace]].compact
    empty_directory File.join(dirs)
    dest_helper_file = File.join([dirs, "#{model_pluralize}_helper.rb"].flatten)
    template "app/helpers/model_helper.rb", dest_helper_file
  end

  def generate_views
    namespacedirs = ["app", "views", engine_name, options[:namespace]].compact
    empty_directory File.join(namespacedirs)
    
    dirs = [namespacedirs, model_pluralize]
    empty_directory File.join(dirs)
    
    [available_views, 'treeview'].flatten.each do |view|
      filename = view + ".html.erb"
      current_template_path = File.join([dirs, filename].flatten)
      empty_template_path   = File.join(["app", "views", filename].flatten)
      
      template empty_template_path, current_template_path
    end

    copy_file  "app/views/_form_habtm_tag.html.erb", "app/views/layouts/_form_habtm_tag.html.erb"
  end

  def install_ransack_intializer
    copy_file  "app/initializers/ransack.rb", "config/initializers/ransack.rb"
  end

  def install_willpaginate_renderer_for_bootstrap
    copy_file  "app/initializers/link_renderer.rb", "config/initializers/link_renderer.rb"
  end

  def routes
    routes_in_text = File.read("config/routes.rb")

    if not routes_in_text[/beautiful#dashboard/] and not routes_in_text[/beautiful#select_fields/] then

      myroute = <<EOF
root :to => 'beautiful#dashboard'
  match ':model_sym/select_fields' => 'beautiful#select_fields', :via => [:get, :post]

  concern :bs_routes do
    collection do
      post :batch
      get  :treeview
      match :search_and_filter, :action => :index, :as => :search, :via => [:get, :post]
    end
    member do
      post :treeview_update
    end
  end

  # Add route with concerns: :bs_routes here # Do not remove
EOF

      route(myroute)
    end

    search_namespace = namespace_alone + "/" if not namespace_alone.blank?
    search_namespace ||= ""

    myroute =  "\n  "
    myroute += "namespace :#{namespace_alone} do\n    " if not namespace_alone.blank?
    myroute += "resources :#{model_pluralize}, concerns: :bs_routes\n  "
    myroute += "end\n"                                  if not namespace_alone.blank?

    inject_into_file("config/routes.rb", myroute, :after => ":bs_routes here # Do not remove")
  end
end
