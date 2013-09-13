# encoding: utf-8
class Administracao::UsuarioAdministradoresController < AdministracaoController

  def index
    params[:pesquisa] ||= {}
    @users = UsuarioAdministrador.pesquisa_usuarios(params[:pesquisa]).page(params[:page]).per(10)
  end

  def show
    @user = UsuarioAdministrador.find(params[:id])
  end

  def new
    @user = UsuarioAdministrador.new
  end

  def edit
    @user = UsuarioAdministrador.find(params[:id])
  end

  def create
    @user = UsuarioAdministrador.new(params[:usuario_administrador])
    @user.active = true
   if @user.save
     redirect_to [:administracao, @user], notice: {success: 'Usuário Criado.'}
   else
     render action: "new"
   end
  end

  def update
    @user = UsuarioAdministrador.find(params[:id])
    if @user.update_attributes(params[:usuario_administrador])
      redirect_to [:administracao, @user], notice: {success: 'Usuário Alterado.'}
    else
      render action: "edit"
    end
  end

  def destroy
    @user = UsuarioAdministrador.find(params[:id])
    if @user == current_user
      redirect_to administracao_usuario_administradores_path, notice: {error: 'Você não pode inativar o usuário que está logado.'}
    else
      @user.toggle_active
      redirect_to administracao_usuario_administradores_path, notice: {success: 'Situação do Usuário Alterado.'}
    end
  end

  private
  def load_title_end_subtitle
    @title = "Usuários Administradores"
    @subtitle = case params[:action]
      when "index" then "Lista de Usuários"
      when "new" then "Criar Usuário"
      when "create" then "Criar Usuário"
      when "edit" then "Editar Usuário"
      when "update" then "Editar Usuário"
      when "show" then "Detalhes do Usuário"
      else "SubTitle"
    end
  end
end
