require 'rails_helper'

RSpec.describe "Posts", type: :request do
  include ImageHelper
  # ログイン処理
  shared_context :login do
    let(:user) {create(:user)}
    before do
      @header         = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
      @header.merge! user.create_new_auth_token  
    end
  end
  describe "POST /posts" do
    context "画像を添付せずに正常に投稿した場合" do
      #ログイン処理
      include_context :login
      before do
        @post_params = attributes_for(:post)
      end
      it "リクエストが成功する" do
        post api_posts_path, params: { post: @post_params }.to_json, headers: @header
        expect(response.status).to eq 201
      end
      it "1件のレコードがPostsテーブルに登録される" do
        expect do
          post api_posts_path, params: { post: @post_params }.to_json, headers: @header
        end.to change(Post, :count).by(1)
      end
    end

    context "画像を添付して正常に投稿した場合" do
      #ログイン処理
      include_context :login
      before do
        @post_params         = attributes_for(:post)
        #画像を読み込み
        base64_encoded       = image_to_base64("test.png")
        #パラメータに埋め込み
        @post_params[:image] = base64_encoded
      end
      it "投稿したデータにファイルがアタッチされている" do
        post api_posts_path, params: { post: @post_params }.to_json, headers: @header
        body   = JSON.parse(response.body)
        posted = Post.find(body["timeline"]["id"])
        # 添付ファイルがアタッチされている
        expect(posted.picture.attached?).to be_truthy
      end
    end
  end
end
