# lib/factory/services_base.rb
#
# Common Base for all Services oriented Classes, without Domains
#

module Factory
  class ServicesBase
    include Factory::ObjectStorageService

    def self.inherited(klass)
      klass.send(:oscs_set_context=, klass.name)
      Rails.logger.debug("Factory::ServicesBase => #{self.name} inherited By #{klass.name}")
    end

  end
end


