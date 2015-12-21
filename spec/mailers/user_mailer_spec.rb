
RSpec.describe UserMailer do
 let(:user) {FactoryGirl.create(:user)}
  
  describe "password_reset" do
    let(:mail) { UserMailer.password_reset(user) }
    before :each do
      user.generate_unique_token(:password_reset_token)
      user.save
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Password Reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(user.password_reset_token)
    end
  end

end
