require 'rails_helper'

RSpec.describe Comment do
  let(:current_user) { create(:user) }

  describe 'posts' do
    describe '#index' do
      context 'when no user is logged in' do
        before(:each) { get '/api/posts/0/comments' }

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context "when post doesn't exist" do
        before(:each) {
          authorized :get, '/api/posts/0/comments', user: current_user
        }

        it { expect(response).to have_http_status(:not_found) }
      end

      context "when post has no comments" do
        before(:each) {
          post = create(:post)
          authorized :get, "/api/posts/#{post.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be 0 }
      end

      context "when post has one comment" do
        before(:each) {
          @count = 1
          post = create(:post_with_comments, comments_count: @count )
          authorized :get, "/api/posts/#{post.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end

      context "when post has multiple comments" do
        before(:each) {
          @count = 3
          post = create(:post_with_comments, comments_count: @count )
          authorized :get, "/api/posts/#{post.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end

      context "when another post has comments" do
        before(:each) {
          @count = 3
          post = create(:post_with_comments, comments_count: @count )
          create(:post_with_comments, comments_count: 2)
          authorized :get, "/api/posts/#{post.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end
    end

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

  describe 'comments' do
    describe '#index' do
      context 'when no user is logged in' do
        before(:each) { get '/api/posts/0/comments' }

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context "when comment doesn't exist" do
        before(:each) {
          authorized :get, '/api/comments/0/comments', user: current_user
        }

        it { expect(response).to have_http_status(:not_found) }
      end

      context "when comment has no comments" do
        before(:each) {
          comment = create(:comment)
          authorized :get, "/api/comments/#{comment.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be 0 }
      end

      context "when comment has one comment" do
        before(:each) {
          @count = 1
          comment = create(:comment_with_comments, comments_count: @count )
          authorized :get, "/api/comments/#{comment.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end

      context "when comment has multiple comments" do
        before(:each) {
          @count = 3
          comment = create(:comment_with_comments, comments_count: @count )
          authorized :get, "/api/comments/#{comment.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end

      context "when another comment has comments" do
        before(:each) {
          @count = 3
          comment = create(:comment_with_comments, comments_count: @count )
          create(:comment_with_comments, comments_count: 2)
          authorized :get, "/api/comments/#{comment.id}/comments", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end
    end

    describe '#create' do
      context 'when no user is logged in' do
        before(:each) { post '/api/comments/0/comments' }
  
        it { expect(response).to have_http_status(:unauthorized) }
      end

      context 'when post does not exist' do
        before(:each) {
          route = "/api/comments/0/comments"
          @params = { comment: { body: '' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:not_found) }
      end
  
      context 'when params are invalid' do
        before(:each) {
          comment = create(:comment)
          route = "/api/comments/#{comment.id}/comments"
          @params = { comment: { body: '' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:unprocessable_entity) }
      end
  
      context 'when params are valid' do
        before(:each) {
          comment = create(:comment)
          route = "/api/comments/#{comment.id}/comments"
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