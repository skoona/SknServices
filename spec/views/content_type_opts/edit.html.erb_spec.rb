require 'rails_helper'

RSpec.describe "content_type_opts/edit", type: :view do
  before(:each) do
    @content_type_opt = assign(:content_type_opt, ContentTypeOpt.create!(
      :value => "MyString",
      :description => "MyString",
      :content_type => nil
    ))
  end

  it "renders the edit content_type_opt form" do
    render

    assert_select "form[action=?][method=?]", content_type_opt_path(@content_type_opt), "post" do

      assert_select "input#content_type_opt_value[name=?]", "content_type_opt[value]"

      assert_select "input#content_type_opt_description[name=?]", "content_type_opt[description]"

      assert_select "input#content_type_opt_content_type_id[name=?]", "content_type_opt[content_type_id]"
    end
  end
end
