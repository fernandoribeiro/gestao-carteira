class CreateUnidades < ActiveRecord::Migration
  def change
    create_table :unidades do |t|
      t.string :nome
      t.string :slug
      t.boolean :active
      t.integer :entidade_id
      t.integer :situacao

      t.timestamps
    end
  end
end
