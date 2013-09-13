class ChangeUnidadeTypeNfTemp < ActiveRecord::Migration

  def up
    remove_column :nota_fiscal_temps, :unidade_id
    add_column :nota_fiscal_temps, :unidade_id, :integer
  end

  def down
    remove_column :nota_fiscal_temps, :unidade_id
    add_column :nota_fiscal_temps, :unidade_id, :string
  end

end
