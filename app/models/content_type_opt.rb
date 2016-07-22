# == Schema Information
#
# Table name: content_type_opts
#
#  id              :integer          not null, primary key
#  value           :string(255)
#  description     :string(255)
#  content_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentTypeOpt < ActiveRecord::Base
  belongs_to :content_type

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
