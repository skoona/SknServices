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

class ContentType < ActiveRecord::Base
  has_many :content_type_opts, inverse_of: :content_type, :dependent => :destroy

  accepts_nested_attributes_for :content_type_opts, allow_destroy: true, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :name, :description

  def self.options_selects
    self.all.map do |cts|
      [cts.name, cts.id, {'data-description'.to_sym => cts.description}]
    end
  end

  # options_for_select(ct_instance.options_selects, selected)   -- multi selections
  def options_selects
    content_type_opts.map do |opts|
      [opts.value, opts.id, {'data-description'.to_sym => opts.description}]
    end
  end

end
