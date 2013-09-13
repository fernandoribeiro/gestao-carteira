class AddRemoveFieldInNotaFiscal < ActiveRecord::Migration
  def up
  	add_column :nota_fiscais,:produto_id,:integer
  	add_column :nota_fiscais,:quantidade,:integer
  	add_column :nota_fiscais,:valor,:decimal
  	add_column :nota_fiscais,:valor_desconto,:decimal
  	add_column :nota_fiscais,:valor_porcentagem_desconto,:decimal
  	drop_table :item_nota_fiscais
  end

  def down
  	remove_column :nota_fiscais,:produto_id
  	remove_column :nota_fiscais,:quantidade
  	remove_column :nota_fiscais,:valor
  	remove_column :nota_fiscais,:valor_desconto
  	remove_column :nota_fiscais,:valor_porcentagem_desconto
  end
end
