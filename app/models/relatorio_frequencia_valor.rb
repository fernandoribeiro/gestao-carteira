class RelatorioFrequenciaValor < ActiveRecord::Base
  
  def self.popula_tabela
    RelatorioFrequenciaValor.delete_all
    sql = "INSERT INTO relatorio_frequencia_valores(valor_comprado_no_mes,cliente_id,unidade_id,ano,mes) (SELECT SUM(valor) AS valor_comprado_no_mes,cliente_id as cliente_id,unidade_id AS unidade_id,DATE_PART('YEAR', data_emissao) as ano,DATE_PART('MONTH', data_emissao) as mes from nota_fiscais
           GROUP BY cliente_id, DATE_PART('YEAR', data_emissao),DATE_PART('MONTH', data_emissao),unidade_id
           ORDER BY DATE_PART('MONTH', data_emissao))"
    ActiveRecord::Base.connection.execute(sql)
  end
  
end
