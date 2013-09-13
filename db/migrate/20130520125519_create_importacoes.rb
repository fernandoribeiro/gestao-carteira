class CreateImportacoes < ActiveRecord::Migration
  def change
    create_table :importacoes do |t|
      t.string :nome
      t.integer :unidade_id
      t.integer :tipo_arquivo
      t.integer :situacao
      t.string :arquivo
      t.timestamps
    end
  end
end
