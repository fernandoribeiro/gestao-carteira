class CreateDeParaProdutos < ActiveRecord::Migration
  def change
    create_table :de_para_produtos do |t|
      t.references :produto
      t.references :produto_entidade
      t.references :unidade

      t.timestamps
    end
    add_index :de_para_produtos, :produto_id
    add_index :de_para_produtos, :produto_entidade_id
    add_index :de_para_produtos, :unidade_id
  end
end
