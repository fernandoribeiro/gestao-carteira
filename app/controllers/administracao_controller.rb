# encoding: utf-8
class AdministracaoController < ApplicationController

  before_filter :authenticate_usuario!

  helper_method :user_authenticated?
  helper_method :current_user

  def index
  end

  private
  def authenticate_usuario!
    unless user_authenticated?
      redirect_to administracao_sign_in_path
    end
  end

  def user_authenticated?
    current_user.present?
  end

  def current_user
    @current_user ||= UsuarioAdministrador.find_by_active_and_autentication_token(true, cookies[:autentication_token]) if cookies[:autentication_token]
  end

  def load_title_end_subtitle
    @title = 'Gestão de Carteira'
    @subtitle = 'Administração'
  end

end
