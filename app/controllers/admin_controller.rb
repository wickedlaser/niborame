class AdminController < ApplicationController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    return if session[:admin_authenticated]

    redirect_to admin_login_path, alert: '管理者ログインが必要です。'
  end
end
