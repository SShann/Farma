attributes :id, :title, :content, :exp_variables, :many_answers

node :last_answer, if: lambda {|question| question.last_answers.by_user(current_user).size > 0} do |question|
  la = question.last_answers.by_user(current_user).first
  {
    tip: la.answer.tip,
    correct: la.answer.correct,
    response: la.answer.response,
    try_number: la.answer.try_number,
    id: la.id,
  }
end