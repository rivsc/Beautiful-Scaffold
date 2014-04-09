# encoding : utf-8
class BeautifulDevisecancanGenerator < Rails::Generators::Base
  require 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  argument :model, :type => :string, :desc => "Name of model (downcase singular)"
  
  def install_devise
    view_path = "app/views/"

    gem("devise", "2.1.0")

    inside Rails.root do
      run "bundle install"
    end

    generate("devise:install")

    for current_env in ['production', 'development', 'test']
      inject_into_file("config/environments/#{current_env}.rb",  "  config.action_mailer.default_url_options = { :host => 'localhost:3000' }", :after => "::Application.configure do\n" )
    end

    # Install devise in the model
    generate("devise", model)

    # Add :token_authenticatable and :lockable
    # In model
    inject_into_file( "app/models/#{model}.rb",
                      ":token_authenticatable, :lockable,",
                      :after => "devise ")
    # In migration
    filename = Dir.glob("db/migrate/*_add_devise_to_#{model.pluralize}.rb")[0]
    gsub_file filename, /#\s*(t\.integer\s+:failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts)/, '\1'
    gsub_file filename, /#\s*(t\.string\s+:unlock_token # Only if unlock strategy is :email or :both)/, '\1'
    gsub_file filename, /#\s*(t\.datetime\s+:locked_at)/, '\1'
    gsub_file filename, /#\s*(t\.string\s+:authentication_token)/, '\1'


    # Limited access (Must be commented if use cancan)
    inject_into_file("app/controllers/beautiful_controller.rb","before_action :authenticate_#{model}!, :except => [:dashboard]", :after => 'layout "beautiful_layout"' + "\n")

    # Custom redirect
    inject_into_file("app/controllers/application_controller.rb","
      def after_sign_out_path_for(resource_or_scope)
        root_path
      end
      def after_sign_in_path_for(resource)
        root_path
      end
      def after_sign_up_path_for(resource)
        root_path
      end
      ", :after => "protect_from_forgery\n")
    copy_file("lib/custom_failure.rb")
    copy_file("app/controllers/registrations_controller.rb")
    inject_into_file("config/initializers/devise.rb","
      config.warden do |manager|
        manager.failure_app = CustomFailure
      end
      ", :after => "Devise.setup do |config|\n")
    inject_into_file("config/application.rb",' #{config.root}/lib', :after => '#{config.root}/app/modules')

    # Use my register controller
    inject_into_file("config/routes.rb",
                     ', :controllers => {:registrations => "registrations"}',
                     :after => "devise_for :#{model.pluralize}")


    # Install partials dans layout (forget password, sign_in)
    template("#{view_path}partials/_forget_password.html.erb",  "#{view_path}layouts/_forget_password.html.erb")
    template("#{view_path}partials/_sign_in_sign_out.html.erb", "#{view_path}layouts/_sign_in_sign_out.html.erb")
    template("#{view_path}partials/_sign_in_form.html.erb",     "#{view_path}layouts/_sign_in_form.html.erb")
    template("#{view_path}partials/_register_form.html.erb",    "#{view_path}layouts/_register_form.html.erb")

    # Sign in sign out
    inject_into_file("#{view_path}layouts/beautiful_layout.html.erb",
                     "<%= render :partial => 'layouts/sign_in_sign_out' %>",
                     :after => "<!-- Beautiful_scaffold - Signin - Do not remove -->\n")

    # Modal (forget password)
    inject_into_file("#{view_path}layouts/beautiful_layout.html.erb",
                     "    <%= render :partial => 'layouts/forget_password' %>",
                     :after => "<!-- Beautiful_scaffold - Modal - Do not remove -->\n")
    inject_into_file("#{view_path}layouts/beautiful_layout.html.erb",
                     "    <%= render :partial => 'layouts/register_form' %>",
                     :after => "<!-- Beautiful_scaffold - Modal - Do not remove -->\n")

  end

  def install_cancan
    gem("cancan")

    inside Rails.root do
      run "bundle install"
    end

    generate("cancan:ability")

    inject_into_file("app/models/ability.rb", "
      if not user.nil? then
        if user.id == 1 then
          can :manage, :all
        end
      end\n", :after => "def initialize(user)\n")

    # current_user method need for CanCan
    current_user_method = ""
    if model != "user" then
      current_user_method = "
  def current_user
    current_#{model}
  end"
    end

    # Exception for AccessDenied
    inject_into_file("app/controllers/application_controller.rb", "
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  #{current_user_method}
  ", :after => "class ApplicationController < ActionController::Base\n")

    # Access controlled by CanCan (in beautiful_scaffold)
    inject_into_file("app/controllers/application_controller.rb", "#", :before => "before_action :authenticate_#{model}!, :except => [:dashboard]")
  end
end
