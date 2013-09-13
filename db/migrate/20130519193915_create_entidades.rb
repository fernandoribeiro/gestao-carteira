class CreateEntidades < ActiveRecord::Migration
  def change
    create_table :entidades do |t|
      t.string :nome
      t.string :slug
      t.integer :numero_limite_usuarios
      t.boolean :active
      t.integer :situacao

      t.timestamps
    end
  end
end
