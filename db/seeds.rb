# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user1 = {
    username:              "skoona",
    name:                  "James Scott",
    email:                 "skoona@gmail.com",
    password:                "developer99",
    password_confirmation:   "developer99",
    role_groups:             ["InternalStaff"],
    roles:                   ["EmployeePrimary",
                              "Services.Action.Developer",
                              "Services.Action.Admin"]
}

user2 = {
    username:              "utester1",
    name:                  "SknService UTester1",
    email:                 "appdev@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["InternalStaff"],
    roles:                   ["EmployeeSecondary",
                              "Users.Action.Update",
                              "Users.Action.Edit",
                              "Users.Action.Read",
                              "Service.Action.ResetPassword"]
}

User.delete_all
u1 = User.create(user1)
u2 = User.create(user2)



##
#
# Authorization Content Profile Initialization
#
##

# {UUID/AgencyOwner} => [
#     PAK/ProfileType    {Commission/Agency/0034 => "CommRptID,CommCsvID,ExperRptID"},
#                        {Notification/Account/99 => "AdvCancel,Cancel"},
#                        {Operations/LicensedStates/USA => "21,30,34,45"}
# ]                      ContentType/TopicType/TopicTypeOpts => ContentTypeOpts

# requires: content_type_id
commission_cto = [
    {value: "68601", description: "Imageright Commision Document Type ID" },
    {value: "68602", description: "Imageright Commision CSV Document Type ID" },
    {value: "68603", description: "Imageright Agency Experience Document Type ID" }
]
# requires: content_type_id
notification_cto = [
    {value: "AdvCancel", description: "Advance Cancel" },
    {value: "FutCancel", description: "Future Cancel" },
    {value: "Cancel",    description: "Cancel" }
]
# requires: content_type_id
operations_cto = [
    {value: "21", description: "Michigan"},
    {value: "9",  description: "Ohio"},
    {value: "23", description: "Illinois"}
]

# requires: topic_type_id
agency_tto = [
   {value: "0034", description: "Some Agency Number"},
   {value: "1001", description: "Another Agency Number"}
]
# requires: topic_type_id
account_tto = [
   {value: "Agency", description: "All Agency Accounts"},
   {value: "Agent",  description: "All Agent Accounts"},
   {value: "None",   description: "All Agent Accounts"}
]
# requires: topic_type_id
LicensedStates_tto = [
   {value: "USA", description: "United States of America"},
   {value: "CAN", description: "Canada"}
]

ct  = [
  {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer"},
  {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String"},
  {name: "Operations",   description: "Business Operational Metric",          value_data_type: "Integer"}
]

tt  = [
  {name: "Agency",  description: "Agency Actions",  value_based_y_n: "Y"},
  {name: "Account", description: "Account Actions", value_based_y_n: "N"},
  {name: "LicensedStates", description: "Agent Actions", value_based_y_n: "Y"}
]

pt  = [
  {name: "AgencyPrimary",   description: "Agency Super User"},
  {name: "AgencySecondary", description: "Limited User"}
]

cpe = [
  {topic_value: "Commission",   content_value: [], description: '', content_type_id: '', topic_type_id: '', content_profile_id: ''},
  {topic_value: "Notification", content_value: [], description: '', content_type_id: '', topic_type_id: '', content_profile_id: ''},
  {topic_value: "Operations",   content_value: [], description: '', content_type_id: '', topic_type_id: '', content_profile_id: ''}
]

cp  = [{person_authenticated_key: u1.person_authenticated_key,
        authentication_provider: "BCrypt",
        username: u1.username,
        display_name: u1.display_name,
        email: u1.email,
        profile_type_id: 'AgencyPrimary'}
]











##
#
# Authorization Group and User level Roles
# Resource Sets
##

# requires user_group_role_id: ''
all_admin = [
    {name: "Services.Action.Admin", description: "Super User"},
    {name: "Services.Action.Primary", description: "Super User"},
    {name: "Services.Action.Developer", description: "Developer"}
]

all_users = [
    {name: "Services.Action.ResetPassword", description: "Reset Forgotten Password via EMail"},
    {name: "Users.Action.Read", description: "Read Action from main models for public"}
]

content_profile_p =
    {name: "Services.Action.Admin.ContentProfile",   description: "Administer Authorization Content Profile"}

content_profile_s =
    {name: "Services.Action.Use.ContentProfile", description: "Consume Authorization Content Profile"}

group_manage_p =
    {name: "Services.Action.Admin.UserAuthorizationGroups",   description: "Administer Authorization Group"}

group_manage_s =
    {name: "Services.Action.Use.UserAuthorizationGroups", description: "Consume Authorization Groups"}

user_manage_p =
    {name: "Services.Action.Admin.UserRecords",   description: "Administer User Records"}

user_manage_s =
    {name: "Services.Action.Use.UserRecords", description: "Consume User Records"}


all_groups = [
    {name: "EmployeePrimary",   group_type: "BMI Admin",    description: "BMI Admin User"},
    {name: "EmployeeSecondary", group_type: "BMI Limited",  description: "BMI Limited User"},
    {name: "AgencyPrimary",     group_type: "Agency Admin", description: "BMI Limited: Agency Admin User"},
    {name: "AgencySecondary",   group_type: "BMI Public",   description: "BMI Public: Agency Limited User"},
    {name: "VendorPrimary",     group_type: "BMI Limited",  description: "BMI Limited: Long Term"},
    {name: "VendorSecondary",   group_type: "BMI Public",   description: "BMI Public: Short Term"}
]

admin_collection =[]
admin_collection.push all_users
admin_collection.push all_admin
admin_collection.push user_manage_p
admin_collection.push group_manage_p
admin_collection.push content_profile_p

limited_collection =[]
limited_collection.push all_users
limited_collection.push user_manage_s
limited_collection.push group_manage_s
limited_collection.push content_profile_s

public_collection =[]
public_collection.push all_users
public_collection.push user_manage_s
public_collection.push group_manage_s
public_collection.push content_profile_s
