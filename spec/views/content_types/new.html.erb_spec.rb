require 'rails_helper'

RSpec.describe "content_types/new", type: :view do
  before(:each) do
    assign(:content_type, ContentType.new(
      :name => "MyString",
      :description => "MyString",
      :value_data_type => "MyString"
    ))
  end

  it "renders new content_type form" do
    render

    assert_select "form[action=?][method=?]", content_types_path, "post" do

      assert_select "input#content_type_name[name=?]", "content_type[name]"

      assert_select "input#content_type_description[name=?]", "content_type[description]"

      assert_select "input#content_type_value_data_type[name=?]", "content_type[value_data_type]"
    end
  end
end
