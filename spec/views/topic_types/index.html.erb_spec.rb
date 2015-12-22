require 'rails_helper'

RSpec.describe "topic_types/index", type: :view do
  before(:each) do
    assign(:topic_types, [
      TopicType.create!(
        :name => "Name",
        :description => "Description",
        :value_based_y_n => "Value Based Y N"
      ),
      TopicType.create!(
        :name => "Name",
        :description => "Description",
        :value_based_y_n => "Value Based Y N"
      )
    ])
  end

  it "renders a list of topic_types" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Value Based Y N".to_s, :count => 2
  end
end
