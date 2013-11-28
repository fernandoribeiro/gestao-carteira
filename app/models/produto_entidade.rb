# encoding: UTF-8

class ProdutoEntidade < ActiveRecord::Base

  attr_accessible :codigo
  attr_accessible :descricao
  attr_accessible :marca
  attr_accessible :ean
  attr_accessible :peso
  attr_accessible :entidade_id

  belongs_to :entidade

  validates :codigo, presence: true,
										 uniqueness: { case_sensitive: false, scope: [:entidade_id] },
                     length: { maximum: 255 }
	validates :entidade, presence: true


end
