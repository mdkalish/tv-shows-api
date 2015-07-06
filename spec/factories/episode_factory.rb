FactoryGirl.define do
  factory :episode do
    tv_show
    sequence(:title) { |n| "#{n}: Episode #{Faker::Lorem.word}" }
    sequence :episode
    watched false
  end
end
