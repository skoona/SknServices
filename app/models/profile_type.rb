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

class ProfileType < ApplicationRecord
  has_one :content_profile

  validates_presence_of :name, :description

  def self.option_selects
    options = []
    self.find_each do |pts|
      options << [pts.name, pts.id, {data: {description: pts.description}}]
    end
    options
  end

  def self.option_selects_with_desc
    options = []
    self.find_each do |pts|
      options << ["#{pts.name} : #{pts.description}", pts.id]
    end
    options
  end

end
