# spec/controllers/profiles_controller_spec.rb

describe ProfilesController, "Verify the basic API is working." do
  let!(:user) { user_eptester()}

  before :each do
    sign_in(user, scope: :access_profile)
    # @request.host = 'www.example.com'
  end

  describe "#accessible_content are valid" do
    it "Access Request returns http success" do
      get :api_accessible_content, params: {"user_options"=>["Manager"], "name"=>"Services.Action.Admin.ContentProfile",
                  "description"=>"Administer Authorization Content Profile",
                  "type"=>"EmployeePrimary", "username"=>"eptester", "controller"=>"profiles",
                  "id"=>"access"}
      expect(assigns(:page_controls)).to be_a(SknUtils::NestedResult)
      expect(assigns(:page_controls).package.success).to be true
      expect(response).to be_success
      expect(response).to be
    end
    it "Content Request returns http success" do
      get :api_accessible_content, params: {"user_options"=>["Manager"], "description"=>"Determine which branch documents can be seen",
                 "username"=>"developer", "topic_value"=>"Branch", "content_value"=>["68601", "68602", "68603"],
                 "content_type"=>"Commission", "content_type_description"=>"Monthly Commission Reports and Files",
                 "topic_type"=>"Branch", "topic_type_description"=>"Branch Actions", "id"=>"content"}
      expect(assigns(:page_controls)).to be_a(SknUtils::NestedResult)
      expect(assigns(:page_controls).package.success).to be true
      expect(response).to be_success
      expect(response).to be
    end
    it "Access Request returns http success" do
      get :api_accessible_content, params: {"user_options"=>["Manager"], "description"=>"Determine which branch documents can be seen",
                                "username"=>"developer", "topic_value"=>"Branch", "content_value"=>["68601", "68602", "68603"],
                                "content_type"=>"Commission", "content_type_description"=>"Monthly Commission Reports and Files",
                                "topic_type"=>"Branch", "topic_type_description"=>"Branch Actions", "id"=>"access"}
      expect(assigns(:page_controls)).to be_a(SknUtils::NestedResult)
      expect(assigns(:page_controls).package.success).to be true
      expect(response).to be_success
      expect(response).to be
    end
  end

end
