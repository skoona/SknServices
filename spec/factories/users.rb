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

# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :user do
    username                {Faker::Internet.user_name}
    name                    {Faker::Name.name}
    email                   { "#{username}@#{Faker::Internet.domain_name}".downcase }
    remember_token          "MyString"
    password                "foobar"
    password_confirmation   "foobar"
    password_reset_token    "tokenx"
    password_reset_date     {Time.zone.now}
    assigned_groups             ["EmployeeSecondary"]
    assigned_roles          ["Users.Action.Update",
                             "Users.Action.Edit",
                             "Users.Action.Read",
                             "Service.Action.ResetPassword"]
    roles                    ["Users.Action.Update",
                             "Users.Action.Edit",
                             "Users.Action.Read",
                             "Service.Action.ResetPassword"]

    factory :support do
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
      assigned_groups             ["EmployeePrimary"]
      assigned_roles          ["Services.Action.Admin",
                               "Services.Action.Developer"]
      roles                   ["Services.Action.Admin",
                               "Services.Action.Developer"]
    end
  end

end
