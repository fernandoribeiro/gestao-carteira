class CreateVendedores < ActiveRecord::Migration
  def change
    create_table :vendedores do |t|
      t.string :codigo_sistema_legado
      t.string :nome
      t.integer :unidade_id
      t.boolean :active
      t.timestamps
    end
  end
end
