# spec/services/password_service_spec.rb
#

RSpec.describe ApplicationController, "Service routines for resetting forgotten passwords.", :type => :controller  do
  let(:service) {controller.password_service}
  let(:user) {create(:user)}

  context "Initialization "  do

    it "throws an Exception without params." do
      expect { PasswordService.new }.to raise_error(ArgumentError)
    end

    it "succeeds when controller is valid." do
      expect(PasswordService.new({controller: controller})).to be_a(PasswordService)
    end

    it "fails when controller is invalid." do
      expect { PasswordService.new({controller: nil}) }.to raise_error(ArgumentError)
    end

    it "#password_service return a proper service object." do
      object = controller.password_service
      expect(object).to be_a PasswordService
    end
  end

  context "Reset Password Operations" do

    it "#reset_password updates user record with new password." do
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new({user: {password: "boomer", password_confirmation: "boomer"}, id: user.id})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be true
    end

    it "#reset_password updates user record with new remember_token." do
      token_1 = user.remember_token
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true

      bundle = ActionController::Parameters.new({:id => user.id, :user => {:password => "boomer", :password_confirmation => "boomer"}})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be true
      user.reload
      expect(user.remember_token).not_to be_eql token_1
    end

    it "#reset_password fails when out of date." do
      user.password_reset_date = 3.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new(user: {password: "boomer", password_confirmation: "boomer"}, id: user.id)

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be false
    end

    it "#reset_password fails without matching passwords." do
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new({user:{password: "boomer", password_confirmation: "boober"}, id: user.id})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be false
    end

    it "#reset_password fails with invalid user id" do
      user.password_reset_date = 1.hours.ago
      expect(user.save).to be true
      bundle = ActionController::Parameters.new({user:{password: "boomer", password_confirmation: "boomer"}, id: 9999995})

      rtn = service.reset_password(bundle)
      expect(rtn.success).to be false
    end
  end

  context "Request Password Reset Operations" do

    it "#reset_requested verifies username and initiates the the reset sequence." do
      allow(service).to receive(:password_mailer) {true}
      rtn = service.reset_requested(user: {username: user.username})
      expect(rtn.success).to be true
    end

    it "#reset_requested fails with invalid username." do
      allow(service).to receive(:password_mailer) {true}
      rtn = service.reset_requested(user: {username: "bambi"})
      expect(rtn.success).to be false
    end

    it "#reset_requested generates a new password_reset_token" do
      token_1 = user.password_reset_token
      allow(service).to receive(:password_mailer) {true}
      rtn = service.reset_requested(user: {username: user.username})
      expect(rtn.success).to be true
      user.reload
      expect(user.password_reset_token).to_not be_eql token_1
    end

    it "#send_password_reset sends password reset email and link to edit page." do
      allow(service).to receive(:password_mailer) {true}
      token_1 = user.password_reset_token
      rtn = service.send_password_reset(user)
      expect(rtn).to be true
      expect(user.password_reset_token).not_to be_eql token_1
    end

    it "#send_password_reset raises and exception if user object is invalid" do
      allow(service).to receive(:password_mailer) {true}
      expect{ service.send_password_reset(nil) }.to raise_error NoMethodError
    end

  end

end
