class RemoveInutilidades < ActiveRecord::Migration

  def up
    drop_table :categorias
    drop_table :precos
    drop_table :setores
    remove_column :produtos, :categoria_id
    change_column :nota_fiscais, :produto_id, :integer
    change_column :nota_fiscais, :quantidade, :integer
    change_column :nota_fiscais, :valor, :decimal, precision: 18, scale: 2
    change_column :nota_fiscais, :valor_desconto, :decimal, precision: 18, scale: 2
    change_column :nota_fiscais, :valor_porcentagem_desconto, :decimal, precision: 18, scale: 2
  end

  def down
  end

end
