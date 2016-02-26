##
# lib/repository/user_repository.rb
#
# Ref: https://blog.8thlight.com/mike-ebert/2013/03/23/the-repository-pattern.html
#

module Repository
  class UserRepository
    def initialize
      @records = {}
      @id = 1
    end
 
    def model_class
      MemoryRepository::User
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
  end
end
