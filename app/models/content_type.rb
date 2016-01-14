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
  has_and_belongs_to_many :content_type_opts, join_table: :content_options, inverse_of: :content_types
  has_and_belongs_to_many :content_profile_entries, inverse_of: :content_types, join_table: :join_contents

  accepts_nested_attributes_for :content_type_opts, allow_destroy: true, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :name, :description

  def self.ct_options_selects
    self.all.map do |cts|
      [cts.name, cts.id, {data_description: cts.description}]
    end
  end

  # options_for_select(ct_instance.options_selects, selected)   -- multi selections
  def options_selects
    content_type_opts.map do |opts|
      [opts.value, opts.id, {data_description: opts.description}]
    end
  end

end
