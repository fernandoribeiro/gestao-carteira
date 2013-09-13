# encoding: UTF-8

class Vendedor < ActiveRecord::Base

  attr_accessible :nome
  attr_accessible :codigo_sistema_legado
  attr_accessible :unidade_id
  attr_accessible :active

  belongs_to :unidade

  validates :unidade, presence: true
  validates :codigo_sistema_legado, presence: true,
                                    uniqueness: { case_sensitive: false, scope: [:unidade_id] },
                                    length: { maximum: 255 }
  validates :nome, presence: true,
                   uniqueness: { case_sensitive: false, scope: [:unidade_id] },
                   length: { maximum: 255 }


  def active_verbose
    case active
    when true; 'Ativo'
    when false; 'Inativo'
    end
  end

  def self.pesquisa(entidade, params)
    if params[:texto].blank?
      Vendedor.joins(:unidade)
             .where('unidades.entidade_id = ?', entidade.id)
             .order('vendedores.nome')
    else
      Vendedor.joins(:unidade)
             .where("unidades.entidade_id = ? AND
                    (vendedores.nome ILIKE ? OR vendedores.codigo_sistema_legado ILIKE ?)",
                    entidade.id, params[:texto].like, params[:texto].like)
             .order('vendedores.nome')
    end
  end

end
