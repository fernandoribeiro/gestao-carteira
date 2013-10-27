class CreateAgendamentos < ActiveRecord::Migration
  def change
    create_table :agendamentos do |t|
      t.string :nome
      t.string :arquivo
      t.integer :unidade_id
      t.integer :entidade_id
      t.integer :status
      t.timestamps
    end
  end
end
