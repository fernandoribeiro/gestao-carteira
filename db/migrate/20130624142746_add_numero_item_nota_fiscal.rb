class AddNumeroItemNotaFiscal < ActiveRecord::Migration

  def up
    add_column :nota_fiscais, :numero_item, :integer
    add_column :nota_fiscal_temps, :numero_item, :integer
  end

  def down
    remove_column :nota_fiscais, :numero_item
    remove_column :nota_fiscal_temps, :numero_item
  end

end
