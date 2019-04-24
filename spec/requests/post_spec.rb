require 'rails_helper'

RSpec.describe Post do
  let(:current_user) { create(:user) }

  describe '#index' do
    context 'when no user is logged in' do
      before(:each) {
        get '/api/posts'
      }

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context "when user doesn't exist" do
      before(:each) {
        authorized :get, '/api/posts', user: current_user
      }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json.length).to be 0 }
    end

    context "when there are no posts" do
      before(:each) {
        author = create(:user)
        authorized :get, "/api/posts", user: current_user
      }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json.length).to be 0 }
    end

    context "when there is one post" do
      before(:each) {
        @count = 1
        author = create(:user_with_posts, posts_count: @count)
        authorized :get, "/api/posts", user: current_user
      }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json.length).to be @count }
    end

    context "when there are multiple posts by multiple authors" do
      before(:each) {
        @first = 3
        @second = 2
        create(:user_with_posts, posts_count: @first)
        create(:user_with_posts, posts_count: @second)
        authorized :get, "/api/posts", user: current_user
      }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json.length).to be @first + @second }
      it { expect(json[0].keys).to match_array(['id', 'title', 'body']) }
    end
  end

  describe '#show' do
    context 'when no user is logged in' do
      before(:each) {
        get '/api/posts/0'
      }

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context "when post doesn't exist" do
      before(:each) {
        authorized :get, '/api/posts/0', user: current_user
      }

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when post does exist' do
      before(:each) {
        @post = create(:post, user: current_user)
        authorized :get, "/api/posts/#{@post.id}", user: current_user
      }

      it { expect(response).to have_http_status(:ok) }
      it { expect(json.keys).to match_array(['id', 'title', 'body']) }
      it { expect(json['id']).to be @post.id }
      it { expect(json['title']).to eq @post.title }
      it { expect(json['body']).to eq @post.body }
    end
  end

  describe 'users' do
    describe '#index' do
      context 'when no user is logged in' do
        before(:each) {
          get '/api/users/0/posts'
        }

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context "when user doesn't exist" do
        before(:each) {
          authorized :get, '/api/users/0/posts', user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be 0 }
      end

      context "when user has no posts" do
        before(:each) {
          author = create(:user)
          authorized :get, "/api/users/#{author.id}/posts", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be 0 }
      end

      context "when user has one post" do
        before(:each) {
          @count = 1
          author = create(:user_with_posts, posts_count: @count)
          authorized :get, "/api/users/#{author.id}/posts", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end

      context "when user has multiple posts" do
        before(:each) {
          @count = 3
          author = create(:user_with_posts, posts_count: @count)
          authorized :get, "/api/users/#{author.id}/posts", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end

      context "when another user has posts" do
        before(:each) {
          @count = 3
          author = create(:user_with_posts, posts_count: @count)
          create(:user_with_posts, posts_count: 2)
          authorized :get, "/api/users/#{author.id}/posts", user: current_user
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(json.length).to be @count }
      end
    end

    describe '#create' do
      context 'when no user is logged in' do
        before(:each) {
          post '/api/users/0/posts'
        }

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context 'when id does not belong to current user' do
        before(:each) { authorized :post, '/api/users/0/posts', user: current_user }
        
        it { expect(response).to have_http_status(:forbidden) }
      end

      context 'when params are invalid' do
        before(:each) {
          route = "/api/users/#{current_user.id}/posts"
          @params = { post: { title: '', body: '' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:unprocessable_entity) }
      end

      context 'when params are valid' do
        before(:each) {
          route = "/api/users/#{current_user.id}/posts"
          @params = { post: { title: 'Good Title', body: 'A bunch of text making up the body of the post' } }
          authorized :post, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:created) }
        it { expect(json.keys).to match_array(['id', 'title', 'body']) }
        it { expect(json['id']).to be_a(Numeric) }
        it { expect(json['title']).to eq(@params[:post][:title]) }
        it { expect(json['body']).to eq(@params[:post][:body]) }
      end
    end
    
    describe '#update' do
      context 'when no user is logged in' do
        before(:each) {
          patch '/api/users/0/posts/0'
        }

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context 'when user id does not belong to current user' do
        before(:each) { authorized :patch, '/api/users/0/posts/0', user: current_user }
        
        it { expect(response).to have_http_status(:forbidden) }
      end

      context "when post id does not belong to any of the current user's posts" do
        before(:each) {
          route = "/api/users/#{current_user.id}/posts/0"
          @params = { patch: { title: '', body: '' } }
          authorized :patch, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:not_found) }
      end

      context 'when params are invalid' do
        before(:each) {
          post = create(:post, user: current_user)
          route = "/api/users/#{current_user.id}/posts/#{post.id}"
          @params = { post: { title: '', body: '' } }
          authorized :patch, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:unprocessable_entity) }
      end

      context 'when params are valid' do
        before(:each) {
          post = create(:post, user: current_user)
          route = "/api/users/#{current_user.id}/posts/#{post.id}"
          @params = { post: { title: 'Good Title', body: 'A bunch of text making up the body of the post' } }
          authorized :patch, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:ok) }
        it { expect(json.keys).to match_array(['id', 'title', 'body']) }
        it { expect(json['id']).to be_a(Numeric) }
        it { expect(json['title']).to eq(@params[:post][:title]) }
        it { expect(json['body']).to eq(@params[:post][:body]) }
      end
    end

    describe '#destroy' do
      context 'when no user is logged in' do
        before(:each) {
          delete '/api/users/0/posts/0'
        }

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context 'when user id does not belong to current user' do
        before(:each) { authorized :delete, '/api/users/0/posts/0', user: current_user }
        
        it { expect(response).to have_http_status(:forbidden) }
      end

      context "when id does not belong to any of the current user's posts" do
        before(:each) {
          route = "/api/users/#{current_user.id}/posts/0"
          @params = { delete: { title: '', body: '' } }
          authorized :delete, route, params: @params, user: current_user
        }
        
        it { expect(response).to have_http_status(:not_found) }
      end

      context "when user is authenticated and post is found" do
        before(:each) {
          @post = create(:post, user: current_user)
          route = "/api/users/#{current_user.id}/posts/#{@post.id}"
          authorized :delete, route, user: current_user
        }
        
        it { expect(response).to have_http_status(:ok) }
        it { expect(json.keys).to match_array(['id', 'title', 'body']) }
        it { expect(json['id']).to be @post.id }
        it { expect(json['title']).to eq @post.title }
        it { expect(json['body']).to eq @post.body }
      end
    end
  end
end