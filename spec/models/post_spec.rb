require 'rails_helper'

RSpec.describe Post do
  subject { Post.create(title: 'My Title', body: "Lorem ipsum ...") }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:user) }
  end

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
  end
end