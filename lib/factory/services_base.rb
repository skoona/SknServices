# lib/factory/services_base.rb
#
# Common Base for all Services oriented Classes, without Domains
#

module Factory
  class ServicesBase
    include Factory::ObjectStorageService

    def self.inherited(klass)
      # self.class_variable_set(:@@object_storage_service_prefix, nil)
      # klass.singleton_class.class_variable_set(:@@object_storage_service_prefix, nil)
      # klass.singleton_class.class_variable_set(:@@object_storage_service_prefix, klass.name.to_s)
      Rails.logger.debug("Factory::ServicesBase => #{self.name} inherited By #{klass.name}")
    end

  end
end


