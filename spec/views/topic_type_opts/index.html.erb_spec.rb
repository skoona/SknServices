require 'rails_helper'

RSpec.describe "topic_type_opts/index", type: :view do
  before(:each) do
    assign(:topic_type_opts, [
      TopicTypeOpt.create!(
        :value => "Value",
        :description => "Description",
        :topic_type => nil
      ),
      TopicTypeOpt.create!(
        :value => "Value",
        :description => "Description",
        :topic_type => nil
      )
    ])
  end

  it "renders a list of topic_type_opts" do
    render
    assert_select "tr>td", :text => "Value".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
