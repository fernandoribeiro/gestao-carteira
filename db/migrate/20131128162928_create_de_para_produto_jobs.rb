class CreateDeParaProdutoJobs < ActiveRecord::Migration
  def change
    create_table :de_para_produto_jobs do |t|
      t.string :nome
      t.string :arquivo
      t.integer :status
      t.text :resultado
      t.references :unidade

      t.timestamps
    end
    add_index :de_para_produto_jobs, :unidade_id
  end
end
