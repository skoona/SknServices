# spec/views/password_resets_spec.rb
#
# This works because the view are all inline, or without imbedded partials
#

RSpec.describe "Password Resets View Collection " do
  let(:user_object) { FactoryGirl.create(:user) }
  
  before :each do
    login_as(user_object, scope: :access_profile)
    @usr_obj = SknUtils::NestedResult.new ({ success: true, user: user_object, message: ""})
  end

  it "#password_resets/new renders correctly. " do
    assign(:page_controls, @usr_obj)
    render :template => "password_resets/new"
    expect(view).to render_template :new
  end

  it "#password_resets/edit renders correctly. " do
    assign(:page_controls, @usr_obj)
    render :template => "password_resets/edit"
    expect(view).to render_template :edit
    expect(rendered).to_not include("can't be blank")
  end

  it "#password_resets/edit renders with errors. " do
    user_object.password_confirmation = ""
    user_object.save             # force loading of errors object
    assign(:page_controls, @usr_obj)
    render :template => "password_resets/edit"
    expect(view).to render_template :edit
    expect(rendered).to include("doesn&#39;t match Password")
  end

end
