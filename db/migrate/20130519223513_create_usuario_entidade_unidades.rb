class CreateUsuarioEntidadeUnidades < ActiveRecord::Migration
  def change
    create_table :usuario_entidade_unidades do |t|
      t.integer :usuario_entidade_id
      t.integer :unidade_id

      t.timestamps
    end
  end
end
