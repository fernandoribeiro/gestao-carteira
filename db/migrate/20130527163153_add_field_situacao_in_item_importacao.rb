class AddFieldSituacaoInItemImportacao < ActiveRecord::Migration
  def up
  	add_column :item_importacoes,:situacao,:integer
  end

  def down
  	remove_column :item_importacoes,:situacao
  end
end
