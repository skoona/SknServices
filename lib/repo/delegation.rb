

module Repo
  module Delegation
    
    def save(record)
      Repo.save(record)
    end
  
    def all
      Repo.all object_class
    end
  
    def find(id)
      Repo.find object_class, id
    end
  
    def delete(record)
      Repo.delete record
    end
  
    def query(selector)
      Repo.query object_class, selector
    end
  
    private
    def object_class
      @object_class ||= self.to_s.match(/^(.+)Repo/)[1].constantize
    end
    
  end # module
end # module
