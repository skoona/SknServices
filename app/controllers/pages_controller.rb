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
    flash.now[:notice] = case params[:id]
                       when 'xml'
                         access_service.reload_access_registry
                         "AccessRegistry Reloaded"
                       when 'purge'
                         count = service_factory.purge_storage_objects((Time.now - 10.minutes).to_i)
                         "ObjectStorageContainer Purged #{count} Items"
                     end
  end


private

end
