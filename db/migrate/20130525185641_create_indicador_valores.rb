class CreateIndicadorValores < ActiveRecord::Migration
  def change
    create_table :indicador_valores do |t|
      t.integer :tipo
      t.string :legenda
      t.integer :operador
      t.float :valor_minimo
      t.float :valor_maximo
      t.integer :frequencia_mimima
      t.integer :frequencia_maxima
      t.text :descricao
      t.integer :conjunto_indicador_id

      t.timestamps
    end
  end
end
