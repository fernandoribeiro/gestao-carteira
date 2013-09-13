# encoding: utf-8

class Administracao::EntidadesController < AdministracaoController

  def index
    params[:pesquisa] ||= {}
    @entidades = Entidade.pesquisa_entidades(params[:pesquisa]).page(params[:page]).per(10)
  end

  def show
    @entidade = Entidade.find(params[:id])
  end

  def new
    @entidade = Entidade.new
    @administrador = @entidade.usuario_entidades.new
  end

  def edit
    @entidade = Entidade.find(params[:id])
  end

  def create
    @entidade = Entidade.new(params[:entidade])
    @entidade.usuarios.first.eh_administrador = UsuarioEntidade::SIM
    if @entidade.save
      redirect_to [:administracao, @entidade], notice: {success: 'Entidade criada com sucesso.'}
    else
      render action: 'new'
    end
  end

  def update
    @entidade = Entidade.find(params[:id])
    if @entidade.update_attributes(params[:entidade])
      redirect_to [:administracao, @entidade], notice: {success: 'Entidade alterada com sucesso.'}
    else
      render action: 'edit'
    end
  end

  def destroy
    @entidade = Entidade.find(params[:id])
    @entidade.toggle_active
    redirect_to [:administracao, :entidades], notice: {success: 'Situação da entidade alterada.'}
  end


  private

  def load_title_end_subtitle
    @title = 'Entidades'
    @subtitle = case params[:action]
      when 'index' then 'Lista de Entidades'
      when 'new' then 'Criar Entidade'
      when 'create' then 'Criar Entidade'
      when 'edit' then 'Editar Entidade'
      when 'update' then 'Editar Entidade'
      when 'show' then 'Detalhes da Entidade'
      else 'SubTitle'
    end
  end

end
