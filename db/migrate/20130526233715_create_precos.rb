class CreatePrecos < ActiveRecord::Migration
  def change
    create_table :precos do |t|
      t.decimal :valor_base
      t.decimal :porcentagem_desconto
      t.decimal :valor_desconto
      t.integer :produto_id
      t.boolean :active
      t.timestamps
    end
  end
end
