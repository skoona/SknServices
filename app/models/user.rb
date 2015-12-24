# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  username                 :string
#  name                     :string
#  email                    :string
#  password_digest          :string
#  remember_token           :string
#  password_reset_token     :string
#  password_reset_date      :datetime
#  assigned_groups          :string
#  roles                    :string
#  active                   :boolean          default(TRUE)
#  file_access_token        :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  person_authenticated_key :string
#  assigned_roles           :string
#

class User < ActiveRecord::Base
  include Secure::UserAccessControl

  has_secure_password

  before_create {|user|
    user.generate_unique_token(:person_authenticated_key)   # Never Changes
  }


  before_save { |user|
    user.roles = [user.roles].flatten unless user.roles.is_a?(Array)
    user.assigned_roles = [user.assigned_roles].flatten unless user.assigned_roles.is_a?(Array)
    user.assigned_groups = [user.assigned_groups].flatten unless user.assigned_groups.is_a?(Array)
    user.email = user.email.downcase
    user.username = user.username.downcase
    user.generate_unique_token(:remember_token)   # Change with every update
  }

  serialize :roles, Array
  serialize :assigned_groups, Array
  serialize :assigned_roles, Array

  # validates(:assigned_groups, :roles, :assigned_roles, presence: true)
  validates(:name, presence: true, length: { maximum: 128 })
  validates(:username, presence: true, uniqueness: { case_sensitive: false })

  validates(:email, presence: true,
      format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
      uniqueness: { case_sensitive: false })

  # Automatically create the virtual attribute 'password_confirmation'.
  validates( :password, confirmation: true, length: { :within => 6..40 }, if: :need_password? )
  validates( :password_confirmation, presence: true, if: :need_password?)

  def display_name
    name
  end

  def generate_unique_token(column)
    # puts "#{self.class.name}.#{__method__} called for #{username}'s #{column}"
    Rails.logger.debug "#{self.class.name}.#{__method__} called for #{username}'s #{column}"
    begin
      self[column] = User.get_new_secure_token
    end while User.exists?(column => self[column])
  end

  def need_password?
    self.password.present? || new_record?
  end

end
