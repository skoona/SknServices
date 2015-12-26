# spec/services/access_registry_spec.rb
#

## Access Registry Model for Testing
#
#    {"testing/role/progressive"=>
#         {"secured"=>true,
#          "description"=>"Testing Resource Only: Progressive Capability",
#          "READ"=>
#              {"Test.Action.Create"=>[],
#               "Test.Action.Read"=>[],
#               "Test.Action.Update"=>[],
#               "Test.Action.Delete"=>[]},
#          "UPDATE"=>
#              {"Test.Action.Update"=>[],
#               "Test.Action.Create"=>[],
#               "Test.Action.Delete"=>[]},
#          "CREATE"=>{"Test.Action.Create"=>[], "Test.Action.Delete"=>[]},
#          "DELETE"=>{"Test.Action.Delete"=>[]}},
#    "testing/role/absolutes"=>
#         {"secured"=>true,
#          "description"=>"Testing Resource Only: Absolute Capability",
#          "READ"=>{"Test.Action.Read"=>[]},
#          "UPDATE"=>{"Test.Action.Update"=>[]},
#          "CREATE"=>{"Test.Action.Create"=>[]},
#          "DELETE"=>{"Test.Action.Delete"=>[]}},
#    "testing/role/options"=>
#         {"secured"=>true,
#          "description"=>
#              "Testing Resource Only: Options Special Ownership Granting Capability",
#          "READ"=>
#              {"Test.Action.Create"=>[],
#               "Test.Action.Read"=>[],
#               "Test.Action.Update"=>[],
#               "Test.Action.Delete"=>[]},
#          "UPDATE"=>{"Test.Action.Read"=>["OBJECT-OWNER"], "Test.Action.Update"=>[]},
#          "CREATE"=>
#              {"Test.Action.Read"=>["CLIENT-MANAGER"], "Test.Action.Create"=>[]},
#          "DELETE"=>{"Test.Action.Delete"=>[]}},
#    "/signout"=>{"secured"=>false, "description"=>"signout Page"},
#    "/signin"=>{"secured"=>false, "description"=>"signin Page"}
#    }


RSpec.describe AccessRegistry, "Authorization management" do

  let(:admin) {["Test.Action.Create", "Test.Action.Read", "Test.Action.Update", "Test.Action.Delete"]}
  let(:employee) {["Test.Action.Read"]}
  let(:manager) {["Test.Action.Delete"]}
  let(:bad) {["Bad User Role"]}

  let(:owner_option) {"OBJECT-OWNER"}
  let(:manager_option) {"CLIENT-MANAGER"}
  let(:options) {["OBJECT-OWNER","CLIENT-MANAGER"]}
  let(:unknown_options) {"SOME:UNKNOWN:VALUES"}

  let(:resource_unknown) {"any value will do"}
  let(:resource_options) {"testing/role/options"}
  let(:resource_absolutes) {"testing/role/absolutes"}
  let(:resource_progressive) {"testing/role/progressive"}
  let(:resource_public_page) {"testing/public"}

  let(:auth) { AccessRegistryTestUser.new(["Test.Action.Read"]) }


  context "Initializes correctly as a Static Service" do
    it "Loads the permissions resources when Rails starts." do
      object = AccessRegistry.get_ar_resource_keys
      expect(object.size).to be > 1
    end
    it "Will not allow an instance to be created."  do
        expect{ AccessRegistry.new }.to raise_error(NotImplementedError)
    end
    it "Undefined resources are treated as secured." do
      expect(AccessRegistry.is_secured?(resource_unknown)).to be true
    end
    it "Defined resources are secure when declared as such." do
      expect(AccessRegistry.is_secured?(resource_progressive)).to be true
    end
    it "Defined resources are not secure when declared as such." do
      expect(AccessRegistry.is_secured?(resource_public_page)).to be false
    end
  end

  context "element payloads are directly accessable" do
    it "#get_resource_description returns desciption element as string, from secured resource." do
      expect(AccessRegistry.get_resource_description('testing/userdata')).to be_a_kind_of(String)
    end
    it "#get_resource_userdata_string returns userdata element as string, from secured resource." do
      expect(AccessRegistry.get_resource_userdata_string('testing/userdata')).to be_a_kind_of(String)
    end
    it "#get_resource_userdata_hash returns userdata element as hash, from secured resource." do
      expect(AccessRegistry.get_resource_userdata_hash('testing/userdata')).to be_a_kind_of(Hash)
    end
    it "#get_resource_description returns desciption element as string, from unsecure resource." do
      expect(AccessRegistry.get_resource_description('testing/userdata')).to be_a_kind_of(String)
    end
    it "#get_resource_userdata_string returns userdata element as string, from unsecure resource." do
      expect(AccessRegistry.get_resource_userdata_string('testing/userdata')).to be_a_kind_of(String)
    end
    it "#get_resource_userdata_hash returns userdata element as hash, from unsecure resource." do
      expect(AccessRegistry.get_resource_userdata_hash('testing/userdata')).to be_a_kind_of(Hash)
    end
  end

  context "AccessControl module helpers" do

    context "Progressive model works as designed. " do
      it "CREATE" do
        auth.set_roles ["Test.Action.Create"]
        expect(auth.has_access?(resource_progressive)).to be true
        expect(auth.has_create?(resource_progressive)).to be true
      end
      it "READ" do
        auth.set_roles ["Test.Action.Read"]
        expect(auth.has_access?(resource_progressive)).to be true
        expect(auth.has_read?(resource_progressive)).to be true
      end
      it "UPDATE" do
        auth.set_roles ["Test.Action.Update"]
        expect(auth.has_access?(resource_progressive)).to be true
        expect(auth.has_update?(resource_progressive)).to be true
      end
      it "DELETE" do
        auth.set_roles  ["Test.Action.Delete"]
        expect(auth.has_access?(resource_progressive)).to be true
        expect(auth.has_create?(resource_progressive)).to be true
        expect(auth.has_read?(resource_progressive)).to be true
        expect(auth.has_update?(resource_progressive)).to be true
        expect(auth.has_delete?(resource_progressive)).to be true
      end
    end

    context "Absolute model works as designed. " do
      it "CREATE" do
        auth.set_roles  ["Test.Action.Create"]
        expect(auth.has_access?(resource_absolutes)).to be true
        expect(auth.has_create?(resource_absolutes)).to be true
      end
      it "READ" do
        auth.set_roles  ["Test.Action.Read"]
        expect(auth.has_access?(resource_absolutes)).to be true
        expect(auth.has_read?(resource_absolutes)).to be true
        expect(auth.has_delete?(resource_absolutes)).to be false
      end
      it "UPDATE" do
        auth.set_roles  ["Test.Action.Update"]
        expect(auth.has_access?(resource_absolutes)).to be true
        expect(auth.has_update?(resource_absolutes)).to be true
      end
      it "DELETE" do
        auth.set_roles  ["Test.Action.Delete"]
        expect(auth.has_access?(resource_absolutes)).to be true
        expect(auth.has_create?(resource_absolutes)).to be false
        expect(auth.has_read?(resource_absolutes)).to be false
        expect(auth.has_update?(resource_absolutes)).to be false
        expect(auth.has_delete?(resource_absolutes)).to be true
      end
    end

    context "Absolute with Options Override model works as designed. " do
      it "CREATE" do
        auth.set_roles  ["Test.Action.Create"]
        expect(auth.has_access?(resource_options)).to be true
        expect(auth.has_create?(resource_options)).to be true
      end
      it "READ" do
        auth.set_roles  ["Test.Action.Read"]
        expect(auth.has_access?(resource_options)).to be true
        expect(auth.has_read?(resource_options)).to be true
      end
      it "UPDATE" do
        auth.set_roles  ["Test.Action.Update"]
        expect(auth.has_access?(resource_options)).to be true
        expect(auth.has_update?(resource_options)).to be true
      end
      it "DELETE" do
        auth.set_roles  ["Test.Action.Delete"]
        expect(auth.has_access?(resource_options)).to be true
        expect(auth.has_create?(resource_options)).to be false
        expect(auth.has_read?(resource_options)).to be false
        expect(auth.has_update?(resource_options)).to be false
        expect(auth.has_delete?(resource_options)).to be true
      end
      it "OPTIONS " do
        auth.set_roles  ["Test.Action.Read"]
        expect(auth.has_access?(resource_options)).to be true
        expect(auth.has_update?(resource_options)).to be false
        expect(auth.has_create?(resource_options)).to be false
        expect(auth.has_update?(resource_options,owner_option)).to be true
        expect(auth.has_create?(resource_options,manager_option)).to be true
      end
    end
  end

  context "#check_access_permissions? Correctly determines  " do

    context "When permissions match" do
      it "Allows access to secured resource when correct role is provided with no options." do
        expect(AccessRegistry.check_access_permissions?(employee, resource_progressive, nil)).to be true
      end
      it "Allows access to secured resource when correct role and options are provided." do
        expect(AccessRegistry.check_access_permissions?(employee, resource_options, options)).to be true
      end
      it "Allows access to secured resource when correct role and unrelated options are provided." do
        expect(AccessRegistry.check_access_permissions?(employee, resource_progressive, unknown_options)).to be true
      end
    end

    context "When permissions do not match." do
      it "Does not allow access to secured resource when wrong role is provided with no options." do
        expect(AccessRegistry.check_access_permissions?(bad, resource_options, nil)).to be false
      end
      it "Allow access to secured resource when correct role and wrong options are provided." do
        expect(AccessRegistry.check_access_permissions?(employee, resource_options, unknown_options)).to be true
      end
      it "Does not allow access to secured resource when wrong role and unrelated options are provided." do
        expect(AccessRegistry.check_access_permissions?(bad, resource_options, unknown_options)).to be false
      end
    end
  end

  context "#check_role_permissions? Correctly determines  " do

    context "When CRUD roles are granted permission to access resource." do
      it "Update permission is granted with options present for employees" do
        expect(AccessRegistry.check_role_permissions?(employee, resource_options, "UPDATE", owner_option)).to be true
      end
      it "Create permission is granted with no options present for managers." do
        expect(AccessRegistry.check_role_permissions?(admin, resource_absolutes, "CREATE", nil)).to be true
      end
      it "Read permission is granted." do
        expect(AccessRegistry.check_role_permissions?(admin, resource_absolutes, "READ", nil)).to be true
      end
      it "Update permission is granted." do
        expect(AccessRegistry.check_role_permissions?(admin, resource_absolutes, "UPDATE", nil)).to be true
      end
      it "Delete permission is granted." do
        expect(AccessRegistry.check_role_permissions?(admin, resource_absolutes, "DELETE", nil)).to be true
      end
    end

    context "When CRUD roles are denied permission to access resource." do
      it "Create permission is denied with wrong options present for employees." do
        expect(AccessRegistry.check_role_permissions?(employee, resource_options, "CREATE", owner_option)).to be false
      end
      it "Create permission is denied." do
        expect(AccessRegistry.check_role_permissions?(employee, resource_absolutes, "CREATE", nil)).to be false
      end
      it "Read permission is denied." do
        expect(AccessRegistry.check_role_permissions?(bad, resource_absolutes, "READ", nil)).to be false
      end
      it "Update permission is denied." do
        expect(AccessRegistry.check_role_permissions?(employee, resource_absolutes, "UPDATE", nil)).to be false
      end
      it "Delete permission is denied." do
        expect(AccessRegistry.check_role_permissions?(employee, resource_absolutes, "DELETE", nil)).to be false
      end
    end
  end

end
