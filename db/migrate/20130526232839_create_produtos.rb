class CreateProdutos < ActiveRecord::Migration
  def change
    create_table :produtos do |t|

     t.string :nome
     t.string :codigo_sistema_legado 
     t.integer :tipo_produto_id
     t.string :unidade_medida
     t.text :descricao
     t.boolean :active
     t.integer :categoria_id
     t.integer :unidade_id
     t.text :outros_campos
     t.timestamps
    end
  end
end
