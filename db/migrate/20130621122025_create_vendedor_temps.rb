class CreateVendedorTemps < ActiveRecord::Migration

  def change
    create_table :vendedor_temps do |t|
      t.string  :nome
      t.string  :codigo_sistema_legado, length: 100
      t.integer :unidade_id
      t.boolean :sent_to_master

      t.timestamps
    end
  end

end
