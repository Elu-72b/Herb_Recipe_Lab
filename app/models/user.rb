class User < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :herbs, dependent: :nullify
  has_many :tea_reviews, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_recipes, through: :bookmarks, source: :recipe
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  NAME_MAX_LENGTH = 20

  validates :name, length: { maximum: NAME_MAX_LENGTH }
  # 新規登録では任意（既存仕様）。プロフィール編集では空にさせない
  validates :name, presence: true, on: :profile_update

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end
  # 既存の連携済みユーザーを探すだけ（作成はしない）。
  # ログイン画面からの Google 認証では未登録なら作成させないため、検索と作成を分けている。
  def self.find_for_oauth(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end

  # 新規登録の意図があるときだけ呼ぶ。
  def self.create_from_omniauth(auth)
    create(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      name: auth.info.name
    )
  end

  def google_user?
    provider.present?
  end

  # プロフィール（名前・メールアドレス）を更新する。
  # Google ユーザーはメールを Google 側で管理するため名前のみ。
  # 通常ユーザーはメールを変えるときだけ現在のパスワードを求める。
  def update_profile(params)
    assign_attributes(google_user? ? params.slice(:name) : params.slice(:name, :email))

    valid = valid?(:profile_update)
    if email_will_change_meaningfully? && !valid_password?(params[:current_password].to_s)
      errors.add(:current_password, "が正しくありません")
      valid = false
    end

    valid && save(context: :profile_update)
  end

  # Devise の update_with_password は新パスワードが空だと「変更なし」で成功扱いにするため、空を明示的に弾く
  def update_password(params)
    if params[:password].blank?
      errors.add(:password, :blank)
      return false
    end

    update_with_password(params)
  end

  private

  # Devise が保存前に strip / downcase するため、正規化後の値で比較する
  def email_will_change_meaningfully?
    email.to_s.strip.downcase != email_in_database
  end
end
