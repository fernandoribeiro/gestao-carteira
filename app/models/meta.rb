#encoding: UTF-8

class Meta < ActiveRecord::Base
  
  attr_accessible :unidade_id
  attr_accessible :data_final
  attr_accessible :data_inicio
  attr_accessible :dias_uteis
  attr_accessible :valor_de_faturamento
  
  belongs_to :unidade
  
  validates :unidade, :presence=>true
  validates :data_final, :presence=>true
  validates :data_inicio, :presence=>true
  validates :dias_uteis, :presence=>true,:numericality => {:greater_than => 0}
  validates :valor_de_faturamento, :presence=>true,:numericality => {:greater_than => 0}
  validate :datas_validas?
  
  
  def datas_validas?
    if !data_inicio.blank? && !data_final.blank?
      data_inicial = data_inicio.to_date
      data_fim = data_final.to_date
      if data_inicial.to_date > data_fim.to_date
        errors.add :data_inicio, "A data inicial não pode ser maior do que a data final"
      end
    end
  end
  
  
  
end
