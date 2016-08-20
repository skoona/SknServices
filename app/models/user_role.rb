# == Schema Information
#
# Table name: user_roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserRole < ApplicationRecord
  has_and_belongs_to_many :user_group_roles, join_table: :user_group_roles_user_roles

  validates_uniqueness_of :name

  def self.select_options
    self.all().map do |r|
      [r.name, r.id, {'data-description': r.description}]
    end
  end

  def role_info
    [name, id, {'data-description': description}]
  end
end
