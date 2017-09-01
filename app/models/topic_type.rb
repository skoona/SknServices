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

class TopicType < ApplicationRecord
  has_many :topic_type_opts, inverse_of: :topic_type, :dependent => :destroy

  accepts_nested_attributes_for :topic_type_opts, allow_destroy: true, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :name, :description

  def self.option_selects
    options = []
    self.find_each do |tts|
      options << [tts.name, tts.id, {data: {description: tts.description, opts: tts.option_selects}}]
    end
    options
  end
  def self.option_selects_by_type(name)
    options = []
    self.where(name: name).find_each do |tts|
      options << [tts.name, tts.id, {data: {description: tts.description, opts: tts.option_selects}}]
    end
    options
  end

  # options_for_select(tt_instance.option_selects, selected)  -- single selection
  def option_selects
    topic_type_opts.map do |opts|
      [opts.value, opts.id, {data: {description: opts.description}}]
    end
  end

end
