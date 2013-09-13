class CreateNotaFiscalTemps < ActiveRecord::Migration

  def change
    create_table :nota_fiscal_temps do |t|
      t.string  :numero_documento
      t.string  :codigo_sistema_legado, length: 100
      t.date    :data_emissao
      t.string  :cod_unidade, length: 100
      t.string  :cod_vendedor, length: 100
      t.string  :code_cliente, length: 100
      t.string  :cod_produto, length: 100
      t.integer :quantidade
      t.decimal :valor, precision: 18, scale: 2
      t.decimal :valor_desconto, precision: 18, scale: 2
      t.decimal :valor_porcentagem_desconto, precision: 18, scale: 2
      t.text    :descricao
      t.text    :outros_campos
      t.boolean :sent_to_master

      t.timestamps
    end
  end

end
