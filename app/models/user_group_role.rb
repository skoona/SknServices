# == Schema Information
#
# Table name: user_group_roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  group_type  :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserGroupRole < ApplicationRecord
  has_and_belongs_to_many :user_roles, join_table: :user_group_roles_user_roles

  validates_uniqueness_of :name

  accepts_nested_attributes_for :user_roles, allow_destroy: true, reject_if: lambda {|attributes| attributes['name'].blank?}

  def self.list_user_roles(group_role_name, wdesc=false)
    rec = find_by(name: group_role_name)
    rec.nil?  ? [] : rec.user_role_names
  end

  def self.select_options
    self.all().map do |r|
      [r.name, r.id, {'data-description': r.description}]
    end
  end

  # used by UserProfile to render roles for user setup.
  def user_role_names
    self.user_roles.map(&:name)
  end

end
