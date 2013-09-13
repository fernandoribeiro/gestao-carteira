class AdicionaCampoImportacaoComDependetes < ActiveRecord::Migration
  def up
  	add_column :item_importacoes,:dependentes,:boolean
  end

  def down
  	remove_column :item_importacoes,:dependentes
  end
end
