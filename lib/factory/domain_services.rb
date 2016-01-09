# ./lib/factory/domain_services.rb
# Replace Controller helpers with Factory Object for DomainServices
#
# The
#
module Factory
  class DomainServices

    attr_accessor :factory

    def initialize(params={})
      @factory = params[:factory] || params[:controller]
      @user ||= @factory.current_user unless @factory.nil?
      raise ArgumentError, "Factory::DomainServices: for #{self.class.name}.  Missing required initialization param(factory)" if @factory.nil?
    end

    def current_user
      @user ||= @factory.current_user
    end

  end
end
