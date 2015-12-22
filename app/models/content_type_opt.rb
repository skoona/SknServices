# == Schema Information
#
# Table name: content_type_opts
#
#  id          :integer          not null, primary key
#  value       :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ContentTypeOpt < ActiveRecord::Base
  has_and_belongs_to_many :content_types, :join_table => :content_options

  validates_presence_of :value, :description
end
