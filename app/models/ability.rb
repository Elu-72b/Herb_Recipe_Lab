class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.admin?

    can :access, :rails_admin
    can :read, :dashboard
    # ハーブ図鑑・タグマスタ: 管理画面のみでフル CRUD
    can :manage, [ Herb, FlavorTag, FunctionalTag, CautionTag ]
    # 既製ブレンド: 作成・編集・削除（編集できる項目は rails_admin 側で商品情報に限定）
    can :manage, TeaReview

    # 公開レシピのみ: 閲覧・削除・非公開化。非公開レシピは管理画面に表示しない
    can [ :read, :export, :update, :destroy ], Recipe, is_public: true
    # 更新は値を反映した後に判定されるため、保存済みの値（公開中か）で判定する。
    # 公開 → 非公開は可能、非公開 → 公開（他人の非公開レシピの公開）は不可
    can :update, Recipe do |recipe|
      recipe.is_public_in_database
    end

    # ユーザー: 閲覧・削除・admin 付与のみ。自分自身は変更・削除できない（ロックアウト防止）
    can [ :read, :export, :update, :destroy ], User
    cannot [ :update, :destroy ], User, id: user.id
  end
end
