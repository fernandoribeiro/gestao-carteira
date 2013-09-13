class ChangeColunaQuantidadeTempNota < ActiveRecord::Migration

  def up
    change_column :nota_fiscal_temps, :quantidade, :decimal, precision: 18, scale: 2
  end

  def down
    change_column :nota_fiscal_temps, :quantidade, :integer
  end

end
