FactoryGirl.define do
  factory :tv_show do
    sequence(:title) { |n| "#{n}: Tv Show #{Faker::Lorem.word}" }
    description 'Description for a show.'

    factory :tv_show_with_episodes do
      transient { episodes_count 5 }

      after(:create) do |tv_show, evaluator|
        create_list(:episode, evaluator.episodes_count, tv_show: tv_show)
      end
    end
  end
end
