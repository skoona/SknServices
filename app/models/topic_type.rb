# == Schema Information
#
# Table name: topic_types
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  description     :string(255)
#  value_based_y_n :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TopicType < ActiveRecord::Base
  has_many :topic_type_opts, inverse_of: :topic_type, :dependent => :destroy

  accepts_nested_attributes_for :topic_type_opts, allow_destroy: true, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :name, :description

  def self.options_selects
    self.all.map do |tts|
      [tts.name, tts.id, {'data-description'.to_sym => tts.description}]
    end
  end

  # options_for_select(tt_instance.options_selects, selected)  -- single selection
  def options_selects
    topic_type_opts.map do |opts|
      [opts.value, opts.id, {'data-description'.to_sym => opts.description}]
    end
  end

end
