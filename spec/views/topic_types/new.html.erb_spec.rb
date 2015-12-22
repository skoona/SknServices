require 'rails_helper'

RSpec.describe "topic_types/new", type: :view do
  before(:each) do
    assign(:topic_type, TopicType.new(
      :name => "MyString",
      :description => "MyString",
      :value_based_y_n => "MyString"
    ))
  end

  it "renders new topic_type form" do
    render

    assert_select "form[action=?][method=?]", topic_types_path, "post" do

      assert_select "input#topic_type_name[name=?]", "topic_type[name]"

      assert_select "input#topic_type_description[name=?]", "topic_type[description]"

      assert_select "input#topic_type_value_based_y_n[name=?]", "topic_type[value_based_y_n]"
    end
  end
end
