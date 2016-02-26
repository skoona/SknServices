##
# lib/repository/repository_base.rb
#
# Base for Entity Repositories
##
# Ref: http://blog.8thlight.com/mike-ebert/2013/03/23/the-repository-pattern.html
#

module Repository
  class RepositoryBase
    
    def initialize(db)
      @db = db
    end

    def create(attributes)
      convert(repository.create(attributes))
    end

    def find_by_id(id)
      convert(repository.find_by_id(id.to_i))
    end

    def all
      repository.all.map { |e| convert(e) }
    end

    def count
      repository.all.count
    end

    def convert(data)
      @db.adapter.convert(model_class, data)
    end

    def model_class
      raise NotImplementedError
    end

    def repository
      raise NotImplementedError
    end
    
  end # class
end # module