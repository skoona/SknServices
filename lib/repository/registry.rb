##
# lib/respository/registry.rb
#
# Ref: https://blog.8thlight.com/mike-ebert/2013/03/23/the-repository-pattern.html
##
# Respository::Registry.register(:user, Repository::UserRepository.new)
# @user = Repository::Registry.for(:user).find_by_id(params[:id])
##

module Respository
  class Registry
    
    def self.register(type, repo)
      repositories[type] = repo
    end
    def self.unregister(type)
      repositories.delete(type)
    end

    def self.repositories
      @repositories ||= {}
    end
   
    def self.for(type)      
      repositories[type]
    end
    
  end # class
end # module
