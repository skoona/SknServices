# ./lib/factory/domain_services.rb
# Replace Controller helpers with Factory Object for DomainServices

module Factory
  class DomainServices

    attr_accessor :factory, :user, :controller

    def initialize(params={})
      [:factory, :controller, :user].each do |k|
        send("#{k}=", nil)
        instance_variable_set("@#{k.to_s}",params[k])  if params.key?(k)
      end

      # Fixups based on how we were initialized
      @factory = @controller if factory.nil? and @controller.present?

      raise ArgumentError,
        %Q!Factory::DomainServices: for #{self.class.name}.  Missing required initialization
           param(s) (#{'factory' if factory.nil?} #{'user' if user.nil?})! unless factory.present?
    end

    def current_user
      @user || @factory.current_user
    end

  end
end
