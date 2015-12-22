# == Schema Information
#
# Table name: content_options
#
#  id                  :integer          not null, primary key
#  content_type_id     :integer
#  content_type_opt_id :integer
#

class ContentOption < ActiveRecord::Base
  belongs_to :content_type
  belongs_to :content_type_opt
end
