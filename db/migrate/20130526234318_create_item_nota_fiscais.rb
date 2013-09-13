class CreateItemNotaFiscais < ActiveRecord::Migration
  def change
    create_table :item_nota_fiscais do |t|
    t.integer :nota_fiscal_id
    t.integer :produto_id
    t.integer :quantidade
    t.decimal :valor
    t.decimal :valor_desconto
    t.decimal :valor_porcentagem_desconto
    t.decimal :valor_total
    t.text :outros_campos
    t.text :descricao
      t.timestamps
    end
  end
end
