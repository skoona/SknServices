# == Schema Information
#
# Table name: content_type_opts
#
#  id          :integer          not null, primary key
#  value       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ContentTypeOpt < ActiveRecord::Base
  has_and_belongs_to_many :content_types, join_table: :content_options, inverse_of: :content_type_opts

  validates_presence_of :value, :description

  def self.options_selects
    self.all.map do |r|
      [r.value, r.id, {data_description: r.description}]
    end
  end

end
