class AddCampoCpfCnpjEmCliente < ActiveRecord::Migration
  
  def up
  	add_column :clientes, :cpf_cnpj, :string
  	add_column :cliente_temps, :cpf_cnpj, :string
  end

  def down
  	remove_column :clientes, :cpf_cnpj
  	remove_column :clientes, :cpf_cnpj
  end

end
