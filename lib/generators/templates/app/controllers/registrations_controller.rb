# encoding : utf-8
class RegistrationsController < Devise::RegistrationsController
  def create
    super
    if resource.id.nil? then
      self.instance_variable_set(:@_response_body, nil)
      @opened_modal = "#modal-register-form"
      if params[:path_to_redirect] then
        redirect_to params[:path_to_redirect]
      else
        render "beautiful/dashboard", :layout => "beautiful_layout", :location => root_path
      end
    end
  end
end