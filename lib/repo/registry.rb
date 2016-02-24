##
# lib/repo/registry.rb
#
# Collection/or of Repositories
##
# Ref: http://hawkins.io/2013/10/implementing_the_repository_pattern/
#      http://martinfowler.com/eaaCatalog/repository.html
#      http://alistair.cockburn.us/Hexagonal+architecture
#      http://www.slideshare.net/rdingwall/domain-driven-design-101
#      http://www.slideshare.net/mariam_hakobyan/ddd-quickly
#
# See: lib/repo/backend/in_memory_backend, lib/repo/delegation,  
#
#
module Repo
  class Registry
    
    def self.adapter
      @adapter
    end
  
    def self.adapter=(adapter)
      @adapter = adapter
    end
  
    def self.find(klass, id)
      adapter.find klass, id
    end
  
    def self.all(klass)
      adapter.all klass
    end
  
    def self.create(model)
      adapter.create(model)
    end
  
    def self.update(model)
      adapter.update(model)
    end
  
    def self.delete(model)
      adapter.delete model
    end

    def self.save(model)
      if model.id
        update model
      else
        create model
      end
    end
    
    def self.query(klass, selector)
      backend.query(klass, selector)
    end
    
  end # class
end # module