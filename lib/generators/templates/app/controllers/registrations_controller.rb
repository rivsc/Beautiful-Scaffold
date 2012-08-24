# encoding : utf-8
class RegistrationsController < Devise::RegistrationsController
  def create
    super
    if resource.id.nil? then
      self.instance_variable_set(:@_response_body, nil)
      @opened_modal = "#modal-register-form"
      render "beautiful/dashboard", :layout => "beautiful_layout", :location => root_path
    end
  end
end