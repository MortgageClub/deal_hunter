class BaseController < ApplicationController
  before_action :authorize_user!

  def authorize_user!
    authorize User
  end
end