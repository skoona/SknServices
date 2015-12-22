# == Schema Information
#
# Table name: content_types
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :string
#  value_data_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentType < ActiveRecord::Base
  has_many :content_type_opts, inverse_of: :content_type
  has_one :content_profile_entry, inverse_of: :content_type

  validates_presence_of :name, :description
end
