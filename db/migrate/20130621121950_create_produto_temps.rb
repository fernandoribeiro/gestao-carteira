class CreateProdutoTemps < ActiveRecord::Migration

  def change
    create_table :produto_temps do |t|
      t.string  :nome
      t.string  :codigo_sistema_legado, length: 100
      t.text    :outros_campos
      t.integer :unidade_id
      t.boolean :sent_to_master

      t.timestamps
    end
  end

end
