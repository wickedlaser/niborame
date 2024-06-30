require 'rails_helper'

RSpec.describe "Shoplists", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/shoplist/index"
      expect(response).to have_http_status(:success)
    end
  end

end
