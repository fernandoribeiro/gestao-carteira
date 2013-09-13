module ModuloEntidade::Administracao::ProdutosHelper

  def produtos_for_select
    Produto.joins(:unidade)
           .where('unidades.entidade_id = ? AND produtos.active = ?', current_entidade.id, true)
           .order('produtos.nome, produtos.codigo_sistema_legado')
           .uniq
           .map{ |prod| [('[' + prod.codigo_sistema_legado + '] ' + prod.nome), prod.id] }
  end

end
