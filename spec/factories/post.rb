FactoryBot.define do
  factory :post do
    user
    title { "My Title" }
    body { "Lorem ipsum..."}
  end
end