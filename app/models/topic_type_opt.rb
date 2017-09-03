# == Schema Information
#
# Table name: topic_type_opts
#
#  id            :integer          not null, primary key
#  value         :string(255)
#  description   :string(255)
#  type_name     :string(255)
#  topic_type_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TopicTypeOpt < ApplicationRecord
  belongs_to :topic_type, inverse_of: :topic_type_opts

  validates_presence_of :value, :description

  before_create {|opts|
    opts.value.gsub!(/\s+/,'')
  }

  def self.option_selects_with_desc(name)
    options = []
    self.where(type_name: name).find_each do |r|
      options << ["#{r.value} : #{r.description}", r.id, {data: {description: r.description}}]
    end
    options
  end
  def self.member_option_selects_with_desc(name)
    options = []
    self.where(type_name: name).find_each do |r|
      options << ["#{r.value} : #{r.description}", r.value]
    end
    options
  end

end
