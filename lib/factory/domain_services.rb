# ./lib/factory/domain_services.rb
# Replace Controller helpers with Factory Object for DomainServices

module Factory
  class DomainServices

    attr_accessor :factory, :user

    def initialize(params={})
      [:factory].each do |k|
        send("#{k}=", nil)
        send("#{k}=", params[k]) if params.key?(k)
      end
      raise ArgumentError,
            "Factory::DomainServices: for #{self},  Missing required initialization param(s) (#{'factory' if @factory.nil?} #{'user' if @user.nil?} for #{self})" unless @factory.present?
    end

    def current_user
      user || factory.current_user
    end

  end
end