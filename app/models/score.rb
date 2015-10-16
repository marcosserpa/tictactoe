class Score < ActiveRecord::Base

  validates :name, presence: true

  class << self

    def save(name)
      score = Score.find_or_initialize_by(name: name)
      score.wins = score.wins.nil? ? 1 : (score.wins + 1)
      score.save
      score.reload
    end

  end

end
