# encoding: UTF-8

class ModuloEntidade::Administracao::MetasController < ModuloEntidade::AdminitracaoController
  
   def index
    params[:pesquisa] ||= {}
    @metas = Meta.joins(:unidade).where("unidades.entidade_id = ?",current_entidade).page(params[:page]).per(20)
  end

  def show
    @meta = Meta.find(params[:id])
  end

  def new
    @meta = Meta.new
  end

  def edit
    @meta = Meta.find(params[:id])
  end

  def create
    @meta = Meta.new(params[:meta])
    if @meta.save
      redirect_to [:entidade, :administracao, :metas], notice: {success: 'Meta criada com sucesso.'}
    else
      render action: 'new'
    end
  end

  def update
    @meta = Meta.find(params[:id])
    if @meta.update_attributes(params[:meta])
      redirect_to [:entidade, :administracao, :metas], notice: {success: 'Meta alterada com sucesso.'}
    else
      render action: 'edit'
    end
  end

  def destroy
    @meta = Meta.find(params[:id])
    @meta.destroy
    redirect_to [:entidade, :administracao, :metas], notice: {success: 'Meta removida com sucesso.'}
  end


  private

  def load_title_end_subtitle
    @title = 'Metas'
    @subtitle = case params[:action]
      when 'index' then 'Lista de Metas'
      when 'new' then 'Criar Meta'
      when 'create' then 'Criar Meta'
      when 'edit' then 'Editar Meta'
      when 'update' then 'Editar Meta'
      when 'show' then 'Detalhes da Meta'
      else 'SubTitle'
    end
  end
  
end
