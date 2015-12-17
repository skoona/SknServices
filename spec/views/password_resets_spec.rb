# spec/views/password_resets_spec.rb
#
# This works because the view are all inline, or without imbedded partials
#

RSpec.describe "Password Resets View Collection " do
  let(:user_object) { FactoryGirl.create(:user) }

  before :each do
    bypass_warden_for_views(user_object, view)
    login_as(user_object)
    #  # force load of Specific View Helpers
    view.extend(ApplicationHelper)
  end

  it "#password_resets/new renders correctly. " do
    assign(:user, User.new())
    render :template => "password_resets/new"
    expect(view).to render_template :new
  end

  it "#password_resets/edit renders correctly. " do
    assign(:user, user_object)
    render :template => "password_resets/edit"
    expect(view).to render_template :edit
    expect(rendered).to_not include("can't be blank")
  end

  it "#password_resets/edit renders with errors. " do
    user_object.password_confirmation = ""
    user_object.save             # force loading of errors object
    assign(:user, user_object)
    render :template => "password_resets/edit"
    expect(view).to render_template :edit
    expect(rendered).to include("doesn&#39;t match Password")
  end

end
