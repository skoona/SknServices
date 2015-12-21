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
    role_groups             ["InternalStaff", "Services.Action.ResetPassword"]
    roles                   ["EmployeeSecondary",
                             "Users.Action.Update",
                             "Users.Action.Edit",
                             "Users.Action.Read",
                             "Service.Action.ResetPassword"]

    factory :support do
      role_groups             ["InternalStaff", "Services.Action.ResetPassword"]
      roles                   ["EmployeeSecondary",
                               "Users.Action.Update",
                               "Users.Action.Edit",
                               "Users.Action.Read",
                               "Service.Action.ResetPassword"]
    end

    factory :manager do
      role_groups             ["InternalStaff", "Services.Action.Admin", "Developer.Access.Status"]
      roles                   ["EmployeePrimary"]
    end
  end

end
