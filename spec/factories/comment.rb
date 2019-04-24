FactoryBot.define do
  factory :comment do
    body { "Lorem ipsum..."}
    commentable { |c| c.association(:post) }
  end
end