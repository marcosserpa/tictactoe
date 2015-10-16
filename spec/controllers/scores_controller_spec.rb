require 'rails_helper'

RSpec.describe ScoresController, type: :controller do

  describe "POST #save" do
    context "when with name" do
      it "returns http success" do
        post :save, params: { name: "Player 2" }
        expect(response).to have_http_status(:success)
      end
    end
  end

end
