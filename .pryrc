
Pry::Commands.create_command "get-service-registry" do
  description "Gain access to default ServiceRegistry"

  def process
    u = Secure::UserProfile.find_and_authenticate_user("developer","developer99");

    app = Rails.application
    session = ActionDispatch::Integration::Session.new(app)
    session.extend(app.routes.url_helpers)
    session.extend(app.routes.mounted_helpers)
  	session.get '/pages/home';
  	c = session.instance_variable_get(:@controller);
  	c.warden.set_user(u);

  	$service = c.service_registry
  end
end