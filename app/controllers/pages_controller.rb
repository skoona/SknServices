# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class PagesController < ApplicationController

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
  def details_architecture
  end

  def about
  end

  # overloaded method: display page, and act on registry
  def details_sysinfo
    access_service.reload_access_registry if 'xml'.eql?( params[:id] )
  end


private

end
