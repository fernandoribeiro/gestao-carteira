# encoding: utf-8

class ModuloEntidade::SessionController < EntidadeController

  skip_before_filter :authenticate_usuario!, only: [:new, :create]
  skip_before_filter :authenticate_usuario_is_admin!, only: [:new, :create, :destroy]

  def new
    @user = UsuarioEntidade.new
  end

  def create
    @user = UsuarioEntidade.authenticate(params[:username], params[:password])
    if @user.errors.blank?
      cookies[:autentication_token] = @user.autentication_token
      if @user.isAdministrador?
        redirect_to [:entidade], notice: { info: 'Login efetuado com sucesso!' }
      else
        redirect_to [:entidade, :select_unidades]
      end
    else
      render action: 'new'
    end
  end

  def destroy
    cookies.delete :autentication_token
    redirect_to [:entidade, :sign_in], notice: { info: 'Logout efetuado com sucesso!' }
  end

  def select_unidades
  end

  def save_unidades
    if params[:unidades_ids] == 'all'
      # cookies[:unidades_ids] = current_entidade.unidades.map{|u| u.id}
      cookies[:unidades_ids] = current_user.unidades.map{|u| u.id}
    else
      cookies[:unidades_ids] = [params[:unidades_ids]]
    end
    redirect_to params[:url].present? ? params[:url] : entidade_path
  end


  private

    def load_title_end_subtitle
      @title = current_entidade.nome
      @subtitle = 'Autenticação'
    end

end
