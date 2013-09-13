class CreateRelatorioFrequenciaValores < ActiveRecord::Migration
  def change
    create_table :relatorio_frequencia_valores do |t|
      t.integer :cliente_id
      t.date :data_primeira_compra
      t.integer :numero_de_compras_no_mes
      t.decimal :valor_comprado_no_mes
      t.timestamps
    end
  end
end
