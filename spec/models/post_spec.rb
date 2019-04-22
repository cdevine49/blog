require 'rails_helper'

RSpec.describe User do
  subject { Post.create(title: 'My Title', body: "Lorem ipsum ...") }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:user) }
  end

  describe 'relationships' do
    it { should belong_to(:user) }
  end
end