class CorrigeCamposNaTabelaDeRelatorioDeFaturamento < ActiveRecord::Migration
  def up
    add_column :relatorio_frequencia_valores,:ano,:integer
    add_column :relatorio_frequencia_valores,:mes,:integer
  end

  def down
    remove_column :relatorio_frequencia_valores,:ano
    remove_column :relatorio_frequencia_valores,:mes
  end
end
