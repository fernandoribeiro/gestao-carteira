class CreateNotaFiscais < ActiveRecord::Migration
  def change
    create_table :nota_fiscais do |t|
      t.integer :vendedor_id
      t.integer :unidade_id
      t.integer :cliente_id
      t.string :codigo_sistema_legado
      t.string :numero_documento
      t.date :data_emissao
      t.text :descricao
      t.text :outros_campos
      t.boolean :active
      t.timestamps
    end
  end
end
