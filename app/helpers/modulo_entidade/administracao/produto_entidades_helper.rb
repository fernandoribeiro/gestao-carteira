module ModuloEntidade::Administracao::ProdutoEntidadesHelper

  def categorias_for_select
    ProdutoEntidade.select(:marca)
           				 .where(entidade_id: current_entidade.id)
           				 .order(:marca)
           				 .uniq
           				 .map{ |prod| [prod.marca, "'#{prod.marca}'"] }
  end

end
