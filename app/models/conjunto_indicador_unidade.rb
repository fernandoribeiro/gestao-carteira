class ConjuntoIndicadorUnidade < ActiveRecord::Base

  attr_accessible :conjunto_indicador_id
  attr_accessible :unidade_id

  belongs_to :unidade
  belongs_to :conjunto_indicador

end
