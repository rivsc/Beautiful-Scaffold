# encoding : utf-8
class BeautifulCancancanGenerator < Rails::Generators::Base
  require_relative 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  #argument :model, :type => :string, :desc => "Name of model (ex: user)"

  def install_cancancan
    model = "user"

    gem("cancancan", "3.2.1")

    Bundler.with_unbundled_env do
      run "bundle install"
    end

    # Because generators doesn't work !
    copy_file("app/models/ability.rb")

    # Why that doesn't work... boring...
    #puts rails_command("generate cancan:ability", capture: true)
    # Why that doesn't work too... boring...
    #generate("cancan:ability")

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
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to root_url, :alert => exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end
  #{current_user_method}
  ", :after => "class ApplicationController < ActionController::Base\n")

    # Access controlled by CanCanCan (in beautiful_scaffold)
    inject_into_file("app/controllers/application_controller.rb", "#", :before => "before_action :authenticate_#{model}!, :except => [:dashboard]")
  end
end
