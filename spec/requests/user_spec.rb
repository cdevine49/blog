require 'rails_helper'

RSpec.describe User do
  subject(:user) { create(:user) }

  describe '#create' do
    context 'when a user is logged in' do
      before(:each) {
        authorized :post, '/api/users', user: user
      }

      it { expect(response).to have_http_status(:forbidden) }
    end

    context 'when user is invalid' do
      invalid_user = { user: { email: 'bad', password: 'short', password_confirmation: 'no match' } }
      before(:each) { |example|
        post '/api/users', params: invalid_user unless example.metadata[:skip_before]
      }

      it "does not create a user", skip_before: true do
        expect { post '/api/users', params: invalid_user }
        .to_not change(User, :count)
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end

    context 'when user is valid' do
      valid_user = { user: { email: 'a@a.io', password: 'good enough', password_confirmation: 'good enough' } }
      before(:each) { |example|
        post '/api/users', params: valid_user unless example.metadata[:skip_before]
      }

      it "creates a user", skip_before: true  do
        expect { post '/api/users', params: valid_user }.to change(User, :count)
      end
      
      it { expect(response).to have_http_status(:created) }
      it { expect(json.keys).to match_array(['id', 'email']) }
      it { expect(json['id']).to be_a(Numeric) }
      it { expect(json['email']).to eq(valid_user[:user][:email]) }
      it { expect(response.headers['jwt']).to eq(JsonWebToken.encode(user_id: json['id'])) }
    end
  end

  describe '#update' do
    context 'when no user is logged in' do
      before(:each) { patch '/api/users/1' }
      
      it { expect(response).to have_http_status(:unauthorized)}
    end

    context 'when id does not belong to current user' do
      before(:each) { authorized :patch, '/api/users/0', user: user }
      
      it { expect(response).to have_http_status(:forbidden) }
    end

    context "when current_password is not the current user's password" do
      before(:each) {
        params = { user: { current_password: "bad_pass" } }
        authorized :patch, "/api/users/#{user.id}", params: params, user: user
      }
      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'when params are invalid' do
      before(:each) {
        params = { user: { current_password: user.password, email: '' } }
        authorized :patch, "/api/users/#{user.id}", params: params, user: user
      }
      it { expect(response).to have_http_status(:unprocessable_entity) }
    end

    context 'when params are valid' do
      before(:each) { 
        @email = 'newemail@email.com'
        params = { user: { current_password: user.password, email: @email } }
        authorized :patch, "/api/users/#{user.id}", params: params, user: user
      }
      it { expect(response).to have_http_status(:ok) }
      it { expect(json.keys).to match_array(['id', 'email']) }
      it { expect(json['id']).to eq(user.id) }
      it { expect(json['email']).to eq(@email) }
    end

    context 'when updating password without confirmation' do
      before(:each) {
        @old_password_digest = user.password_digest
        params = { user: { current_password: user.password, password: 'A1b2C3d4' } }
        authorized :patch, "/api/users/#{user.id}", params: params, user: user
        user.reload
      }
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(user.password_digest).to eq(@old_password_digest) }
    end

    context 'when updating password with confirmation' do
      before(:each) {
        @old_password_digest = user.password_digest
        params = {
          user: {
            current_password: user.password,
            password: 'A1b2C3d4',
            password_confirmation: 'A1b2C3d4'
          }
        }
        authorized :patch, "/api/users/#{user.id}", params: params, user: user
        user.reload
      }
      it { expect(response).to have_http_status(:ok) }
      it { expect(user.password_digest).to_not eq(@old_password_digest) }
    end
  end
end