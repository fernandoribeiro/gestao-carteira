# encoding: utf-8
class Administracao::SessionController < AdministracaoController
  skip_before_filter :authenticate_usuario!, only: [:new, :create]

  def new
    @user = UsuarioAdministrador.new
  end

  def create
    @user = UsuarioAdministrador.authenticate(params[:username], params[:password])

    if @user.errors.blank?
      cookies[:autentication_token] = @user.autentication_token
      redirect_to administracao_path, notice: {info: "Login efetuado com sucesso!"}
    else
      render action: "new"
    end
  end

  def destroy
    cookies.delete :autentication_token
    redirect_to administracao_sign_in_url, notice: {info: "Logout efetuado com sucesso!"}
  end

  private

  def load_title_end_subtitle
    @title = "Administração"
    @subtitle = "Autenticação"
  end
end
