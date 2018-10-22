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
#  person_authentication_key :string(255)
#  assigned_roles           :string(4096)
#  remember_token_digest    :string(255)
#  user_options             :string(4096)
#

# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :user do
    username                {Faker::Internet.user_name}
    person_authentication_key {SecureRandom.hex(16)}
    name                    {Faker::Name.name}
    email                   { "#{username}@#{Faker::Internet.domain_name}".downcase }
    remember_token          {SecureRandom.urlsafe_base64}
    password                "foobar"
    password_confirmation   "foobar"
    password_reset_token    {SecureRandom.urlsafe_base64}
    password_reset_date     {Time.zone.now}
    user_options            ["Employee"]
    assigned_groups         ["EmployeeSecondary"]
    assigned_roles          ["Service.Action.ResetPassword"]
    roles                   ["Service.Action.ResetPassword"]

    factory :support do
      user_options            ["Support"]
      assigned_groups             ["EmployeeSecondary"]
      assigned_roles          ["Users.Action.Update",
                               "Users.Action.Edit",
                               "Users.Action.Read",
                               "Service.Action.ResetPassword"]
      roles                   ["Users.Action.Update",
                               "Users.Action.Edit",
                               "Users.Action.Read",
                               "Service.Action.ResetPassword"]
    end

    factory :manager do
      user_options            ["Manager"]
      assigned_groups          ["EmployeePrimary"]
      assigned_roles          ["Services.Action.Admin",
                               "Services.Action.Developer"]
      roles                   ["Services.Action.Admin",
                               "Services.Action.Developer"]
    end
  end

end
