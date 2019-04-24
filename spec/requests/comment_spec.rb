require 'rails_helper'

RSpec.describe Comment do
  let(:current_user) { create(:user) }

  describe '#create' do
    context 'when no user is logged in' do
      before(:each) { post '/api/comments' }

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'when params are invalid' do
      before(:each) {
        route = "/api/comments"
        post = create(:post)
        @params = { comment: { body: '', commentable_id: post.id, commentable_type: 'Post' } }
        authorized :post, route, params: @params, user: current_user
      }
      
      it { expect(response).to have_http_status(:unprocessable_entity) }
    end

    context 'when params are valid' do
      before(:each) {
        route = "/api/comments"
        body = 'A bunch of text making up the body of the post'
        post = create(:post)
        @params = { comment: { body: body, commentable_id: post.id, commentable_type: 'Post' } }
        authorized :post, route, params: @params, user: current_user
      }
      
      it { expect(response).to have_http_status(:created) }
      it { expect(json.keys).to match_array(['id', 'body']) }
      it { expect(json['id']).to be_a(Numeric) }
      it { expect(json['body']).to eq(@params[:comment][:body]) }
    end
  end
end