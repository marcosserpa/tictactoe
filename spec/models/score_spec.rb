require 'rails_helper'

RSpec.describe Score, type: :model do
  describe 'factory' do
    context 'is valid' do
      it { expect(FactoryGirl.create(:score)).to be_valid }
    end
  end

  describe '.save' do
    context "with name" do
      it "must be valid" do
        expect(Score.save("Player")).to eql(true)
      end
    end

    context "without name" do
      it "must be invalid" do
        expect(Score.save('')).to eql(false)
      end
    end

    context "already saved name" do
      it "must increment wins" do
        player = FactoryGirl.create(:score)
        wins = player.wins

        expect{ Score.save("Player 1") }.to change{ player.reload.wins }.from(wins).to(wins + 1)
      end
    end
  end
end
