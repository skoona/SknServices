module Repo
  module MemoryRepository
    class UserRepository
  
      def initialize
        @records = {}
        @id = 1
      end
   
      def model_class
        Repo::MemoryRepository::User
      end
   
      def new(attributes = {})
        model_class.new(attributes)
      end
   
      def save(object)
        object.id = @id
        @records[@id] = object
        @id += 1
        return object
      end
   
      def find_by_id(n)
        @records[n.to_i]
      end
    end # class
  end # module
end # module
