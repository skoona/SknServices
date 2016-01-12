##
# lib/factory/domains_base.rb
#
# Common Base for all Domain-like objects
#
# The
#
module Factory
  class DomainsBase

    attr_accessor :factory

    def initialize(params={})
      @factory = params[:factory] || params[:controller]
      @user ||= @factory.current_user unless @factory.nil?
      raise ArgumentError, "Factory::DomainsBase: for #{self.class.name}.  Missing required initialization param(factory)" if @factory.nil?
    end

    def current_user
      @user ||= @factory.current_user
    end

  end
end
