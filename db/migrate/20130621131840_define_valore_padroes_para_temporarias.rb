class DefineValorePadroesParaTemporarias < ActiveRecord::Migration

  def up
    change_column :cliente_temps, :sent_to_master, :boolean, default: false
    change_column :produto_temps, :sent_to_master, :boolean, default: false
    change_column :vendedor_temps, :sent_to_master, :boolean, default: false
    change_column :nota_fiscal_temps, :sent_to_master, :boolean, default: false
  end

  def down
    change_column :cliente_temps, :sent_to_master, :boolean
    change_column :produto_temps, :sent_to_master, :boolean
    change_column :vendedor_temps, :sent_to_master, :boolean
    change_column :nota_fiscal_temps, :sent_to_master, :boolean
  end

end
