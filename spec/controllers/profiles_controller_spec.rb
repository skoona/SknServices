# spec/controllers/profiles_controller_spec.rb

describe ProfilesController, "Verify the basic API is working." do
  let!(:user) {Secure::UserProfile.page_user("eptester")}
  before :each do
    sign_in(user, scope: :access_profile)
    @request.host = 'www.example.com'
  end

  describe "#accessible_content are valid" do
    it "Access Request returns http success" do
      get :accessible_content, {"user_options"=>["Manager"], "name"=>"Services.Action.Admin.ContentProfile",
                  "description"=>"Administer Authorization Content Profile",
                  "type"=>"EmployeePrimary", "username"=>"eptester", "controller"=>"profiles",
                  "id"=>"access"}
      expect(assigns(:page_controls)).to be_a(SknUtils::PageControls)
      expect(assigns(:page_controls).package.success).to be true
      expect(response).to be_success
      expect(response).to be
    end
    it "Content Request returns http success" do
      get :accessible_content, {"user_options"=>["Manager"], "description"=>"Determine which agency documents can be seen",
                 "username"=>"skoona", "topic_value"=>"Agency", "content_value"=>["68601", "68602", "68603"],
                 "content_type"=>"Commission", "content_type_description"=>"Monthly Commission Reports and Files",
                 "topic_type"=>"Agency", "topic_type_description"=>"Agency Actions", "id"=>"content"}
      expect(assigns(:page_controls)).to be_a(SknUtils::PageControls)
      expect(assigns(:page_controls).package.success).to be true
      expect(response).to be_success
      expect(response).to be
    end
  end

end
