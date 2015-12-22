# == Schema Information
#
# Table name: content_type_opts
#
#  id              :integer          not null, primary key
#  value           :string
#  description     :string
#  content_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentTypeOpt < ActiveRecord::Base
  belongs_to :content_type, inverse_of: :content_type_opts

  validates_presence_of :value, :description
end
