require 'rails_helper'

RSpec.describe "topic_types/show", type: :view do
  before(:each) do
    @topic_type = assign(:topic_type, TopicType.create!(
      :name => "Name",
      :description => "Description",
      :value_based_y_n => "Value Based Y N"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Value Based Y N/)
  end
end
