class RetiraObrigatoriedadeDoCampo < ActiveRecord::Migration
  def up
    change_column :relatorio_frequencia_valores, :created_at, :datetime, null: true
    change_column :relatorio_frequencia_valores, :updated_at, :datetime, null: true
  end

  def down
    change_column :relatorio_frequencia_valores, :created_at, :datetime, null: false
    change_column :relatorio_frequencia_valores, :updated_at, :datetime, null: false
  end
end
