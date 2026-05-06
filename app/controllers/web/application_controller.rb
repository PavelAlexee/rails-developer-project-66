# frozen_string_literal: true

class Web::ApplicationController < ApplicationController
  helper_method :current_user
  helper_method :signed_in?


  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id].present?
  end

  def signed_in?
    session[:user_id].present? && current_user.present?
  end

  def authenticate_user!
    return if signed_in?

    redirect_to root_path, alert: t('flash.auth_required')
  end
end
