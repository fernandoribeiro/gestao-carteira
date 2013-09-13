class CreateRelatorioFaturamentos < ActiveRecord::Migration
  def change
    create_table :relatorio_faturamentos do |t|

      t.timestamps
    end
  end
end
