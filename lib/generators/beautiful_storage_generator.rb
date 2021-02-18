# encoding : utf-8
class BeautifulStorageGenerator < Rails::Generators::Base
  require_relative 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  # TODO voir pour engine

  argument :model, :type => :string, :desc => "Name of model (ex: user)"
  argument :storage_name, :type => :string, :desc => "Storage's name (ex: picture_file)"

  class_option :mountable_engine, default: nil
  
  def install_storage

    #if !File.read('Gemfile').include?("image_processing")
      gem("image_processing", '~> 1.2')
    #end

    Bundler.with_unbundled_env do
      run "bundle install"
    end

    # Install activestorage
    run "bin/rails active_storage:install"
    #run "rake db:migrate"

    raise "Model must be specified" if model.blank?
    raise "Attachment must be specified" if storage_name.blank?

    # ===== Model
    inject_into_file("app/models/#{engine_name}#{model}.rb",
 "\n
  has_one_attached :#{storage_name}
\n", after: "< ApplicationRecord")
    inject_into_file("app/models/#{engine_name}#{model}.rb", ":#{storage_name},", :after => "def self.permitted_attributes\n    return ")

    # ====== Views
    inject_into_file("app/views/#{engine_name}#{model_pluralize}/_form.html.erb",
"  <div class='form-group'>
    <%= f.label :#{storage_name}, t('app.models.#{model}.bs_attributes.#{storage_name}', :default => '#{storage_name}').capitalize, :class => 'control-label' %><br />
    <%= f.file_field :#{storage_name}, direct_upload: true, :class => 'form-control' %>
  </div>\n", before: '<!-- Beautiful_scaffold - AddField - Do not remove -->')

    inject_into_file("app/views/#{engine_name}#{model_pluralize}/_form.html.erb",
                     ", multipart: true", after: "form_for(@#{model}")

    inject_into_file("app/views/#{engine_name}#{model_pluralize}/show.html.erb",
                     "<p><b><%= t('app.models.#{model}.bs_attributes.#{storage_name}', :default => '#{storage_name}') %>:</b><br><%= image_tag @#{model}.#{storage_name}.variant(resize_to_limit: [100, 100]) %></p>",
                     before: "<!-- Beautiful_scaffold - AddField - Field - Do not remove -->")

    # Controller
    #inject_into_file("app/controllers/#{engine_name}#{model_pluralize}_controller.rb",
    #                 "\n  before_action :require_login, except: [:dashboard]\n",
    #                 :after => 'layout "beautiful_layout"' + "\n")

    say "You must run 'rake db:migrate' to create activestorage migrations !"

  end
end
