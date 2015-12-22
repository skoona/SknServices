require 'rails_helper'

RSpec.describe "ContentProfiles", type: :request do
  describe "GET /content_profiles" do
    it "works! (now write some real specs)" do
      get content_profiles_path
      expect(response).to have_http_status(200)
    end
  end
end
