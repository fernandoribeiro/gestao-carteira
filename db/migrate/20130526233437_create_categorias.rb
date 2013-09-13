class CreateCategorias < ActiveRecord::Migration
  def change
    create_table :categorias do |t|
      t.string :nome
      t.boolean :active
      t.integer :categoria_id
      t.integer :unidade_id
      t.string :codigo_sistema_legado
      t.timestamps
    end
  end
end
