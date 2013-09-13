class AdicionaCampoRetornoEmImportacaoJob < ActiveRecord::Migration
  def up
  	add_column :item_importacao_jobs,:retorno,:string
  end

  def down
  	remove_column :item_importacao_jobs,:retorno
  end
end
