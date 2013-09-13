# encoding: UTF-8

module Relatorio

  def trata_parametros(params)
    indicador_id = params[:indicador_id].present? ? params[:indicador_id].to_i : ''
    meta_id = params[:meta_id].present? ? params[:meta_id].to_i : ''
    dias_uteis = params[:dias_uteis].to_s
    unidade_id = params[:unidade_id].present? ? params[:unidade_id].to_i : ''
    produto_id = params[:produto_id].present? ? params[:produto_id].to_i : ''
    mes = params[:meses].split('_').first.to_i rescue nil
    ano = params[:meses].split('_').last.to_i rescue nil
    mes_corrente = params[:mes_ano_corrente].present? ? params[:mes_ano_corrente].split('_').first.to_i : ''
    ano_corrente = params[:mes_ano_corrente].present? ? params[:mes_ano_corrente].split('_').last.to_i : ''
    dias = params[:dias].split('#').join(', ') rescue nil

    params_processado = {
      indicador_id: indicador_id,
      meta_id: meta_id,
      dias_uteis: dias_uteis,
      unidade_id: unidade_id,
      produto_id: produto_id,
      mes: mes,
      ano: ano,
      mes_corrente: mes_corrente,
      ano_corrente: ano_corrente,
      dias: dias
    }
  end

  module_function :trata_parametros

end
