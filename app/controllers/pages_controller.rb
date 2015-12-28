# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class PagesController < ApplicationController

  before_action :honor_flash

  def home
  end

  def learn_more
  end
  def details_content
  end
  def details_access
  end
  def details_auth
  end
  def details_model
  end

  def about
  end

  def developer
  end

  def unauthenticated
  end

private

  def honor_flash
    flash.now.alert = warden.message if warden.message.present?
  end
end
