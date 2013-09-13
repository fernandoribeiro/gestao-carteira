class CreateConjuntoIndicadores < ActiveRecord::Migration
  def change
    create_table :conjunto_indicadores do |t|
      t.integer :entidade_id
      t.integer :numero_minimo_periodos
      t.boolean :default
      t.boolean :active
      t.integer :tipo_periodo
      t.string :nome
      t.integer :abrangencia

      t.timestamps
    end
  end
end
