class ScoresController < ApplicationController

  def save
    @score = Score.save(params[:name])
    @ranking = Score.order(wins: :desc)

    respond_to do |format|
      format.html { redirect_to @ranking notice: @score.errors if !@score.errors.blank? }
    end
  end

  def leaderboard

  end

  private
    def score_params
      params.require(:score).permit(:name)
    end
end
