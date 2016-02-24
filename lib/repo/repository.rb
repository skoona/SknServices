##
# lib/repo/repository.rb
#
# Collection/or of Repositories
##
# Ref: http://blog.8thlight.com/mike-ebert/2013/03/23/the-repository-pattern.html
#   See: repo/memory_repository/user_repository, repo/sql_repository/user_repository
##
#
#

module Repo
  class Repository
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