class BaseController < ApplicationController
  before_action :authorize_user!, except: [:receive_sms]

  def authorize_user!
    authorize User
  end
end