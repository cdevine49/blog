require 'rails_helper'

RSpec.describe User do
  subject { User.create(email: 'a@a.com', password: "AbC12DeF") }

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('goodemail@domain.com').for(:email) }
    it { should_not allow_value('notanemail').for(:email) }

    it { should validate_length_of(:password).is_at_least(8) }

    it { should validate_presence_of(:password_confirmation).on(:create) }
  end

end