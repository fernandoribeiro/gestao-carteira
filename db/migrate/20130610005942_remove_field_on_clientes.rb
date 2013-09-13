class RemoveFieldOnClientes < ActiveRecord::Migration
  def up
  	remove_column :clientes,:nome
  	remove_column :clientes,:razao_social
  	remove_column :clientes,:nome_fantasia
  	remove_column :clientes,:setor_id
  	add_column :clientes,:nome_razao_social,:string
  end

  def down
  	add_column :clientes,:nome,:string
  	add_column :clientes,:razao_social,:string
  	add_column :clientes,:nome_fantasia,:string
  	add_column :clientes,:setor_id,:string
  	remove_column :clientes,:nome_razao_social
  end
end
