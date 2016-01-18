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

class UserGroupRole < ActiveRecord::Base
  has_and_belongs_to_many :user_roles, join_table: :user_group_roles_user_roles

  validates_uniqueness_of :name

  def self.list_user_roles(group_role_name, wdesc=false)
    rec = find_by(name: group_role_name)
    rec.nil?  ? [] : rec.user_role_names
  end

  def self.select_options
    self.all().map do |r|
      [r.name, r.id, {data_description: r.description}]
    end
  end

  def user_role_names
    self.user_roles.map(&:name)
  end
  def role_descriptions(gname)
    results = []
    self.user_roles.map do |ur|
      results << {name: ur.name, description: ur.description, type: gname}
    end
    results
  end

end
