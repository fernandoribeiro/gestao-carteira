class AddIndexInTables < ActiveRecord::Migration

  def change
    add_index :clientes, :unidade_id
    add_index :clientes, :cidade_id
    add_index :conjunto_indicador_unidades, :unidade_id
    add_index :conjunto_indicadores, :entidade_id
    add_index :importacoes, :entidade_id
    add_index :importacoes, :unidade_id
    add_index :item_importacao_jobs, :item_importacao_id
    add_index :item_importacao_jobs, :unidade_id
    add_index :item_importacoes, :importacao_id
    add_index :nota_fiscais, :cliente_id
    add_index :nota_fiscais, :vendedor_id
    add_index :nota_fiscais, :unidade_id
    add_index :nota_fiscais, :produto_id
    add_index :unidades, :entidade_id
    add_index :usuario_entidade_unidades, :usuario_entidade_id
    add_index :usuario_entidade_unidades, :unidade_id
    add_index :usuario_entidades, :entidade_id
  end

end
