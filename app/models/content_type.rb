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
  has_and_belongs_to_many :content_type_opts, :join_table => :content_options
  has_one :content_profile_entry, inverse_of: :content_type

  validates_presence_of :name, :description
end
