
Pry::Commands.create_command "get-service-factory" do
  description "Gain access to default ServiceFactory"

  def process
    u = Secure::UserProfile.find_and_authenticate_user("developer","developer99");

    app = Rails.application
    session = ActionDispatch::Integration::Session.new(app)
    session.extend(app.routes.url_helpers)
    session.extend(app.routes.mounted_helpers)
  	session.get '/pages/home';
  	c = session.instance_variable_get(:@controller);
  	c.warden.set_user(u);

  	$service = c.service_factory
  end
end