# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = {
    username:              "skoona",
    name:                  "James Scott",
    email:                 "skoona@gmail.com",
    password:                "developer99",
    password_confirmation:   "developer99",
    role_groups:             ["InternalStaff"],
    roles:                   ["EmployeePrimary","Developer.Access.Status"]
}

User.delete_all
User.create(user)
