# encoding: utf-8

class EntidadeController < ApplicationController

  before_filter :valid_current_entidade!
  # before_filter :authenticate_usuario!

  helper_method :user_authenticated?
  helper_method :current_user
  helper_method :current_entidade
  helper_method :current_unidades
  helper_method :current_user_is_admin?

  def index
    current_entidade
  end


  private

  def default_url_options(options = {})
    if current_entidade.present?
      options[:entidade_slug] = current_entidade.slug
    end
    options
  end

  def authenticate_usuario!
    unless user_authenticated?
      redirect_to entidade_sign_in_path
    end
  end

  def authenticate_usuario_is_admin!
    unless current_user_is_admin?
      redirect_to entidade_path, notice: {error: 'Você não tem permissão para acessar esse módulo!' }
    end
  end

  def user_authenticated?
    current_user.present?
  end

  def valid_current_entidade!
    unless current_entidade.present?
      redirect_to root_path, notice: { error: 'Entidade não Encontrada!' }
    end
  end

  def current_user_is_admin?
    current_user.isAdministrador?
  end

  def current_user
    @current_user ||= current_entidade.usuarios.find_by_active_and_autentication_token(true, cookies[:autentication_token]) if cookies[:autentication_token]
  end

  def current_entidade
    @current_entidade ||= Entidade.find_by_active_and_slug(true, params[:entidade_slug]) if params[:entidade_slug]
  end

  def current_unidades
    @current_unidades ||= current_entidade.unidades.where('id IN(?)', cookies[:unidades_ids].split(/&/)).all if cookies[:unidades_ids]
  end

  def load_title_end_subtitle
    @title = current_entidade.nome
    @subtitle = ''
  end

end
