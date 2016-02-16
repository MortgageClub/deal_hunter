class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  private

  def admin?
    @current_user.admin?
  end
end