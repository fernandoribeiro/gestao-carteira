class CreateConjuntoIndicadorUnidades < ActiveRecord::Migration
  def change
    create_table :conjunto_indicador_unidades do |t|
      t.integer :unidade_id
      t.integer :conjunto_indicador_id

      t.timestamps
    end
  end
end
