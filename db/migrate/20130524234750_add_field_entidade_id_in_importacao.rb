class AddFieldEntidadeIdInImportacao < ActiveRecord::Migration
  def up
  	add_column :importacoes,:entidade_id,:integer
  end

  def down
  	remove_column :importacoes,:entidade_id
  end
end
