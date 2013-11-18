class CreateProdutoEntidades < ActiveRecord::Migration
  def change
    create_table :produto_entidades do |t|
      t.string :marca
      t.text :descricao
      t.string :codigo
      t.string :ean
      t.decimal :peso
      t.references :entidade

      t.timestamps
    end
    add_index :produto_entidades, :entidade_id
  end
end
