module ModuloEntidade::Administracao::UnidadesHelper

  def unidades_for_select
    Unidade.where(entidade_id: current_entidade.id, active: true)
           .order(:nome)
           .uniq
           .map{ |unid| [unid.nome, unid.id] }
  end

end
