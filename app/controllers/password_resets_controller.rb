##
# <root>/app/strategy/use_cases/password_reset_use_case.rb
#
class PasswordResetsController < ApplicationController
	
  def new
		wrap_html_response  password_reset_use_case.empty_user_to_get_username, root_url
  end

  def create
		wrap_html_and_redirect_response  password_reset_use_case.reset_requested(params.to_unsafe_h), home_pages_url
  end

  def edit
		wrap_html_response  password_reset_use_case.edit_new_password(params[:id]), root_url
  end

  def update
		@page_controls = password_reset_use_case.reset_password(params.to_unsafe_h)
		if @page_controls.success
			redirect_to signin_url, notice: @page_controls.message
		else
			@user = @page_controls.user
			flash.now.alert = @page_controls.message 
			render :edit 
		end
  end

end
