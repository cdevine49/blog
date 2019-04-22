FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "A1B2C3D4" }
    password_confirmation { "A1B2C3D4" }
  end
end