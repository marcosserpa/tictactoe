class ScoresController < ApplicationController

  def save
    @score = Score.save(params[:name])
  end

  def leaderboard
    ranking = Score.order(wins: :desc)

    render :leaderboard, locals: { ranking: ranking }
  end

  private
    def score_params
      params.require(:score).permit(:name)
    end
end
