require 'rails_helper'

RSpec.describe "topic_type_opts/show", type: :view do
  before(:each) do
    @topic_type_opt = assign(:topic_type_opt, TopicTypeOpt.create!(
      :value => "Value",
      :description => "Description",
      :topic_type => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Value/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(//)
  end
end
