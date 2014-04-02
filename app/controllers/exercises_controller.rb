class ExercisesController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!, except: :delete_last_answers
  before_filter :find_lo, except: :delete_last_answers

  #def index
  #  @exercises = @lo.exercises
  #end

  def create
    @exercise = @lo.exercises.build(params[:exercise])
    if @exercise.save
      respond_with(@lo, @exercise)
    else
      respond_with(@lo, @exercise, status: 422)
    end
  end

  def show
    @exercise = @lo.exercises.includes(:questions).find(params[:id])
    clear_test_answers
    respond_with(@lo, @exercise)
  end

  def update
    @exercise = @lo.exercises.find(params[:id])

    if @exercise.update_attributes(params[:exercise])
      respond_with(@lo, @exercise)
    else
      respond_with(@lo, @exercise, status: 422)
    end
  end

  def destroy
    @exercise = @lo.exercises.find(params[:id])
    @exercise.destroy
    respond_with(@lo, @exercise)
  end

  def delete_last_answers
    @lo = Lo.find(params[:lo_id])
    @exercise = @lo.exercises.find(params[:id])
    @exercise.delete_last_answers_of(current_or_guest_user.id)
    respond_with(@lo, @exercise)
  end

private
 # Its necessary for clean the database and the tests
 def clear_test_answers
   current_user.answers.where(to_test: true).each do |answer|
      tips_counts = answer.original_question.tips_counts.where(user_id: current_user.id)
      tips_counts.destroy
      answer.destroy
   end
 end

 def find_lo
    if current_user.admin?
      @lo = Lo.find(params[:lo_id])
    else
      begin
        @lo = current_user.los.find(params[:lo_id])
      #rescue Exception => e
      rescue
        @lo = Lo.find(params[:lo_id]).in(lo_id: user_los_ids).try(:first)
      end
    end
 end

 # TODO: Refactor this, do in a better way
 def user_los_ids
   @lo_ids ||= []
   current_user.teams.each {|team| @lo_ids = @lo_ids | team.lo_ids}
   @lo_ids
 end

end
