class InsereCampoUnidadeIdEmRelatorioFaturamento < ActiveRecord::Migration
  def up
    add_column :relatorio_frequencia_valores,:unidade_id,:integer
  end

  def down
    remove_column :relatorio_frequencia_valores,:unidade_id
  end
end
