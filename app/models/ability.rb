class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.admin?

    can :access, :rails_admin
    can :read, :dashboard
    # ハーブ図鑑・タグマスタ: 管理画面のみでフル CRUD
    can :manage, [ Herb, FlavorTag, FunctionalTag, CautionTag ]
  end
end
