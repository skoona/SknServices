##
#
#
# Warden Helpers
# login_as(user, opts = {})
# logout(*scopes)
#
module AuthenticationHelpers

  #def current_user
  #  @user
  #end

  # [warden.] login_as(user_object, :default)   -- should without the bypass stuff
  # logout(:default)

  def bypass_warden_for_views(user, controller_object)
    allow(controller_object).to receive(:current_user) {user}    
    allow(controller_object).to receive(:authenticated?) {true}
    allow(controller_object).to receive(:logged_in?) {true}        
    warden = double(:foo, :message => "", :authenticated? => true, :login_required => true ).as_null_object
    allow(controller_object).to receive(:warden) {warden}
  end

  def bypass_warden(user, controller_object)
    allow(controller_object).to receive(:login_required) {true}
    allow(controller_object).to receive(:current_user) {user}    
    allow(controller_object).to receive(:authenticated?) {true}
    allow(controller_object).to receive(:logged_in?) {true}        
    warden = double(:foo, :message => "", :authenticated? => true ).as_null_object
    allow(controller_object).to receive(:warden) {warden}
  end
end
