require 'rails_helper'

RSpec.describe "topic_type_opts/new", type: :view do
  before(:each) do
    assign(:topic_type_opt, TopicTypeOpt.new(
      :value => "MyString",
      :description => "MyString",
      :topic_type => nil
    ))
  end

  it "renders new topic_type_opt form" do
    render

    assert_select "form[action=?][method=?]", topic_type_opts_path, "post" do

      assert_select "input#topic_type_opt_value[name=?]", "topic_type_opt[value]"

      assert_select "input#topic_type_opt_description[name=?]", "topic_type_opt[description]"

      assert_select "input#topic_type_opt_topic_type_id[name=?]", "topic_type_opt[topic_type_id]"
    end
  end
end
