namespace :db do

  desc "This populate database"
  task :populate => :environment do
    require 'faker'

    [Lo, User].each(&:destroy_all)

    professor = User.create!(name: 'Farma', email: 'farma.ufpr@gmail.com', password: 'farma123',
                password_confirmation: 'farma123', admin: true)

    los = 10.times.map do
        lo = professor.los.create( name: Faker::Name.name, available: true,
                                   description: Faker::Lorem.paragraphs(2).join)
        3.times do
          lo.introductions.create( title: Faker::Name.title, content: Faker::Lorem.paragraphs(3).join)
        end

        3.times do
          exer = lo.exercises.create( title: Faker::Name.title, content: Faker::Lorem.paragraphs(3).join)
          3.times do |i|
            q = exer.questions.create(title: Faker::Name.title, content: Faker::Lorem.paragraphs(1).join,
                                  correct_answer: i)

            3.times do |i|
              q.tips.create(content: Faker::Lorem.paragraphs(1).join,
                            numbers_of_tries: i )
            end

          end
        end
    end
  end

end
