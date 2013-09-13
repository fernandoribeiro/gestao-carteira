class CreateClienteTemps < ActiveRecord::Migration

  def change
    create_table :cliente_temps do |t|
      t.string  :nome_razao_social
      t.string  :tipo_pessoa, length: 20
      t.string  :codigo_sistema_legado, length: 100
      t.string  :cidade_nome, length: 20
      t.string  :estado, length: 30
      t.string  :email, length: 100
      t.string  :telefone, length: 20
      t.text    :outros_campos
      t.integer :unidade_id
      t.boolean :sent_to_master

      t.timestamps
    end
  end

end
