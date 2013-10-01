#encoding: UTF-8

class Entidade < ActiveRecord::Base

  # SITUACAO
  ATIVO = true
  INATIVO = false

  attr_accessible :active
  attr_accessible :nome
  attr_accessible :numero_limite_usuarios
  attr_accessible :situacao
  attr_accessible :slug
  attr_accessible :usuario_entidades_attributes

  has_many :conjunto_indicadores
  has_many :unidades
  has_many :usuario_entidades
  has_many :importacoes
  accepts_nested_attributes_for :usuario_entidades, limit: 1
  alias_method :usuarios, :usuario_entidades

  validates :nome, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }, format: { with: /\A[a-z0-9]+\z/ }
  validates :numero_limite_usuarios, presence: true, numericality: { only_integer: true }, numericality: { greater_than: 0 }
  validates :active, presence: true, inclusion: { in: [ATIVO, INATIVO] }

  scope :active, where(active: true)


  def initialize(attributes = {})
    attributes["active"] ||= ATIVO
    super
  end

  def self.pesquisa_entidades(pesquisa)
    if pesquisa[:text].blank?
      Entidade.order(:nome, :slug)
    else
      Entidade.order(:nome, :slug).where('nome ILIKE ? OR slug ILIKE ?', pesquisa[:text].like, pesquisa[:text].like)
    end
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

end
