class CorrigeNomeAtributosTemps < ActiveRecord::Migration

  def up
    rename_column :nota_fiscal_temps, :cod_unidade, :unidade_id
    rename_column :nota_fiscal_temps, :cod_vendedor, :vendedor_id
    rename_column :nota_fiscal_temps, :code_cliente, :cliente_id
    rename_column :nota_fiscal_temps, :cod_produto, :produto_id
  end

  def down
    rename_column :nota_fiscal_temps, :unidade_id, :cod_unidade
    rename_column :nota_fiscal_temps, :vendedor_id, :cod_vendedor
    rename_column :nota_fiscal_temps, :cliente_id, :code_cliente
    rename_column :nota_fiscal_temps, :produto_id, :cod_produto
  end

end
