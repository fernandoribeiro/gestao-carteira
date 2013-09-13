class CreateSetores < ActiveRecord::Migration
  def change
    create_table :setores do |t|
      t.string :nome
      t.string :codigo_sistema_legado
      t.integer :unidade_id
      t.timestamps
    end
  end
end
