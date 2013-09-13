#encoding: UTF-8

class UsuarioEntidadeUnidade < ActiveRecord::Base

  # attr_accessible :unidade_id
  # attr_accessible :usuario_entidade_id

  belongs_to :usuario_entidade
  belongs_to :unidade

  # before_validation :teste

  # def teste
  #   p '==============='
  #   p self
  # end

end
