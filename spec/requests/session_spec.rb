require 'rails_helper'

RSpec.describe 'Session' do

  let(:user) { create(:user) }
  describe '#create' do
    context 'when a user is logged in' do
      before(:each) { authorized :post, '/api/session', user: create(:user) }
      
      it { expect(response).to have_http_status(:forbidden)}
    end

    context 'with invalid credentials' do
      before(:each) do
        post '/api/session', params: { user: { email: 'notmy@email.com', password: 'bad pass' } }
      end

      it { expect(response).to have_http_status(422) }
      it { expect(json).to match({ 'errors' => 'Invalid email or password' }) }
    end

    context 'with valid credentials' do
      before(:each) do
        post '/api/session', params: { user: { email: user.email, password: user.password } }
      end

      it { expect(response).to have_http_status(:ok)}
      it { expect(json.keys).to match_array(['id', 'email']) }
      it { expect(json['id']).to eq(user.id) }
      it { expect(json['email']).to eq(user.email) }
      it { expect(response.headers['jwt']).to eq(JsonWebToken.encode(user_id: user.id)) }
    end
  end

  describe '#show' do
    context 'when logged in' do
      before(:each) { authorized :get, '/api/session', user: user }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json.keys).to match_array(['id', 'email']) }
      it { expect(json['id']).to eq(user.id) }
      it { expect(json['email']).to eq(user.email) }
    end

    context 'when logged out' do
      before(:each) { get '/api/session' }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe '#destroy' do
    context 'when logged out' do
      before(:each) { delete '/api/session' }

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'when logged in' do
      before(:each) { authorized :delete, '/api/session', user: user }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.headers['jwt']).to be(nil) }
    end
  end
end