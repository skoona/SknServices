# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

puts "Defining  Users"
users =[ {
    username:              "skoona",
    name:                  "Employee Primary User: Developer",
    email:                 "skoona@gmail.com",
    password:                "developer99",
    password_confirmation:   "developer99",
    role_groups:             ["EmployeePrimary"],
    roles:                   ["Services.Action.Developer"]
},
{
    username:              "eptester",
    name:                  "Employee Primary User",
    email:                 "appdev@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["EmployeePrimary"],
    roles:                   ["Services.Action.Admin"]
},
{
    username:              "estester",
    name:                  "Employee Secondary User",
    email:                 "appdev1@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["EmployeeSecondary"],
    roles:                   ["Services.Action.ResetPassword"]
},
{
    username:              "aptester",
    name:                  "Agency Primary User",
    email:                 "appdev2@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["AgencyPrimary"],
    roles:                   ["Services.Action.ResetPassword"]
},
{
    username:              "astester",
    name:                  "Agency Secondary User",
    email:                 "appdev3@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["AgencySecondary"],
    roles:                   ["Services.Action.ResetPassword"]
},
{
    username:              "vptester",
    name:                  "Vendor Long Term User",
    email:                 "appdev4@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["VendorPrimary"],
    roles:                   ["Services.Action.ResetPassword"]
},
{
    username:              "vstester",
    name:                  "Vendor Short Term User",
    email:                 "appdev5@brotherhoodmutual.com",
    password:                "nobugs",
    password_confirmation:   "nobugs",
    role_groups:             ["VendorSecondary"],
    roles:                   ["Services.Action.ResetPassword"]
}
]

puts "Clear existing User Table"
User.delete_all

urecs = User.create!(users)
puts "Users Created #{urecs.size}"



##
#
# Authorization Content Profile Initialization
#
##
puts "Clearing ContentProfile process tables"
ContentProfileEntry.destroy_all
ContentProfile.destroy_all
ProfileType.destroy_all
ContentTypeOpt.destroy_all
ContentType.destroy_all
TopicTypeOpt.destroy_all
TopicType.destroy_all


# {UUID/AgencyOwner} => [
#     PAK/ProfileType    {Commission/Agency/0034 => "CommRptID,CommCsvID,ExperRptID"},
#                        {Notification/Account/99 => "AdvCancel,Cancel"},
#                        {Operations/LicensedStates/USA => "21,30,34,45"}
# ]                      ContentType/TopicType/TopicTypeOpts => ContentTypeOpts
puts "Defining Content Options"
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

all_content_type_opts = [
    commission_cto,
    notification_cto,
    operations_cto
].flatten.uniq

puts "Creating Content Options"
all_content_type_opts_recs = ContentTypeOpt.create!(all_content_type_opts)

puts "Defining Topic Options"
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
licensed_states_tto = [
   {value: "USA", description: "United States of America"},
   {value: "CAN", description: "Canada"}
]

all_topic_type_opts = [
    agency_tto,
    account_tto,
    licensed_states_tto
].flatten.uniq

puts "Creating Topic Options"
all_topic_type_opts_recs = TopicTypeOpt.create!(all_topic_type_opts)

puts "Defining Type Records"
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

control_opts = {
       "Commission" => commission_cto.map() {|rec| rec[:value]}.flatten,
     "Notification" => notification_cto.map() {|rec| rec[:value]}.flatten,
       "Operations" => operations_cto.map() {|rec| rec[:value]}.flatten,
           "Agency" => agency_tto.map() {|rec| rec[:value]}.flatten,
          "Account" => account_tto.map() {|rec| rec[:value]}.flatten,
    "LicensedStates" => licensed_states_tto.map() {|rec| rec[:value]}.flatten
}

##
# Create Type Records
puts "Creating Type Records"
ct_recs = ContentType.create!(ct).each do |rec|
  # find ids
  ids = all_content_type_opts_recs.map {|item| item.id if control_opts[rec.name].include?(item.value)}.flatten.uniq
  # set ids and save
  rec.content_type_opt_ids=ids
  rec.save
  rec
end
tt_recs = TopicType.create!(tt).each do |rec|
  # find ids
  ids = all_topic_type_opts_recs.map {|item| item.id if control_opts[rec.name].include?(item.value)}.flatten.uniq
  # set ids and save
  rec.topic_type_opt_ids=ids
  rec.save
  rec
end
pt_recs = ProfileType.create!(pt)

##
# Make Associations

puts "Defining ContentProfileEntries"
cpe = [
  {topic_value: "Agency",     content_value: [], description: 'Determine which agency documents can be seen'},
  {topic_value: "Account",    content_value: [], description: 'Determine which accounts will have notification sent'},
  {topic_value: "LicensedStates", content_value: [], description: 'Determine which States agent may operate in.'}
]
puts "Creating ContentProfileEntries"
cpe_recs_ids = cpe.map do |item|
    human_choice = {"Agency" => "Commission", "Account" => "Notification", "LicensedStates" => "Operations"}
    topic_rec = tt_recs.detect {|t| t.name.eql?(item[:topic_value])}
    content_rec = ct_recs.detect {|t| t.name.eql?(human_choice[item[:topic_value]])}
    rec = ContentProfileEntry.create!(item)
    rec.content_value = content_rec.content_type_opts.map {|v| v.value}.uniq
    rec.content_type=content_rec
    rec.topic_type=topic_rec
    rec.save
    rec.id
end

puts "Creating ContentProfile"
pt_rec = pt_recs.detect {|r| r.name.eql?("AgencyPrimary")}
cp  = ContentProfile.create({person_authentication_key: urecs[3].person_authenticated_key,
        authentication_provider: "BCrypt",
        username: urecs[3].username,
        display_name: urecs[3].display_name,
        email: urecs[3].email,
        profile_type_id: pt_rec.id}
)
cp.content_profile_entry_ids=cpe_recs_ids


puts "Completed Creating ContentProfile Models"


##
#
# Authorization Group and User level Roles
# Resource Sets
##
puts "Defining UserGroup Management process tables"
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

all_roles = [all_admin , all_users ,
             content_profile_p ,  content_profile_s ,
             group_manage_p ,  group_manage_s ,
             user_manage_p , user_manage_s
].flatten.uniq

all_groups = [
    {name: "EmployeePrimary",   group_type: "BMI Admin",    description: "BMI Admin User"},
    {name: "EmployeeSecondary", group_type: "BMI Limited",  description: "BMI Limited User"},
    {name: "AgencyPrimary",     group_type: "Agency Admin", description: "BMI Limited: Agency Admin User"},
    {name: "AgencySecondary",   group_type: "BMI Public",   description: "BMI Public: Agency Limited User"},
    {name: "VendorPrimary",     group_type: "BMI Limited",  description: "BMI Limited: Long Term"},
    {name: "VendorSecondary",   group_type: "BMI Public",   description: "BMI Public: Short Term"}
]

admin_collection = [
    all_users ,
    all_admin ,
    content_profile_p ,
    group_manage_p ,
    user_manage_p
].flatten.uniq

agency_admin_collection = [
    all_users ,
    user_manage_p ,
    group_manage_p ,
    content_profile_s
].flatten.uniq

limited_collection = [
    all_users ,
    user_manage_s ,
    group_manage_s ,
    content_profile_s
].flatten.uniq

public_collection = [
    all_users
].flatten.uniq


control = {
     "BMI Admin"   => admin_collection,
     "BMI Limited" => limited_collection,
     "BMI Public"  => public_collection,
    "Agency Admin" => agency_admin_collection
}

# Remove Current Stuf
UserGroupRolesUserRole.delete_all
UserGroupRole.delete_all
UserRole.delete_all

# Create them all with array of results in return var
res = UserRole.create!(all_roles)
ges = UserGroupRole.create!(all_groups)

# make the associations
result = ges.each do |grp|
  role_keys = control[grp.group_type].map {|hsh| hsh[:name] }
  role_ids = res.map() do |role|
    role.id if role_keys.include?(role.name)
  end.flatten
  grp.user_role_ids = role_ids
  grp.save!
end

puts "Completed creating UserGroup Management process model"