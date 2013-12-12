#encoding: UTF-8

class UsuarioEntidade < ActiveRecord::Base

  # ACTIVE
  ATIVO = true
  INATIVO = false
  # EH_ADMINISTRADOR
  SIM = true
  NAO = false

  attr_accessible :nome
  attr_accessible :username
  attr_accessible :email
  attr_accessible :password
  attr_accessible :password_confirmation
  attr_accessible :active
  attr_accessible :autentication_token
  attr_accessible :eh_administrador
  attr_accessible :entidade_id
  attr_accessible :unidade_ids

  has_secure_password

  belongs_to :entidade

  has_many :usuario_entidade_unidades, dependent: :destroy
  has_many :unidades, through: :usuario_entidade_unidades, uniq: true

  before_create :create_autentication_token
  before_create :activate

  validates :nome, presence: true, length: { maximum: 255 }
  validates :username, presence: true, uniqueness: { case_sensitive: false, scope: [:entidade_id] }, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: [:entidade_id]}, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, length: { maximum: 255 }
  validates :password, presence: { on: :create }, length: { allow_blank: true, minimum: 6 }
  validates :unidade_ids, presence: true, unless: :isAdministrador?

  scope :active, where(active: true)
  scope :by_entidade_id, lambda { |entidade_id| where(entidade_id: entidade_id)}


  def activate
    write_attribute :active, ATIVO unless read_attribute :active
  end

  def self.authenticate(value, password)
    user = find_by_username_or_email(value)
    user ||= new

    if user.new_record?
      user.errors.add :username, :invalid
    elsif !user.authenticate password
      user.errors.add :password, :invalid
    elsif !user.active?
      user.errors.add :username, :invalid
    end
    user
  end

  def self.find_by_username_or_email(value)
    where('email = ? OR username = ?', value, value).first
  end

  def eh_administrador_verbose
    eh_administrador ? 'Sim' : 'Não'
  end

  def active_verbose
    active ? 'Ativo' : 'Inativo'
  end

  def active?
    active
  end

  def isAdministrador?
    eh_administrador
  end

  def notIsAdministrador?
    !eh_administrador
  end

  def toggle_active
    update_attribute :active, (active ? INATIVO : ATIVO)
  end

  def create_autentication_token
    write_attribute :autentication_token, generate_token(:autentication_token)
  end
  alias_method :update_autentication_token, :create_autentication_token

  def generate_token(attribute_name)
    begin
      token = SecureRandom.hex
    end while self.class.exists?(attribute_name => token)
    token
  end

  def self.pesquisa(entidade_id, pesquisa)
    if pesquisa[:texto].blank?
      UsuarioEntidade.by_entidade_id(entidade_id)
                     .order(:nome, :username)
    else
      UsuarioEntidade.by_entidade_id(entidade_id)
                     .order(:nome, :username)
                     .where('nome ILIKE ? OR username ILIKE ? OR email ILIKE ?',
                            pesquisa[:texto].like, pesquisa[:texto].like, pesquisa[:texto].like)
    end
  end

end
