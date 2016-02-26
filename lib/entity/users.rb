##
# lib/entity/users.rb
#
# User Entity Object

module Users
  
  class User
    attr_reader :id, :name, :uuid
    
  end
  
  class Repository < Repository::RepositoryBase
    
    def create_for(user)
      obj = create({user_id: user.id})
      obj
    end
    
    def find_all_by_user_id(user_id)
      repository.where(user_id: user_id).map do |obj|
        convert(obj)
      end
    end

    def model_class
      Users::User
    end

    def repository
      @db.user
    end    
  end
  
end