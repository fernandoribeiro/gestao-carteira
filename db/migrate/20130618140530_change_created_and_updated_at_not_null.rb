class ChangeCreatedAndUpdatedAtNotNull < ActiveRecord::Migration

  def up
    change_column :clientes, :created_at, :datetime, null: true
    change_column :clientes, :updated_at, :datetime, null: true

    change_column :produtos, :created_at, :datetime, null: true
    change_column :produtos, :updated_at, :datetime, null: true

    change_column :vendedores, :created_at, :datetime, null: true
    change_column :vendedores, :updated_at, :datetime, null: true

    change_column :nota_fiscais, :created_at, :datetime, null: true
    change_column :nota_fiscais, :updated_at, :datetime, null: true
  end

  def down
    change_column :clientes, :created_at, :datetime, null: false
    change_column :clientes, :updated_at, :datetime, null: false

    change_column :produtos, :created_at, :datetime, null: false
    change_column :produtos, :updated_at, :datetime, null: false

    change_column :vendedores, :created_at, :datetime, null: false
    change_column :vendedores, :updated_at, :datetime, null: false

    change_column :nota_fiscais, :created_at, :datetime, null: false
    change_column :nota_fiscais, :updated_at, :datetime, null: false
  end

end
