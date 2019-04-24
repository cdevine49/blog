require 'rails_helper'

RSpec.describe Comment do
  let(:current_user) { create(:user) }

  describe 'posts' do
    describe '#create' do
      context 'when no user is logged in' do
        before(:each) { post '/api/posts/0/comments' }
  
        it { expect(response).to have_http_status(:unauthorized) }
      end

      context 'when post does not exist' do
        before(:each) {
          route = "/api/posts/0/comments"
          @params = { comment: { body: '' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:not_found) }
      end
  
      context 'when params are invalid' do
        before(:each) {
          post = create(:post)
          route = "/api/posts/#{post.id}/comments"
          @params = { comment: { body: '' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:unprocessable_entity) }
      end
  
      context 'when params are valid' do
        before(:each) {
          post = create(:post)
          route = "/api/posts/#{post.id}/comments"
          @params = { comment: { body: 'A bunch of text making up the body of the post' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:created) }
        it { expect(json.keys).to match_array(['id', 'body']) }
        it { expect(json['id']).to be_a(Numeric) }
        it { expect(json['body']).to eq(@params[:comment][:body]) }
      end
    end
  end
end