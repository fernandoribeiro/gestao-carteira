class CreateLogAcessos < ActiveRecord::Migration
  def change
    create_table :log_acessos do |t|
      t.references :usuario_entidade
      t.references :entidade

      t.timestamps
    end
    add_index :log_acessos, :usuario_entidade_id
    add_index :log_acessos, :entidade_id
  end
end
