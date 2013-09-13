class AddRemoveFieldEmProdutos < ActiveRecord::Migration
  def up
  	remove_column :produtos,:tipo_produto_id
  	remove_column :produtos,:unidade_medida
  	remove_column :produtos,:descricao
  end

  def down
  	add_column :produtos,:tipo_produto_id,:integer
  	add_column :produtos,:unidade_medida,:string
  	add_column :produtos,:descricao,:text
  end
end
