require 'rails_helper'

RSpec.describe Comment do
  subject { Comment.create(body: "Lorem ipsum ...", commentable: create(:post)) }

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'relationships' do
    it { should belong_to(:commentable) }
    it { should have_many(:comments) }
  end
end