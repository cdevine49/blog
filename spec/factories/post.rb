FactoryBot.define do
  factory :post do
    user
    title { "My Title" }
    body { "Lorem ipsum..."}

    factory :post_with_comments do
      transient do
        comments_count { 1 }
      end

      after(:create) do |post, evaluator|
          create_list(
            :comment,
            evaluator.comments_count,
            commentable_id: post.id,
            commentable_type: post.class.to_s
          )
      end
    end
  end
end