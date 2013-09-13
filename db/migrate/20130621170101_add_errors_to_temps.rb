class AddErrorsToTemps < ActiveRecord::Migration

  def up
    add_column :cliente_temps, :error_messages, :text
    add_column :produto_temps, :error_messages, :text
    add_column :vendedor_temps, :error_messages, :text
    add_column :nota_fiscal_temps, :error_messages, :text
  end

  def down
    remove_column :cliente_temps, :error_messages
    remove_column :produto_temps, :error_messages
    remove_column :vendedor_temps, :error_messages
    remove_column :nota_fiscal_temps, :error_messages
  end

end
