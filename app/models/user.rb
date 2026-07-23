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
         :omniauthable, omniauth_providers: [:google_oauth2]
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
end
