FactoryBot.define do
  factory :comment do
    body { "Lorem ipsum..."}
    commentable { |c| c.association(:post) }

    factory :comment_with_comments do
      transient do
        comments_count { 1 }
      end

      after(:create) do |comment, evaluator|
          create_list(
            :comment,
            evaluator.comments_count,
            commentable_id: comment.id,
            commentable_type: comment.class.to_s
          )
      end
    end
  end
end