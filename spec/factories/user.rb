FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "A1B2C3D4" }
    password_confirmation { "A1B2C3D4" }
    
    factory :user_with_posts do
      transient do
          posts_count { 1 }
      end
  
      after(:create) do |user, evaluator|
          create_list(:post, evaluator.posts_count, user: user)
      end
    end
  end
end