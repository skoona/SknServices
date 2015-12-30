# == Schema Information
#
# Table name: user_group_roles
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  group_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserGroupRole < ActiveRecord::Base
  has_and_belongs_to_many :user_roles, join_table: :user_group_roles_user_roles

  validates_uniqueness_of :name

  def self.list_user_roles(group_role_name, wdesc=false)
    rec = find_by(name: group_role_name)
    rec.nil?  ? [] : wdesc ? rec.role_descriptions(group_role_name) : rec.user_role_names
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    raise e
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
