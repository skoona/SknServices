class PasswordResetsController < ApplicationController
	
  def new
		@user = User.new
  end

  def create
		@page_controls = access_service.reset_requested(params.to_unsafe_h)
		redirect_to home_pages_url, notice: @page_controls.message
  end

  def edit
		@user = User.find_by(password_reset_token: params[:id])
  end

  def update
		@page_controls = access_service.reset_password(params.to_unsafe_h)
		if @page_controls.success
			redirect_to signin_url, notice: @page_controls.message
		else
			@user = @page_controls.user
			flash.now.alert = @page_controls.message 
			render :edit 
		end
  end

end
