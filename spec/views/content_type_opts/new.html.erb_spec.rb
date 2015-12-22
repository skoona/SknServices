require 'rails_helper'

RSpec.describe "content_type_opts/new", type: :view do
  before(:each) do
    assign(:content_type_opt, ContentTypeOpt.new(
      :value => "MyString",
      :description => "MyString",
      :content_type => nil
    ))
  end

  it "renders new content_type_opt form" do
    render

    assert_select "form[action=?][method=?]", content_type_opts_path, "post" do

      assert_select "input#content_type_opt_value[name=?]", "content_type_opt[value]"

      assert_select "input#content_type_opt_description[name=?]", "content_type_opt[description]"

      assert_select "input#content_type_opt_content_type_id[name=?]", "content_type_opt[content_type_id]"
    end
  end
end
