# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  username                 :string(255)
#  name                     :string(255)
#  email                    :string(255)
#  password_digest          :string(255)
#  remember_token           :string(255)
#  password_reset_token     :string(255)
#  password_reset_date      :datetime
#  assigned_groups          :string(4096)
#  roles                    :string(4096)
#  active                   :boolean          default(TRUE)
#  file_access_token        :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  person_authenticated_key :string(255)
#  assigned_roles           :string(4096)
#  remember_token_digest    :string(255)
#  user_options             :string(4096)
#

class User < ActiveRecord::Base
  include Secure::UserProfileHelper

  has_secure_password

  before_create {|user|
    user.generate_unique_token(:person_authenticated_key)   # Never Changes
    user.regenerate_remember_token!   # :remember_token Change by reset or any update
    user.active = true
    user.user_options = [user.user_options] unless user.user_options.is_a?(Array)
  }


  before_save { |user|
    user.roles = [user.roles].flatten unless user.roles.is_a?(Array)
    user.assigned_roles = [user.assigned_roles].flatten unless user.assigned_roles.is_a?(Array)
    user.assigned_groups = [user.assigned_groups].flatten unless user.assigned_groups.is_a?(Array)
    user.email = user.email.downcase
    user.username = user.username.downcase
    user.user_options = [user.user_options] unless user.user_options.is_a?(Array)
  }

  serialize :roles, Array
  serialize :assigned_groups, Array
  serialize :assigned_roles, Array
  serialize :user_options, Array

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
    self.name
  end

  def need_password?
    self.password.present? || new_record?
  end

end
