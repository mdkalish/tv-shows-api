1.upto(5) do
  user = User.create!(email: Faker::Internet.email,
                      password: "asdasdasd" )
  1.upto(rand(1..3)) do
    tv_show = TvShow.create!(title: Faker::Lorem.word.capitalize,
                             description: Faker::Lorem.sentence,
                             user: user)
    1.upto(rand(3..5)) do |k|
      Episode.create!(tv_show: tv_show,
                      title: Faker::Lorem.words(2).join(' ').titleize,
                      episode: k)
    end
  end
end
