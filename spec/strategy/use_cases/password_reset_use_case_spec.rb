# spec/strategy/use_cases/password_reset_use_case_spec.rb
#

RSpec.describe ::UseCases::PasswordResetUseCase, "UseCase to Reset users Password"  do
  let!(:user) {user_bstester}

  let(:mc) {ServiceRegistryMockController.new(user: user)}
  let(:service_registry)  { Services::ServiceRegistry.new({registry: mc}) }

  let(:service) {service_registry.password_reset_use_case}

  context "Initialization "  do

    scenario "#new throws an Exception without params." do
      expect{ described_class.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds with only :registry as init param." do
      expect(described_class.new({registry: service_registry})).to be_a(described_class)
    end
    scenario "#new fails when :registry is invalid." do
      expect{ described_class.new({registry: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#registry.password_reset_use_case returns a proper service object." do
      expect( service ).to be_a described_class
    end
    scenario "#service #registry and #controller objects to be different." do
      expect( service.registry ).to be_a Services::ServiceRegistry
      expect( service.controller ).to be_a ServiceRegistryMockController
    end
    scenario "#current_user returns a UserProfile object." do
      expect( service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Reset Password Operations" do

    scenario "#reset_password updates user record with new password." do
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new({user: {password: "boomer", password_confirmation: "boomer"}, id: user.id})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be true
    end

    scenario "#reset_password updates user record with new remember_token." do
      token_1 = user.remember_token
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true

      bundle = ActionController::Parameters.new({:id => user.id, :user => {:password => "boomer", :password_confirmation => "boomer"}})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be true
      user.reload
      expect(user.remember_token).not_to be_eql token_1
    end

    scenario "#reset_password fails when out of date." do
      user.password_reset_date = 3.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new(user: {password: "boomer", password_confirmation: "boomer"}, id: user.id)

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be false
    end

    scenario "#reset_password fails without matching passwords." do
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new({user:{password: "boomer", password_confirmation: "boober"}, id: user.id})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be false
    end

    scenario "#reset_password fails with invalid user id" do
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new({user:{password: "boomer", password_confirmation: "boomer"}, id: 9999995})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be false
    end

    context "Request Password Reset Operations" do

      scenario "#reset_requested verifies username and initiates the the reset sequence." do
        allow(service).to receive(:password_mailer) {true}
        rtn = service.reset_requested(user: {username: user.username})
        expect(rtn.success).to be true
      end

      scenario "#reset_requested fails with invalid username." do
        allow(service).to receive(:password_mailer) {true}
        rtn = service.reset_requested(user: {username: "bambi"})
        expect(rtn.success).to be false
      end

      scenario "#reset_requested generates a new password_reset_token" do
        token_1 = user.password_reset_token
        allow(service).to receive(:password_mailer) {true}
        rtn = service.reset_requested(user: {username: user.username})
        expect(rtn.success).to be true
        user.reload
        expect(user.password_reset_token).to_not be_eql token_1
      end

      scenario "#send_password_reset sends password reset email and link to edit page." do
        allow(service).to receive(:password_mailer) {true}
        token_1 = user.password_reset_token
        rtn = service.send_password_reset(user)
        expect(rtn).to be true
        expect(user.password_reset_token).not_to be_eql token_1
      end

      scenario "#send_password_reset raises and exception if user object is invalid" do
        allow(service).to receive(:password_mailer) {true}
        expect{ service.send_password_reset(nil) }.to raise_error NoMethodError
      end

    end
  end

end
