# == Schema Information
#
# Table name: topic_options
#
#  id                :integer          not null, primary key
#  topic_type_id     :integer
#  topic_type_opt_id :integer
#

FactoryGirl.define do
  factory :topic_option do
    topic_type nil
topic_type_opt nil
  end

end
