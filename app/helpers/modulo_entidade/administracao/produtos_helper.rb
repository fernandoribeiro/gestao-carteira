module ModuloEntidade::Administracao::ProdutosHelper

  def produtos_for_select
    # Produto.select('ON(produtos.codigo_sistema_legado, produtos.nome) produtos.id')
    # 			 .select('produtos.codigo_sistema_legado, produtos.nome')
    # 			 .joins(:unidade)
    #        .where('unidades.entidade_id = ? AND produtos.active = ?', current_entidade.id, true)
    #        .order('produtos.codigo_sistema_legado, produtos.nome')
    #        .uniq
    #        .map{ |prod| [('[' + prod.codigo_sistema_legado + '] ' + prod.nome), prod.id] }
    ProdutoEntidade.where(entidade_id: current_entidade.id)
           				 .order(:descricao, :codigo)
           				 .uniq
           				 .map{ |prod| [('[' + prod.codigo + '] ' + prod.descricao), prod.id] }
  end

end
