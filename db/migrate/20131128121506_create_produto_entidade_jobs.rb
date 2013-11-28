class CreateProdutoEntidadeJobs < ActiveRecord::Migration
  def change
    create_table :produto_entidade_jobs do |t|
      t.references :entidade
      t.string :nome
      t.integer :status
      t.text :resultado
      t.text :arquivo

      t.timestamps
    end
    add_index :produto_entidade_jobs, :entidade_id
  end
end
