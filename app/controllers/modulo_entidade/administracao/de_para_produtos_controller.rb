#encoding: UTF-8

class ModuloEntidade::Administracao::DeParaProdutosController < ModuloEntidade::AdminitracaoController

  def index
    @de_para_produtos = DeParaProduto.joins(:produto)
    																 .joins(:unidade)
    																 .where(unidade_id: current_entidade.unidades.pluck(:id))
    																 .order('unidades.nome, produtos.nome')
    																 .page(params[:page]).per(20)
  end

  def destroy
    @de_para_produto = DeParaProduto.find(params[:id])
    @de_para_produto.destroy
    redirect_to [:entidade, :administracao, :de_para_produtos], notice: { success: 'De-Para excluída com sucesso!' }
  end

  def index_sem_de_para
    produtos_de_para_ids = DeParaProduto.where(produto_id: Produto.where(unidade_id: Unidade.where(entidade_id: current_entidade.id))
                                                                  .pluck(:id))
                                        .pluck(:produto_id)
                                        .uniq
    @produtos = Produto.joins(:unidade)
                       .where(unidade_id: Unidade.where(entidade_id: current_entidade.id))
                       .where('produtos.id NOT IN(?)', produtos_de_para_ids.sort)
                       .order('unidades.nome, produtos.codigo_sistema_legado, produtos.nome')
                       .page(params[:page]).per(50)
  end


  private

    def load_title_end_subtitle
      @title = case params[:action]
        when 'index' then 'De-Para de Produtos'
        when 'destroy' then 'Excluir De-Para de Produtos'
        else 'SubTitle'
      end
    end

end
