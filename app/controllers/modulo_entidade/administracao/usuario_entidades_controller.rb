# encoding: UTF-8

class ModuloEntidade::Administracao::UsuarioEntidadesController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @users = UsuarioEntidade.pesquisa(current_entidade.id, params[:pesquisa]).page(params[:page]).per(20)
  end

  def show
    @user = current_entidade.usuarios.find(params[:id])
  end

  def new
    @user = current_entidade.usuarios.new
  end

  def edit
    @user = current_entidade.usuarios.find(params[:id])
  end

  def create
    @user = current_entidade.usuarios.new(params[:usuario_entidade])
    if @user.save
      redirect_to [:entidade, :administracao, @user], notice: { success: 'Usuário criado com sucesso.' }
    else
      render action: 'new'
    end
  end

  def update
    @user = current_entidade.usuarios.find(params[:id])
    if @user.update_attributes(params[:usuario_entidade])
      redirect_to [:entidade, :administracao, @user], notice: { success: 'Usuário alterado com sucesso.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = current_entidade.usuarios.find(params[:id])
    if @user == current_user
      redirect_to [:entidade, :administracao, :usuario_entidades], notice: {error: 'Você não pode inativar o usuário que está logado.'}
    else
      @user.toggle_active
      redirect_to [:entidade, :administracao, :usuario_entidades], notice: {success: 'Situação do usuário alterada com sucesso.'}
    end
  end


  private

  def load_title_end_subtitle
    @title = "Usuários"
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
