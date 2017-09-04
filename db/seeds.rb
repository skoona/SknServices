# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# http://guides.rubyonrails.org/form_helpers.html#building-complex-forms
#
#
begin

  ##
  #
  # Authorization Group and User level Roles
  # Resource Sets
  # XML Specific: Services.<TopicType>.<ContentType>.Access
  #  -   TopicTypes: Branch, Partner, UserGroups
  #  - ContentTypes: Commission, Experience, LicensedStates, Activity, FileDownload
  ##
  Rails.logger.info "Defining UserGroup Management process tables"
  # requires user_group_role_id: ''
  all_admin = [
      {name: "Services.Action.Admin",                            description: "Employee Managers"},
      {name: "Services.Action.Primary",                          description: "Branch Managers"},
      {name: "Services.Action.Developer",                        description: "Super User or Developer"},
      {name: "Services.Branch.Commission.Access",                description: "Access Branch Commission Statements"},
      {name: "Services.Branch.Experience.Access",                description: "Access Branch Experience Report"},
      {name: "Services.Branch.LicensedStates.Access",            description: "Access Branch Licensed USA States"},
      {name: "Services.UserGroups.FileDownload.Access",          description: "Access Shared UserGroup Resources"},
      {name: "Services.Partner.Activity.Access",                 description: "Access Partner Project Resources"}
  ]

  all_users = [
      {name: "Services.Action.ResetPassword",                    description: "Reset Forgotten Password via EMail"},
      {name: "Services.Action.Use.ContentProfile",               description: "Consumer of Authorization Content Profile"},
      {name: "Services.Action.Use.UserRecords",                  description: "Consumer of User Records"},
      # XML Content Profile Permission, controlled by combination of :user_options and presence of one of these roles.
      {name: "Services.UserGroups.FileDownload.Access",          description: "Access Shared UserGroup Resources"},
      {name: "Services.Partner.Activity.Access",                 description: "Access Partner Project Resources"}
  ]

  content_profile_p = [
      {name: "Services.Action.Admin.ContentProfile",             description: "Administer Authorization Content Profile"},
      {name: "Services.Branch.Commission.Access",                description: "Access Branch Commission Statements"},
      {name: "Services.Branch.Experience.Access",                description: "Access Branch Experience Report"},
      {name: "Services.Branch.LicensedStates.Access",            description: "Access Branch Licensed USA States"}
  ]

  content_profile_s = [
      {name: "Services.Action.Use.ContentProfile",               description: "Consumer of Authorization Content Profile"},
      {name: "Services.Branch.Commission.Access",                description: "Access Branch Commission Statements"},
      {name: "Services.Branch.Experience.Access",                description: "Access Branch Experience Report"},
      {name: "Services.Branch.LicensedStates.Access",            description: "Access Branch Licensed USA States"}
  ]

  group_manage_p = [
      {name: "Services.Branch.LicensedStates.Access",            description: "Access Branch Licensed USA States"}]

  user_manage_p =
      {name: "Services.Action.Admin.UserRecords",                description: "Administer User Records"}

  user_manage_s =
      {name: "Services.Action.Use.UserRecords",                  description: "Consumer of User Records"}

  file_manage_p = [
      {name: "Services.UserGroups.Admin.FileDownload",           description: "Administer Datafile Downloads"}
  ]

  file_manage_s = [
      {name: "Services.UserGroups.Use.FileDownload",                 description: "Consumer of Datafile Downloads"}
  ]

  all_roles = [ all_admin , all_users , file_manage_p, file_manage_s, content_profile_p ,  content_profile_s , group_manage_p ,  user_manage_p , user_manage_s ].flatten.uniq

  all_groups = [
      {name: "Developer",         group_type: "Skoona Consulting",  description: "Open Source Independent Consultancy"},
      {name: "Manager",           group_type: "Corporate Manager",  description: "Corporate Managers"},
      {name: "EmployeePrimary",   group_type: "Department Manager", description: "Department Manager"},
      {name: "EmployeeSecondary", group_type: "Corporate Staff",    description: "Corporate Staff"},
      {name: "BranchPrimary",     group_type: "Branch Admin",       description: "Branch Manager"},
      {name: "BranchSecondary",   group_type: "Branch Staff",       description: "Branch Staff"},
      {name: "VendorPrimary",     group_type: "Partner Admin",      description: "Partner Manager"},
      {name: "VendorSecondary",   group_type: "Partner Staff",      description: "Partner Staff"}
  ]

  admin_collection =        [ all_users , all_admin , content_profile_p , group_manage_p , user_manage_p, file_manage_p ].flatten.uniq
  branch_admin_collection = [ all_users , user_manage_p , group_manage_p , content_profile_s, file_manage_s ].flatten.uniq
  limited_collection =      [ all_users , user_manage_s , content_profile_s, file_manage_s ].flatten.uniq
  public_collection =       [ all_users, file_manage_s ].flatten.uniq

  control = {
      "Skoona Consulting" => all_roles,
      "Corporate Manager"  => all_roles,
      "Department Manager" => admin_collection,
      "Corporate Staff"    => limited_collection,
      "Branch Admin"       => branch_admin_collection,
      "Branch Staff"       => limited_collection,
      "Partner Admin"      => public_collection,
      "Partner Staff"      => public_collection
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
  Rails.logger.info "Completed creating UserGroup Management process model"

  Rails.logger.info "Defining  Users"
  users =[
    {
        username:              "developer",
        name:                  "Skoona Developer",
        email:                 "skoona@gmail.com",
        password:                "developer99",
        password_confirmation:   "developer99",
        user_options:            ["Developer", "0034", "0037", "0040","0099"],
        assigned_groups:         ["Developer"],
        assigned_roles:          ["Services.Action.Developer"]
    },
    {
         username:              "emtester",
         name:                  "Department Manager",
         email:                 "emtester@localhost.com",
         password:                "nobugs",
         password_confirmation:   "nobugs",
         user_options:            ["Manager", "0034", "0037", "0040", "0099"],
         assigned_groups:         ["Manager"],
         assigned_roles:          ["Services.Action.Admin"]
    },
    {
        username:              "eptester",
        name:                  "Employee Primary User",
        email:                 "appdev@localhost.com",
        password:                "nobugs",
        password_confirmation:   "nobugs",
        user_options:            ["EmployeePrimary", "0034", "0037", "0040", "0099"],
        assigned_groups:         ["EmployeePrimary"],
        assigned_roles:          ["Services.Action.Admin"]
    },
    {
        username:              "estester",
        name:                  "Employee Secondary User",
        email:                 "appdev1@localhost.com",
        password:                "nobugs",
        password_confirmation:   "nobugs",
        user_options:            ["EmployeeSecondary", "0037","0099"],
        assigned_groups:         ["EmployeeSecondary"],
        assigned_roles:          []
    },
    {
        username:              "bptester",
        name:                  "Branch Primary User",
        email:                 "appdev2@localhost.com",
        password:                "nobugs",
        password_confirmation:   "nobugs",
        user_options:            ["BranchPrimary", "0034", "0037", "0040","0099"],
        assigned_groups:         ["BranchPrimary"],
        assigned_roles:          ["Services.Action.Primary"]
    },
    {
        username:              "bstester",
        name:                  "Branch Secondary User",
        email:                 "appdev3@localhost.com",
        password:                "nobugs",
        password_confirmation:   "nobugs",
        user_options:            ["BranchSecondary", "0037", "0099"],
        assigned_groups:         ["BranchSecondary"],
        assigned_roles:          []
    },
    {
         username:              "bnptester",
         name:                  "Branch No Privileges User",
         email:                 "appdev6@localhost.com",
         password:                "nobugs",
         password_confirmation:   "nobugs",
         user_options:            [],
         assigned_groups:         ["BranchSecondary"],
         assigned_roles:          []
    },
    {
        username:              "vptester",
        name:                  "Vendor Primary User",
        email:                 "appdev4@localhost.com",
        password:                "nobugs",
        password_confirmation:   "nobugs",
        user_options:            ["VendorPrimary", "0099"],
        assigned_groups:         ["VendorPrimary"],
        assigned_roles:          []
    },
    {
        username:              "vstester",
        name:                  "Vendor Secondary User",
        email:                 "appdev5@localhost.com",
        password:                "nobugs",
        password_confirmation:   "nobugs",
        user_options:            ["VendorSecondary", "0099"],
        assigned_groups:         ["VendorSecondary"],
        assigned_roles:          []
    }
  ]

  Rails.logger.info "Clear existing User Table"
  User.delete_all

  urecs = User.create!(users)
  Rails.logger.info "Completed creating Users model: Users Created #{urecs.size}"


  ##
  #
  # Authorization Content Profile Initialization
  #
  ##
  Rails.logger.info "Reloading ContentProfile process tables"

  Utility::ContentProfileTestDataLoader.new().refresh_content_profiles_data_model

  Rails.logger.info "Completed Creating ContentProfile Models"

end


#  Access Levels -->   Public,  AllAuthorized,  Admin,  Developer
#  Users v
# ------------------------------------------------------------------------------------------------
# QPublic
# developer
# emtester
# eptester
# estester
# bptester
# bstester
# bnptester
# vptester
# vstester
#
#

#  Page / User                                                  vs,  vp,  bs,  bp,  es,  ep,  em,  dv
# ---------------------------------------------------------------------------------------------------------------------
# Home
# About
# Help
# System Architecture
# UserProfile
# AccessProfile
# ContentProfile
# NotAuthenticated
# NotAuthorized
# SignIn
# SignOut
#
# UsersView[profiles/in_action]                               -np    X    X    X    X    X    X    X
#      -depends: profiles/api_get_demo_content_object          X     X    X    X    X    X    X    X
# SystemInformation[pages/details_sysinfo]                     X     X    X    X    X    X    X    X
# User/Show                                                    X     X    X    X    X    X    X    X
# User/Edit                                                    X     X    X    X    X    X    X    X
# User/Update                                                  X     X    X    X    X    X    X    X
# ForgottenPassword[password_resets/new]                       X     X    X    X    X    X    X    X
#
# User/Index                                                   -     -    -    X    -    X    X    X
# Administration Menu                                          -     -    -    X    -    X    X    X
# Full Admin Menu                                              -     -    -    -    -    X    X    X
# user_group_roles/                                            -     -    -    -    -    X    X    X
# AdminView[profiles/members]                                  -     -    -    -    -    X    X    X
# InDepth[profiles/in_depth]                                   -     -    -    -    -    X    X    X
# InAction[profiles/in_action_admin]                           -     -    -    -    -    X    X    X
# SystemInformation[pages/details_sysinfo] APIs Enabled        -     -    -    -    -    X    X    X
#
#