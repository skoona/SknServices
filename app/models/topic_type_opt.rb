# == Schema Information
#
# Table name: topic_type_opts
#
#  id          :integer          not null, primary key
#  value       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TopicTypeOpt < ActiveRecord::Base
  has_and_belongs_to_many :topic_types, :join_table => :topic_options, reject_if: lambda {|attributes| attributes['value'].blank?}

  validates_presence_of :value, :description

  before_create {|opts|
    opts.value.gsub!(/\s+/,'')
  }

  def self.options_selects
    self.all.map do |r|
      [r.value, r.id, {'data-description'.to_sym => r.description}]
    end
  end

end
