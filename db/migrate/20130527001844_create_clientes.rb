class CreateClientes < ActiveRecord::Migration
  def change
    create_table :clientes do |t|
    t.string :tipo_pessoa
    t.string :nome
    t.string :razao_social
    t.string :nome_fantasia
    t.string :codigo_sistema_legado
    t.integer :cidade_id
    t.string :estado
    t.string :email
    t.string :cidade_nome
    t.string :telefone
    t.text :outros_campos
    t.integer :unidade_id
    t.integer :setor_id
    t.boolean :active
      t.timestamps
    end
  end
end
