class ScoresController < ApplicationController

  def save
    @score = Score.save(params[:name])
  end

  def leaderboard
    @ranking = Score.order(wins: :desc)

    respond_to do |format|
      format.html { redirect_to @ranking }
    end
  end

  private
    def score_params
      params.require(:score).permit(:name)
    end
end
