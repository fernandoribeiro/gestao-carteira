class CreateItemImportacaoJobs < ActiveRecord::Migration
  def change
    create_table :item_importacao_jobs do |t|
      t.integer :item_importacao_id
      t.integer :status
      t.string :arquivo
      t.integer :unidade_id
      t.timestamps
    end
  end
end
