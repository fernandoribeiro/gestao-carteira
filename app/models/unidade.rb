#encoding: UTF-8

class Unidade < ActiveRecord::Base

  # SITUACAO
  ATIVO = true
  INATIVO = false

  attr_accessible :active
  attr_accessible :entidade_id
  attr_accessible :nome
  attr_accessible :situacao
  attr_accessible :slug

  belongs_to :entidade

  has_many :usuario_entidade_unidades
  has_many :importacoes
  has_many :usuarios, through: :usuario_entidade_unidades
  has_many :vendedores
  has_many :metas
  has_many :agendamentos

  validates :nome, presence: true, uniqueness: { case_sensitive: false, scope: [:entidade_id] }, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false, scope: [:entidade_id] }, length: { maximum: 50 }, format: { with: /\A[a-z0-9]+\z/ }
  validates :entidade, presence: true
  # validates :situacao, presence: true
  validates :active, presence: true, inclusion: { in: [ATIVO, INATIVO] }

  scope :active, where(active: true)
  scope :by_entidade_id, lambda { |entidade_id| where(entidade_id: entidade_id)}


  def initialize(attributes = {})
    super
    set_active
  end

  def set_active
    write_attribute :active, ATIVO unless read_attribute :active
  end

  def toggle_active
    update_attribute(:active, (active ? INATIVO : ATIVO))
  end

  def active_verbose
    case self.active
    when ATIVO; 'Ativo'
    when INATIVO; 'Inativo'
    end
  end

  def self.return_for_select(entidade)
    Unidade.where('active = ? AND entidade_id = ?', true, entidade.id)
           .order(:nome)
           .collect{ |obj_unidade| [obj_unidade.nome, obj_unidade.id] }
  end

  def self.pesquisa(entidade_id, pesquisa)
    if pesquisa[:texto].blank?
      Unidade.by_entidade_id(entidade_id)
             .order(:nome, :slug)
    else
      Unidade.by_entidade_id(entidade_id)
             .where('nome ILIKE ? OR slug ILIKE ?', pesquisa[:texto].like, pesquisa[:texto].like)
             .order(:nome, :slug)
    end
  end

end
