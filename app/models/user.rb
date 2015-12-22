# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  username             :string
#  name                 :string
#  email                :string
#  password_digest      :string
#  remember_token       :string
#  password_reset_token :string
#  password_reset_date  :datetime
#  role_groups          :string
#  roles                :string
#  active               :boolean          default(TRUE)
#  file_access_token    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class User < ActiveRecord::Base
  include Secure::AccessControl
  include Secure::AuthenticationUserHelper

  has_secure_password

  # before_create {|user|
  #   user.generate_unique_token(:person_authenticated_key)   # Never Changes
  # }

  before_save { |user|
    user.email = user.email.downcase
    user.username = user.username.downcase
    user.generate_unique_token(:remember_token)   # Change with every update
  }

  serialize :roles, Array
  serialize :role_groups, Array

  validates(:role_groups, :roles, presence: true)
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
