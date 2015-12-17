# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  username             :string(255)
#  name                 :string(255)
#  email                :string(255)
#  password_digest      :string(255)
#  remember_token       :string(255)
#  password_reset_token :string(255)
#  password_reset_date  :datetime
#  role_groups          :string(255)
#  roles                :string(255)
#  file_access_token    :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class User < ActiveRecord::Base
  include Secure::AccessControl
  include Secure::AuthenticationUserHelper

  has_secure_password

  before_save { |user|
    user.email = user.email.downcase
    user.username = user.username.downcase
    user.generate_token(:remember_token)
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


  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def need_password?
    self.password.present? || new_record?
  end

end
