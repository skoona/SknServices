# == Schema Information
#
# Table name: content_options
#
#  id                  :integer          not null, primary key
#  content_type_id     :integer
#  content_type_opt_id :integer
#

FactoryGirl.define do
  factory :content_option do
    content_type nil
content_type_opt nil
  end

end
