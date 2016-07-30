# == Schema Information
#
# Table name: profile_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProfileType < ActiveRecord::Base
  has_one :content_profile

  validates_presence_of :name, :description

  def self.option_selects
    options = []
    self.find_each do |pts|
      options << [pts.name, pts.id, {'data-description'.to_sym => pts.description}]
    end
    options
  end

end
