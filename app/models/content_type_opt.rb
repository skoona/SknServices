# == Schema Information
#
# Table name: content_type_opts
#
#  id              :integer          not null, primary key
#  value           :string(255)
#  description     :string(255)
#  type_name       :string(255)
#  content_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentTypeOpt < ApplicationRecord
  belongs_to :content_type, inverse_of: :content_type_opts

  validates_presence_of :value, :description

  before_create {|opts|
    opts.value.gsub!(/\s+/,'')
  }

  def self.option_selects_with_desc(name)
    options = []
    self.where(type_name: name).find_each do |r|
      options << [ "#{r.value} : #{r.description}", r.id, {data: {description: r.description}}]
    end
    options
  end

end
