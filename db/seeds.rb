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
  ##
  Rails.logger.info "Defining UserGroup Management process tables"
  # requires user_group_role_id: ''
  all_admin = [
      {name: "Services.Action.Admin", description: "Employee Managers"},
      {name: "Services.Action.Primary", description: "Branch Managers"},
      {name: "Services.Action.Developer", description: "Super User or Developer"},
      {name: "Test.Branch.Commission.Statement.PDF.Access", description: "Access Branch Commission Statements"},
      {name: "Test.Branch.Commission.Statement.CSV.Access", description: "Access Branch Commission Data Files"},
      {name: "Test.Branch.Commission.Experience.PDF.Access", description: "Access Branch Experience Report"},
      {name: "Test.Branch.Operations.LicensedStates.USA", description: "Access Branch Licensed USA States"}]

  all_users =
      {name: "Services.Action.ResetPassword", description: "Reset Forgotten Password via EMail"}

  content_profile_p =
      {name: "Services.Action.Admin.ContentProfile",   description: "Administer Authorization Content Profile"}

  content_profile_s =
      {name: "Services.Action.Use.ContentProfile", description: "Consumer of Authorization Content Profile"}

  group_manage_p = [
      {name: "Services.Action.Admin.UserAuthorizationGroups",   description: "Administer Authorization Group"},
      {name: "Test.Branch.Operations.LicensedStates.USA", description: "Access Branch Licensed USA States"}]

  group_manage_s =
      {name: "Services.Action.Use.UserAuthorizationGroups", description: "Consumer of Authorization Groups"}

  user_manage_p =
      {name: "Services.Action.Admin.UserRecords",   description: "Administer User Records"}

  user_manage_s =
      {name: "Services.Action.Use.UserRecords", description: "Consumer of User Records"}

  file_manage_p = [
      {name: "Services.Action.Admin.FileDownload.Datafile",   description: "Administer Datafile Downloads"},
      {name: "Services.Action.Admin.FileDownload.Image",      description: "Administer Image Downloads"},
      {name: "Services.Action.Admin.FileDownload.Pdf",        description: "Administer Pdf Downloads"}
  ]

  file_manage_s = [
      {name: "Services.Action.Use.FileDownload.Datafile",   description: "Consumer of Datafile Downloads"},
      {name: "Services.Action.Use.FileDownload.Image",      description: "Consumer of Image Downloads"},
      {name: "Services.Action.Use.FileDownload.Pdf",        description: "Consumer of Pdf Downloads"}
  ]

  all_roles = [all_admin , all_users , file_manage_p, file_manage_s,
               content_profile_p ,  content_profile_s ,
               group_manage_p ,  group_manage_s ,
               user_manage_p , user_manage_s
  ].flatten.uniq

  all_groups = [
      {name: "Developer",         group_type: "Skoona Development",  description: "Open Source Independent Consultancy"},
      {name: "EmployeePrimary",   group_type: "Corporate Admin",  description: "Corporate Managers"},
      {name: "EmployeeSecondary", group_type: "Corporate Staff",  description: "Corporate Staff"},
      {name: "BranchPrimary",     group_type: "Branch Admin",     description: "Branch Manager"},
      {name: "BranchSecondary",   group_type: "Branch Staff",     description: "Branch Staff"},
      {name: "VendorPrimary",     group_type: "Partner Admin",    description: "Partner Manager"},
      {name: "VendorSecondary",   group_type: "Partner Staff",    description: "Partner Staff"}
  ]

  admin_collection = [
      all_users ,
      all_admin ,
      content_profile_p ,
      group_manage_p ,
      user_manage_p,
      file_manage_p
  ].flatten.uniq

  branch_admin_collection = [
      all_users ,
      user_manage_p ,
      group_manage_p ,
      content_profile_s,
      file_manage_s
  ].flatten.uniq

  limited_collection = [
      all_users ,
      user_manage_s ,
      group_manage_s ,
      content_profile_s,
      file_manage_s
  ].flatten.uniq

  public_collection = [
      all_users,
      file_manage_s
  ].flatten.uniq


  control = {
      "Skoona Development" => all_roles,
      "Corporate Admin" => admin_collection,
      "Corporate Staff" => limited_collection,
      "Branch Staff"    => public_collection,
      "Partner Admin"    => public_collection,
      "Partner Staff"    => public_collection,
      "Branch Admin"    => branch_admin_collection
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
  users =[ {
      username:              "developer",
      name:                  "Skoona Developer",
      email:                 "skoona@gmail.com",
      password:                "developer99",
      password_confirmation:   "developer99",
      user_options:            ["Developer","EmployeePrimary", "0034", "0037", "0040","0099", "1601"],
      assigned_groups:         ["Developer","EmployeePrimary"],
      assigned_roles:          ["Services.Action.Developer"]
  },
  {
      username:              "eptester",
      name:                  "Employee Primary User",
      email:                 "appdev@localhost.com",
      password:                "nobugs",
      password_confirmation:   "nobugs",
      user_options:            ["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602"],
      assigned_groups:         ["Manager", "EmployeePrimary"],
      assigned_roles:          ["Services.Action.Admin"]
  },
  {
      username:              "estester",
      name:                  "Employee Secondary User",
      email:                 "appdev1@localhost.com",
      password:                "nobugs",
      password_confirmation:   "nobugs",
      user_options:            ["EmployeeSecondary", "0037","0099", "1602"],
      assigned_groups:         ["EmployeeSecondary"],
      assigned_roles:          ["Services.Action.Primary",
                                "Test.Branch.Commission.Experience.PDF.Access",
                                "Test.Branch.Commission.Statement.PDF.Access",
                                "Test.Branch.Commission.Statement.CSV.Access"]
  },
  {
      username:              "bptester",
      name:                  "Branch Primary User",
      email:                 "appdev2@localhost.com",
      password:                "nobugs",
      password_confirmation:   "nobugs",
      user_options:            ["BranchPrimary", "0034", "0037", "0040"],
      assigned_groups:         ["BranchPrimary"],
      assigned_roles:          ["Services.Action.Primary",
                                "Services.Action.ResetPassword",
                                "Test.Branch.Commission.Experience.PDF.Access",
                                "Test.Branch.Commission.Statement.PDF.Access",
                                "Test.Branch.Commission.Statement.CSV.Access"]
  },
  {
      username:              "bstester",
      name:                  "Branch Secondary User",
      email:                 "appdev3@localhost.com",
      password:                "nobugs",
      password_confirmation:   "nobugs",
      user_options:            ["BranchSecondary", "0037"],
      assigned_groups:         ["BranchSecondary"],
      assigned_roles:          ["Services.Action.ResetPassword",
                                "Test.Branch.Commission.Statement.CSV.Access"]
  },
   {
       username:              "bnptester",
       name:                  "Branch No Privileges User",
       email:                 "appdev6@localhost.com",
       password:                "nobugs",
       password_confirmation:   "nobugs",
       user_options:            [],
       assigned_groups:         ["BranchSecondary"],
       assigned_roles:          ["Services.Action.ResetPassword" ]
   },
  {
      username:              "vptester",
      name:                  "Vendor Primary User",
      email:                 "appdev4@localhost.com",
      password:                "nobugs",
      password_confirmation:   "nobugs",
      user_options:            ["VendorPrimary", "0099"],
      assigned_groups:         ["VendorPrimary"],
      assigned_roles:          ["Services.Action.ResetPassword"]
  },
  {
      username:              "vstester",
      name:                  "Vendor Secondary User",
      email:                 "appdev5@localhost.com",
      password:                "nobugs",
      password_confirmation:   "nobugs",
      user_options:            ["VendorSecondary", "0099"],
      assigned_groups:         ["VendorSecondary"],
      assigned_roles:          ["Services.Action.ResetPassword"]
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