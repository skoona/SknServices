require 'rails_helper'

RSpec.describe "content_types/edit", type: :view do
  before(:each) do
    @content_type = assign(:content_type, ContentType.create!(
      :name => "MyString",
      :description => "MyString",
      :value_data_type => "MyString"
    ))
  end

  it "renders the edit content_type form" do
    render

    assert_select "form[action=?][method=?]", content_type_path(@content_type), "post" do

      assert_select "input#content_type_name[name=?]", "content_type[name]"

      assert_select "input#content_type_description[name=?]", "content_type[description]"

      assert_select "input#content_type_value_data_type[name=?]", "content_type[value_data_type]"
    end
  end
end
