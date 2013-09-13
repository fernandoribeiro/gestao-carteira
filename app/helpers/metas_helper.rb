module MetasHelper

  def metas_for_select
    Meta.joins(:unidade)
        .where('unidades.entidade_id = ?', current_entidade.id)
        .order(:data_inicio)
        .uniq
        .map{ |meta| [
                        (meta.data_inicio.to_date.to_s + ' - ' +
                         meta.data_final.to_date.to_s + ' (' +
                         meta.valor_de_faturamento.real.to_s + ')'
                        ),
                        meta.id
                      ]
            }
  end

end
