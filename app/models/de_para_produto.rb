#encoding: UTF-8

class DeParaProduto < ActiveRecord::Base
  
  attr_accessible :produto_id
  attr_accessible :produto_entidade_id
  attr_accessible :unidade_id

  belongs_to :produto
  belongs_to :produto_entidade
  belongs_to :unidade

  validates :produto_id, uniqueness: { scope: [:produto_entidade_id, :unidade_id] }
  
end
