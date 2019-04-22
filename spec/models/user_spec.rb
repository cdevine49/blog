require 'rails_helper'

RSpec.describe User do
  subject { User.create(email: 'a@a.com', password: "AbC12DeF", password_confirmation: "AbC12DeF") }

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('goodemail@domain.com').for(:email) }
    it { should_not allow_value('notanemail').for(:email) }

    it { should validate_length_of(:password).is_at_least(8) }

    it { should validate_presence_of(:password_confirmation).on(:create) }
  end

  describe 'find_by_token' do
    context 'when token is invalid' do
      before(:each) {
        allow(JsonWebToken).to receive(:decode).and_return({})
      }

      it { expect(User.find_by_token('invalid or nil')).to be(nil) }
    end
    
    context 'when token is valid' do
      before(:each) {
        allow(JsonWebToken).to receive(:decode).and_return({ user_id: subject.id })
      }

      it { expect(User.find_by_token('xxx.yyy.zzz')).to eq(subject) }
    end
  end

end