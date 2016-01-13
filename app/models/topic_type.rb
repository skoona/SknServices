# == Schema Information
#
# Table name: topic_types
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :string
#  value_based_y_n :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TopicType < ActiveRecord::Base
  has_and_belongs_to_many :topic_type_opts, :join_table => :topic_options
  has_and_belongs_to_many  :content_profile_entries, inverse_of: :topic_types, :join_table => :join_topics

  accepts_nested_attributes_for :topic_type_opts, allow_destroy: true, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :name, :description

  def self.tt_options_selects
    self.all.map do |tts|
      [tts.name, tts.id, {data_description: tts.description}]
    end
  end

  # options_for_select(tt_instance.options_selects, selected)  -- single selection
  def options_selects
    topic_type_opts.map do |opts|
      [opts.value, opts.id, {data_description: opts.description}]
    end
  end

end
