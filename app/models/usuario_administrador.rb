#encoding: UTF-8

class UsuarioAdministrador < ActiveRecord::Base

  # ACTIVE
  ATIVO = true
  INATIVO = false

  attr_accessible :nome
  attr_accessible :username
  attr_accessible :email
  attr_accessible :password
  attr_accessible :password_confirmation
  attr_accessible :active
  attr_accessible :autentication_token

  has_secure_password

  before_create :create_autentication_token

  validates :nome, presence: true, length: { maximum: 255 }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, length: { maximum: 255 }
  validates :password, presence: { on: :create }, length: { allow_blank: true, minimum: 6 }
  validates :active, presence: true, inclusion: { in: [ATIVO, INATIVO] }

  scope :active, where(active: true)


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

  def active_verbose
    active ? 'Ativo' : 'Inativo'
  end

  def active?
    active
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

  def self.pesquisa_usuarios(pesquisa)
    if pesquisa[:text].blank?
      UsuarioAdministrador.order(:nome, :username)
    else
      UsuarioAdministrador.order(:nome, :username).where('nome ILIKE ? OR username ILIKE ? OR email ILIKE ?', pesquisa[:text].like, pesquisa[:text].like, pesquisa[:text].like)
    end
  end

end
