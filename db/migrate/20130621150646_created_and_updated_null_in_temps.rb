class CreatedAndUpdatedNullInTemps < ActiveRecord::Migration

  def up
    change_column :cliente_temps, :created_at, :datetime, null: true
    change_column :cliente_temps, :updated_at, :datetime, null: true

    change_column :produto_temps, :created_at, :datetime, null: true
    change_column :produto_temps, :updated_at, :datetime, null: true

    change_column :vendedor_temps, :created_at, :datetime, null: true
    change_column :vendedor_temps, :updated_at, :datetime, null: true

    change_column :nota_fiscal_temps, :created_at, :datetime, null: true
    change_column :nota_fiscal_temps, :updated_at, :datetime, null: true
  end

  def down
    change_column :cliente_temps, :created_at, :datetime, null: false
    change_column :cliente_temps, :updated_at, :datetime, null: false

    change_column :produto_temps, :created_at, :datetime, null: false
    change_column :produto_temps, :updated_at, :datetime, null: false

    change_column :vendedor_temps, :created_at, :datetime, null: false
    change_column :vendedor_temps, :updated_at, :datetime, null: false

    change_column :nota_fiscal_temps, :created_at, :datetime, null: false
    change_column :nota_fiscal_temps, :updated_at, :datetime, null: false
  end

end
