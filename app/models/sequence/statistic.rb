class Sequence::Statistic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :difficulty_degree, type: Hash
  field :question_statistics, type: Hash
  field :order_exercises, type: Hash
  field :rating_user, type: Hash

  field :lo_id, type: Moped::BSON::ObjectId

  field :team_id, type: Moped::BSON::ObjectId

  def calculate_statistics   
    self.question_statistics = Hash.new 
    self.order_exercises = Hash.new

    difficulty_degree_exercise = Hash.new 

    lo = Lo.find(lo_id)
    lo.exercises.each_with_index do |exercise, index|
      difficulty_degree_vector = []
      exercise.questions.each do |question| 
        calculate_statistics_question(question.id, team_id)
        difficulty_degree_vector << self.question_statistics[question.id][:difficulty_degree]
      end
      # Se o exercício possui questões
      # TODO: Verificar
      unless exercise.questions.empty?
        difficulty_degree_exercise[exercise.id] =  difficulty_degree_vector.inject(0.0) { |sum, el| sum + el } / difficulty_degree_vector.size           
      end
      self.order_exercises[exercise.id] = Hash.new
      self.order_exercises[exercise.id][:previous_position] = index
    end
    calculate_new_order_exercises(difficulty_degree_exercise)
    puts self.order_exercises
    self.question_statistics.each {|key,value| puts "#{Question.find(key).title} = #{value}"}
    calculate_rating
    save
  end

  #  Median of a vector
  def calculate_median (vetor)
    sorted = vetor.sort
    mid = (sorted.length - 1) / 2.0
    (sorted[mid.floor] + sorted[mid.ceil]) / 2.0
  end

# TODO: investigar modo de usar aggregation p/ otimizar a forma de calcular as estatísticas

  private

  def calculate_statistics_question(question_id, team_id)
    team = Team.find(team_id)
    users = team.users
    total_users = users.count
    attempts = []
    self.question_statistics[question_id] = Hash.new 
    self.question_statistics[question_id][:number_of_correct_response] = 0
    self.question_statistics[question_id][:number_of_wrong_response] = 0
    users.each do |user|
      answer = user.answers.every.where(from_question_id: question_id).desc(:created_at).limit(1).first
      if answer
        attempts << answer.attempt_number
      end
      ans_correct = user.answers.corrects.where(from_question_id: question_id)              
      unless ans_correct.empty?
        self.question_statistics[question_id][:number_of_correct_response] += 1
      end
    end
    self.question_statistics[question_id][:number_of_wrong_response] = total_users - self.question_statistics[question_id][:number_of_correct_response]
    if self.question_statistics[question_id][:number_of_wrong_response] == 0
       self.question_statistics[question_id][:number_of_wrong_response] = 1     
    end
    if attempts == []
       self.question_statistics[question_id][:median] = 1
    else
       self.question_statistics[question_id][:median] = calculate_median(attempts)
    end
    self.question_statistics[question_id][:difficulty_degree] = 10*self.question_statistics[question_id][:number_of_wrong_response] / (self.question_statistics[question_id][:number_of_wrong_response] + self.question_statistics[question_id][:number_of_correct_response])       
  end

  def calculate_new_order_exercises(difficulty_degree_exercise)
 
      exercises_ordered = difficulty_degree_exercise.keys.sort_by do |a|
         difficulty_degree_exercise[a]
      end
      puts "exercicios ordenados: #{exercises_ordered}"
      i = 0
      exercises_ordered.each do |ex|
         self.order_exercises[ex][:actual_position] = i
         i = i + 1
      end
  end    
    
def calculate_rating ()
    team = Team.find(team_id)
    users = team.users
    total_users = users.count
    puts "total de alunos: #{total_users}"
    self.rating_user = Hash.new
    lo = Lo.find(lo_id)
    lo.exercises.each do |exercise|
      exercise.questions.each do |question|    
        users.each do |user|
          user_attempts = 0
          answer = user.answers.where(from_question_id: question.id).desc(:created_at).limit(1).first
          if answer.nil? 
            user_attempts = 0
          else
            user_attempts = answer.attempt_number
          end
          if user_attempts >= 10
            user_attempts = 10
          end
          a = 0
          e = 0
          ans_correct = user.answers.corrects.where(from_question_id: question.id)              
          if ans_correct.empty?
            a = 0
            e = 1
          else
            a = 1
            e = 0
          end
          previous_rating = 5.5
          if self.rating_user[user.id]
            previous_rating = self.rating_user[user.id]
          end
          k1 = 1 - (previous_rating/10.0)
          k2 = (previous_rating - 1)/10.0
          alfa =(1.0/self.question_statistics[question.id][:number_of_correct_response])
          beta =(1.0/self.question_statistics[question.id][:number_of_wrong_response])
          if self.question_statistics[question.id][:median] == 0
            median_rating = 1
          else
            median_rating = self.question_statistics[question.id][:median]
          end
          if user_attempts > median_rating
            user_attempts = median_rating
          end
          actual_rating = previous_rating + a*k1*alfa*(10 - 9*(user_attempts/median_rating)) - e*k2*beta*10*(user_attempts/median_rating)
          self.rating_user[user.id] = actual_rating
        end  
      end
    end    
    puts "rating:#{self.rating_user}"
  end

end
