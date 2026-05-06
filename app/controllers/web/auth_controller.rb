# frozen_string_literal: true

class Web::AuthController < Web::ApplicationController
  def callback
    user_info = request.env['omniauth.auth'][:info]
    email = user_info.fetch(:email, '').downcase
    user = User.find_or_initialize_by(email:)
    user.name = user_info.fetch(:name)
    user.nickname = user_info.fetch(:nickname, '')
    user.image_url = user_info.fetch(:image, '')
    user.token = request.env['omniauth.auth'][:credentials].fetch(:token)
    if user.save
      session[:user_id] = user.id
      redirect_to root_path, notice: t('flash.auth.success')
    else
      redirect_to root_path, alert: t('flash.auth.failure')
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t('flash.auth.logout')
  end
end