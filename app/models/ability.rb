class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.admin?

    can :access, :rails_admin
    can :read, :dashboard
    # モデルごとの権限は #102 / #103 で追記する
  end
end
