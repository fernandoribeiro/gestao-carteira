class CreateItemImportacoes < ActiveRecord::Migration
  def change
    create_table :item_importacoes do |t|
      t.integer :importacao_id
      t.integer :aba_trabalho_index
      t.string :aba_trabalho_nome
      t.text :de_para
      t.integer :ordem
      t.integer :tabela_sistema_destino
      t.integer :linha_inicio
      t.integer :linha_fim
      t.timestamps
    end
  end
end
