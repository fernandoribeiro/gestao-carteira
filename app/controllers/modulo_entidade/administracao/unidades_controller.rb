# encoding: UTF-8

class ModuloEntidade::Administracao::UnidadesController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @unidades = Unidade.pesquisa(current_entidade.id, params[:pesquisa]).page(params[:page]).per(20)
  end

  def show
    @unidade = Unidade.find(params[:id])
  end

  def new
    @unidade = Unidade.new
  end

  def edit
    @unidade = Unidade.find(params[:id])
  end

  def create
    @unidade = Unidade.new(params[:unidade])
    @unidade.entidade = current_entidade
    if @unidade.save
      redirect_to [:entidade, :administracao, @unidade], notice: {success: 'Unidade criada com sucesso.'}
    else
      render action: 'new'
    end
  end

  def update
    @unidade = Unidade.find(params[:id])
    if @unidade.update_attributes(params[:unidade])
      redirect_to [:entidade, :administracao, @unidade], notice: {success: 'Unidade alterada com sucesso.'}
    else
      render action: 'edit'
    end
  end

  def destroy
    @unidade = Unidade.find(params[:id])
    @unidade.toggle_active
    redirect_to [:entidade, :administracao, :unidades], notice: {success: 'Situação da unidade alterada.'}
  end


  private

  def load_title_end_subtitle
    @title = 'Unidades'
    @subtitle = case params[:action]
      when 'index' then 'Lista de Unidades'
      when 'new' then 'Criar Unidade'
      when 'create' then 'Criar Unidade'
      when 'edit' then 'Editar Unidade'
      when 'update' then 'Editar Unidade'
      when 'show' then 'Detalhes da Unidade'
      else 'SubTitle'
    end
  end

end
