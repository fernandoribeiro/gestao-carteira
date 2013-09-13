class CorrigeTipoCampoQuantidade < ActiveRecord::Migration

  def up
    change_column :nota_fiscais, :quantidade, :decimal, precision: 18, scale: 2
  end

  def down
    change_column :nota_fiscais, :quantidade, :decimal
  end

end
