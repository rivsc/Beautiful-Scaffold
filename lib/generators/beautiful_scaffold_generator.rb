# encoding : utf-8
class BeautifulScaffoldGenerator < Rails::Generators::Base
  require_relative 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  # Resources
  # Generator : http://guides.rubyonrails.org/generators.html
  # ActiveAdmin with MetaSearch : https://github.com/gregbell/active_admin/tree/master/lib/active_admin
  # MetaSearch and ransack : https://github.com/ernie/meta_search & http://erniemiller.org/projects/metasearch/#description & http://github.com/ernie/ransack
  # Generator of rails : https://github.com/rails/rails/blob/master/railties/lib/rails/generators/erb/scaffold/scaffold_generator.rb

  #include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :model_opt, type: :string, desc: "Name of model (singular)"
  argument :myattributes, type: :array, default: [], banner: "field:type field:type"

  class_option :namespace, default: nil
  class_option :donttouchgem, default: nil
  class_option :mountable_engine, default: nil

  def install_gems
    if options[:donttouchgem].blank?
      require_gems
    end

    #inside Rails.root do # Bug ?!
    Bundler.with_unbundled_env do
      run "bundle install"
    end
  end

  def add_field_for_fulltext
    @beautiful_attributes = myattributes.dup
    @fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['wysiwyg'].include?(t)
        # _typetext = {html|text}
        # _fulltext = text without any code
        @fulltext_field << [a + '_typetext', 'string'].join(':')
        @fulltext_field << [a + '_fulltext', 'text'].join(':')
      end
    }
  end

  def mimetype
    if !File.exist?("app/controllers/beautiful_controller.rb")
      if File.exist?("config/initializers/mime_types.rb") # For mountable engine
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
    bc_css           = [
                        "beautiful-scaffold.css.scss",
                        "tagit-dark-grey.css",
                        "colorpicker.css",
                        "bootstrap-wysihtml5.css"
                       ]

    javascriptspath = "app/assets/javascripts/"
    javascriptspath_dest = "#{javascriptspath}#{engine_name}"

    bc_css.each do |path|
      copy_file "#{stylesheetspath}#{path}", "#{stylesheetspath_dest}#{path}"
    end
    copy_file "#{stylesheetspath}application-bs.css", "#{stylesheetspath_dest}application-bs.scss"

    # Jstree theme
    directory "#{stylesheetspath}themes", "#{stylesheetspath}#{engine_name}themes"

    if !engine_name.blank?
      ['beautiful-scaffold',
      'tagit-dark-grey',
      'colorpicker',
      'bootstrap-wysihtml5'].each do |fileassets|
        gsub_file File.join(stylesheetspath_dest, "application-bs.scss"), " *= require #{fileassets}", " *= require #{engine_name}#{fileassets}"
      end

      # Issue otherwise
      gsub_file File.join(stylesheetspath_dest, "application-bs.scss"), '@import "tempusdominus-bootstrap-4.css";', '@import "../tempusdominus-bootstrap-4.css";'
      gsub_file File.join(stylesheetspath_dest, "application-bs.scss"), 'require themes/default/style', "require #{engine_name}themes/default/style"

      # treeview
      gsub_file File.join(stylesheetspath_dest, 'themes', 'default', 'style.scss'), 'asset-url("themes', "asset-url(\"#{engine_name}themes"
      gsub_file File.join(stylesheetspath_dest, 'themes', 'default-dark', 'style.scss'), 'asset-url("themes', "asset-url(\"#{engine_name}themes"
    end

    # Js
    bc_js            = [
                        "application-bs.js",
                        "beautiful_scaffold.js",
                        "bootstrap-datetimepicker-for-beautiful-scaffold.js",
                        "jquery-barcode.js",
                        "jstree.min.js",
                        "tagit.js",
                        "bootstrap-colorpicker.js",
                        "a-wysihtml5-0.3.0.min.js",
                        "bootstrap-wysihtml5.js",
                        "fixed_menu.js"
                       ]

    [bc_js].flatten.each{ |path|
      copy_file "#{javascriptspath}#{path}", "#{javascriptspath_dest}#{path}"
    }

    if !engine_name.blank?
      ['a-wysihtml5-0.3.0.min',
      'bootstrap-colorpicker',
      'bootstrap-datetimepicker-for-beautiful-scaffold',
      'bootstrap-wysihtml5',
      'tagit.js',
      'jstree.min.js',
      'jquery-barcode',
      'beautiful_scaffold',
      'fixed_menu'].each do |fileassets|
        gsub_file File.join(javascriptspath_dest, "application-bs.js"), "//= require #{fileassets}", "//= require #{engine_name}#{fileassets}"
      end
    end

    # Images
    dir_image = "app/assets/images"
    dir_image_dest = "app/assets/images/#{engine_opt}"
    directory dir_image, dir_image_dest

    # Precompile BS assets
    path_to_assets_rb = "config/initializers/assets.rb"
    if !File.exist?(path_to_assets_rb) && !engine_name.blank? # Engine
      path_to_assets_rb = File.join("test", "dummy", "config/initializers/assets.rb")
    end

    append_to_file(path_to_assets_rb, "Rails.application.config.assets.precompile += ['#{engine_name}application-bs.css','#{engine_name}application-bs.js']")
    if !engine_name.blank?
      manifest_prefix = "#{engine_opt}_"
    else
      manifest_prefix = ""
    end
    #append_to_file("app/assets/config/#{manifest_prefix}manifest.js", '//= link_directory ../stylesheets/faq .css')
    append_to_file("app/assets/config/#{manifest_prefix}manifest.js", '//= link_directory ../javascripts/faq .js')
  end

  def generate_layout
    template  "app/views/layout.html.erb", "app/views/layouts/#{engine_name}beautiful_layout.html.erb"

    gsub_file "app/views/layouts/#{engine_name}beautiful_layout.html.erb", '"layouts/beautiful_menu"', "\"layouts/#{engine_name}beautiful_menu\""

    if !File.exist?("app/views/layouts/#{engine_name}_beautiful_menu.html.erb")
      template  "app/views/_beautiful_menu.html.erb", "app/views/layouts/#{engine_name}_beautiful_menu.html.erb"
    end

    empty_directory "app/views/#{engine_name}beautiful"
    template  "app/views/dashboard.html.erb", "app/views/#{engine_name}beautiful/dashboard.html.erb"
    copy_file "app/views/_modal_columns.html.erb",  "app/views/layouts/#{engine_name}_modal_columns.html.erb"
    copy_file "app/views/_mass_inserting.html.erb", "app/views/layouts/#{engine_name}_mass_inserting.html.erb"

    action_ctrl = "#{namespace_for_url}#{model.pluralize}"

    inject_into_file("app/views/layouts/#{engine_name}_beautiful_menu.html.erb",
                     "\n" + '<%= link_to ' + i18n_t_m_p(model) + '.capitalize, ' + namespace_for_route + model.pluralize + '_path, class: "nav-link #{(params[:controller] == "' + action_ctrl + '" ? "active" : "")}" %>',
                     :after => "<!-- Beautiful Scaffold Menu Do Not Touch This -->")
  end

  def generate_model
    generate("model", "#{model} #{beautiful_attr_to_rails_attr.join(' ')} #{@fulltext_field.join(' ')}")
    directory  "app/models/concerns", "app/models/concerns/#{engine_name}"

    copy_file  "app/models/pdf_report.rb", "app/models/#{engine_name}pdf_report.rb"

    if !engine_name.blank?
      ['caption_concern', 'default_sorting_concern','fulltext_concern'].each do |f|
        path_to_the_concern = "app/models/concerns/#{engine_name}#{f}.rb"
        inject_into_file path_to_the_concern, "module #{engine_camel}\n", before: "module #{f.camelcase}"
        append_to_file path_to_the_concern, "\nend #endofmodule \n"
      end

      path_to_the_pdf_report = "app/models/#{engine_name}pdf_report.rb"
      inject_into_file path_to_the_pdf_report, "module #{engine_camel}\n", before: "class PdfReport"
      append_to_file path_to_the_pdf_report, "\nend #endofmodule \n"
    end

    gsub_file "app/models/#{engine_name}#{model}.rb", 'ActiveRecord::Base', 'ApplicationRecord' # Rails 4 -> 5
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

  end

  def add_to_model
    add_relation
  end

  def generate_controller
    beautiful_ctrl_path = "app/controllers/#{engine_name}beautiful_controller.rb"
    copy_file  "app/controllers/master_base.rb", beautiful_ctrl_path
    # beautiful_controller in the context of engine
    if !engine_name.empty?
      inject_into_file beautiful_ctrl_path, "module #{engine_camel}\n", before: "class BeautifulController"
      #gsub_file beautiful_ctrl_path, '< ApplicationController', "< ::#{engine_camel}::ApplicationController" # Rails 4 -> 5 'BeautifulController < ApplicationController'
      append_to_file beautiful_ctrl_path, "end #endofmodule \n"

      gsub_file beautiful_ctrl_path, 'layout "beautiful_layout"', "layout \"#{engine_name}beautiful_layout\""
    end
    dirs = ['app', 'controllers', engine_name, options[:namespace]].compact
    # Avoid to remove app/controllers directory (https://github.com/rivsc/Beautiful-Scaffold/issues/6)
    empty_directory File.join(dirs) if !options[:namespace].blank?
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

      gsub_file current_template_path, '"layouts/modal_columns"', "\"layouts/#{engine_name}modal_columns\""
      gsub_file current_template_path, '"layouts/mass_inserting"', "\"layouts/#{engine_name}mass_inserting\""
    end

    copy_file  "app/views/_form_habtm_tag.html.erb", "app/views/layouts/#{engine_name}_form_habtm_tag.html.erb"
  end

  def install_ransack_intializer
    copy_file  "app/initializers/ransack.rb", "config/initializers/ransack.rb"
  end

  def install_willpaginate_renderer_for_bootstrap
    copy_file  "app/initializers/link_renderer.rb", "config/initializers/link_renderer.rb"
  end

  def routes
    myroute = <<EOF
  root :to => 'beautiful#dashboard'
  match ':model_sym/select_fields' => 'beautiful#select_fields', as: :select_fields, via: [:get, :post]

  concern :bs_routes do
    collection do
      post :batch
      get  :treeview
      match :search_and_filter, action: :index, as: :search, via: [:get, :post]
    end
    member do
      post :treeview_update
    end
  end

  # Add route with concerns: :bs_routes here # Do not remove
EOF

    inject_into_file("config/routes.rb", myroute, :after => "routes.draw do\n")

    myroute =  "\n  "
    myroute += "namespace :#{namespace_alone} do\n    " if !namespace_alone.blank?
    myroute += "resources :#{model_pluralize}, concerns: :bs_routes\n  "
    myroute += "end\n"                                  if !namespace_alone.blank?

    inject_into_file("config/routes.rb", myroute, :after => ":bs_routes here # Do not remove")
  end
end
