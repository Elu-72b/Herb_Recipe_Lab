require "rails_helper"

# ログインが必要なページへ未ログインでアクセスした場合の確認
RSpec.describe "未ログイン時のアクセス制限", type: :request do
  let(:recipe) { create(:recipe, :public) }
  let(:herb) { create(:herb) }

  shared_examples "ログイン画面へリダイレクトする" do
    it "ログイン画面へリダイレクトする" do
      subject
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "レシピ" do
    describe "GET /recipes/new" do
      subject { get new_recipe_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "POST /recipes" do
      subject { post recipes_path, params: { recipe: { title: "テスト", brewed_at: "2026-10-01" } } }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "レシピは作成されない" do
        expect { subject }.not_to change(Recipe, :count)
      end
    end

    describe "GET /recipes/:id/edit" do
      subject { get edit_recipe_path(recipe) }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "PATCH /recipes/:id" do
      subject { patch recipe_path(recipe), params: { recipe: { title: "変更後" } } }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "DELETE /recipes/:id" do
      subject { delete recipe_path(recipe) }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "レシピは削除されない" do
        recipe
        expect { subject }.not_to change(Recipe, :count)
      end
    end
  end

  describe "感想" do
    describe "GET /recipes/:recipe_id/drinking_logs/new" do
      subject { get new_recipe_drinking_log_path(recipe) }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "POST /recipes/:recipe_id/drinking_logs" do
      subject { post recipe_drinking_logs_path(recipe), params: { drinking_log: { rating: 4 } } }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "感想は作成されない" do
        recipe
        expect { subject }.not_to change(DrinkingLog, :count)
      end
    end
  end

  # ハーブ図鑑の編集は管理画面に集約したため、管理画面で確認する
  describe "ハーブ図鑑（管理画面）" do
    describe "GET /admin/herb/new" do
      subject { get rails_admin.new_path(model_name: "herb") }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "POST /admin/herb/new" do
      subject { post rails_admin.new_path(model_name: "herb"), params: { herb: { name: "テストハーブ" } } }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "ハーブは登録されない" do
        expect { subject }.not_to change(Herb, :count)
      end
    end

    describe "GET /admin/herb/:id/edit" do
      subject { get rails_admin.edit_path(model_name: "herb", id: herb.id) }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "DELETE /admin/herb/:id/delete" do
      subject { delete rails_admin.delete_path(model_name: "herb", id: herb.id) }

      it_behaves_like "ログイン画面へリダイレクトする"

      it "ハーブは削除されない" do
        herb
        expect { subject }.not_to change(Herb, :count)
      end
    end
  end

  describe "その他のページ" do
    describe "GET /home" do
      subject { get home_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /profile" do
      subject { get profile_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /tea_reviews" do
      subject { get tea_reviews_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /bookmarks" do
      subject { get bookmarks_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end

    describe "GET /recipe_suggestion" do
      subject { get recipe_suggestion_path }

      it_behaves_like "ログイン画面へリダイレクトする"
    end
  end

  describe "未ログインでも閲覧できるページ" do
    it "トップページが表示される" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "利用規約が表示される" do
      get terms_path
      expect(response).to have_http_status(:ok)
    end

    it "プライバシーポリシーが表示される" do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "ログイン済みの場合" do
    it "トップページからホームへリダイレクトする" do
      sign_in create(:user)
      get root_path
      expect(response).to redirect_to(home_path)
    end
  end
end

# メールアドレス確認（confirmable）の確認
RSpec.describe "メールアドレス確認", type: :request do
  before { ActionMailer::Base.deliveries.clear }

  describe "POST /users（メールアドレスで新規登録）" do
    subject do
      post user_registration_path, params: {
        user: {
          name: "テストユーザー",
          email: "new_user@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "ユーザーが未確認の状態で作成される" do
      expect { subject }.to change(User, :count).by(1)
      expect(User.last.confirmed_at).to be_nil
    end

    it "登録したメールアドレス宛に確認メールが 1 通送信される" do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(ActionMailer::Base.deliveries.last.to).to eq([ "new_user@example.com" ])
    end

    it "ログイン状態にならず、トップページへリダイレクトする" do
      subject
      expect(response).to redirect_to(root_path)
      get home_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /users/sign_in（ログイン）" do
    subject do
      post user_session_path, params: { user: { email: user.email, password: "password123" } }
    end

    context "メールアドレスが未確認の場合" do
      let(:user) { create(:user, :unconfirmed) }

      it "ログインできない" do
        subject
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq(I18n.t("devise.failure.unconfirmed"))
      end
    end

    context "メールアドレスが確認済みの場合" do
      let(:user) { create(:user) }

      it "ログインできる" do
        subject
        expect(response).to redirect_to(home_path)
      end
    end
  end

  describe "GET /users/confirmation（確認リンク）" do
    let(:user) { create(:user, :unconfirmed) }

    context "正しいトークンの場合" do
      it "確認済みになり、ログインできるようになる" do
        get user_confirmation_path(confirmation_token: user.confirmation_token)
        expect(user.reload.confirmed_at).to be_present

        post user_session_path, params: { user: { email: user.email, password: "password123" } }
        expect(response).to redirect_to(home_path)
      end
    end

    context "不正なトークンの場合" do
      it "確認済みにならない" do
        get user_confirmation_path(confirmation_token: "invalid")
        expect(user.reload.confirmed_at).to be_nil
      end
    end

    context "有効期限（3日）を過ぎたトークンの場合" do
      it "確認済みにならない" do
        user.update_column(:confirmation_sent_at, 4.days.ago)
        get user_confirmation_path(confirmation_token: user.confirmation_token)
        expect(user.reload.confirmed_at).to be_nil
      end
    end
  end
end
