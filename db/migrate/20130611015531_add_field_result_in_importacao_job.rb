class AddFieldResultInImportacaoJob < ActiveRecord::Migration
  def up
  	add_column :item_importacao_jobs,:resultado,:text
  end

  def down
  	remove_column :item_importacao_jobs,:resultado
  end
end
