require 'rails_helper'

RSpec.describe ScoresController, type: :routing do
  describe 'routing' do

    it "routes to #save" do
      expect(post: '/save').to route_to("scores#save")
    end
  end
end
