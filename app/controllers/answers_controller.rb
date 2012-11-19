class AnswersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json
  before_filter :team_ids, only: :index

  def index
    if current_user.admin?
      @answers = Answer.search(params[:page], params[:search])
    else
      @answers = Answer.search(params[:page], params[:search], @team_ids)
    end
  end

  def create
    last = LastAnswer.where(user_id: current_user.id, question_id: params[:answer][:question_id]).try(:first)

    if (last && last.answer && (last.answer.response == params[:answer][:response]))
      @answer = last.answer
    else
      @answer = current_user.answers.create(params[:answer])
    end
  end

  def retroaction
    delete_retroaction_answers
    @answer = Answer.find(params[:id])
  end

  def team_ids
    owner_team_ids = Team.where(owner_id: current_user.id).map {|e| e.id}
    @team_ids ||= owner_team_ids | current_user.team_ids
  end

private
  def delete_retroaction_answers
    retros = RetroactionAnswer.where(answer_id: params[:id], user_id: current_user.id)
    retros.delete_all
  end

end
