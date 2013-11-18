#encoding: UTF-8

class ModuloEntidade::Administracao::ProdutoEntidadesController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @produto_entidades = ProdutoEntidade.where(entidade_id: current_entidade.id).page(params[:page]).per(20)
  end

  def show
    @produto_entidade = ProdutoEntidade.find(params[:id])
  end

  def new
    @produto_entidade = ProdutoEntidade.new
  end

  def create
    @produto_entidade = ProdutoEntidade.new(params[:produto_entidade])
    @produto_entidade.entidade_id = current_entidade.id
    if @produto_entidade.save
      redirect_to [:entidade, :administracao, @produto_entidade], notice: { success: 'Produto da Entidade criado com sucesso.' }
    else
      render action: 'new'
    end
  end

  def edit
    @produto_entidade = ProdutoEntidade.find(params[:id])
  end

  def update
    @produto_entidade = ProdutoEntidade.find(params[:id])
    if @produto_entidade.update_attributes(params[:produto_entidade])
      redirect_to [:entidade, :administracao, @produto_entidade], notice: { success: 'Produto da Entidade alterado com sucesso.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    @produto_entidade = ProdutoEntidade.find(params[:id])
    @produto_entidade.destroy
    redirect_to [:entidade, :administracao, :produto_entidades], notice: {success: 'Produto da Entidade removido com sucesso.'}
  end


  private

  def load_title_end_subtitle
    @title = case params[:action]
      when 'index' then 'Produtos da Entidade'
      when 'new' then 'Novo Produto da Entidade'
      when 'create' then 'Novo Produto da Entidade'
      when 'edit' then 'Editar Produto da Entidade'
      when 'update' then 'Atualizar Produto da Entidade'
      when 'show' then 'Detalhes do Produto da Entidade'
      else 'SubTitle'
    end
  end

end
