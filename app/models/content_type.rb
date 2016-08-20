# == Schema Information
#
# Table name: content_types
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  description     :string(255)
#  value_data_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentType < ApplicationRecord
  has_many :content_type_opts, inverse_of: :content_type, :dependent => :destroy

  accepts_nested_attributes_for :content_type_opts, allow_destroy: true, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :name, :description

  def self.option_selects
    options = []
    self.find_each do |cts|
      options << [cts.name, cts.id, {data: {description: cts.description, opts: cts.option_selects.to_json}}]
    end
    options
  end
  def self.option_selects_by_type(name)
    options = []
    self.where(name: name).find_each do |cts|
      options << [cts.name, cts.id, {data: {description: cts.description, opts: cts.option_selects}}]
    end
    options
  end

  # options_for_select(ct_instance.option_selects, selected)   -- multi selections
  def option_selects
    content_type_opts.map do |opts|
      [opts.value, opts.id, {data: {description: opts.description}}]
    end
  end

end
