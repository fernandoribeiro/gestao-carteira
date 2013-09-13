class CreateMetas < ActiveRecord::Migration
  def change
    create_table :metas do |t|
      t.date :data_inicio
      t.date :data_final
      t.integer :dias_uteis
      t.decimal :valor_de_faturamento
      t.integer :unidade_id

      t.timestamps
    end
  end
end
