##
# lib/respository/repository.rb
#
# Ref: https://blog.8thlight.com/mike-ebert/2013/03/23/the-repository-pattern.html
##
# Respository::Repository.register(:user, Repository::UserRepository.new)
# @user = Repository::Repository.for(:user).find_by_id(params[:id])
##

module Respository
  class Respository
    
    def self.register(type, repo)
      repositories[type] = repo
    end
   
    def self.repositories
      @repositories ||= {}
    end
   
    def self.for(type)      
      repositories[type]
    end
    
  end # class
end # module
