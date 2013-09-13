# encoding: UTF-8

class Produto < ActiveRecord::Base

  attr_accessible :nome
  attr_accessible :codigo_sistema_legado
  attr_accessible :active
  attr_accessible :categoria_id
  attr_accessible :unidade_id
  attr_accessible :outros_campos

  belongs_to :unidade

  validates :unidade, presence: true
  validates :codigo_sistema_legado, presence: true,
                                    uniqueness: { case_sensitive: false, scope: [:unidade_id] },
                                    length: { maximum: 255 }
  validates :nome, presence: true,
                   length: { maximum: 255 }
                   # uniqueness: { case_sensitive: false, scope: [:unidade_id] }


  def active_verbose
    case active
    when true; 'Ativo'
    when false; 'Inativo'
    end
  end

  def self.pesquisa(entidade, params)
    if params[:texto].blank?
      Produto.joins(:unidade)
             .where('unidades.entidade_id = ?', entidade.id)
             .order('produtos.nome')
    else
      Produto.joins(:unidade)
             .where("unidades.entidade_id = ? AND
                    (produtos.nome ILIKE ? OR produtos.codigo_sistema_legado ILIKE ?)",
                    entidade.id, params[:texto].like, params[:texto].like)
             .order('produtos.nome')
    end
  end

end
