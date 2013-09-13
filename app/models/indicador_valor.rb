# encoding: utf-8

class IndicadorValor < ActiveRecord::Base

  attr_accessible :conjunto_indicador_id
  attr_accessible :descricao
  attr_accessible :frequencia_maxima
  attr_accessible :frequencia_mimima
  attr_accessible :legenda
  attr_accessible :operador
  attr_accessible :tipo
  attr_accessible :valor_maximo
  attr_accessible :valor_maximo_verbose
  attr_accessible :valor_minimo
  attr_accessible :valor_minimo_verbose

  belongs_to :conjunto_indicador

  FREQUENCIA = 1
  VALOR = 2

  MAIOR = 1
  MAIOR_OU_IGUAL = 2
  NAO_COMPREI_NO_PERIODO = 3
  IGUAL = 4
  ENTRE = 5

  OPERADOR_VERBOSE = {
    MAIOR => 'Maior',
    MAIOR_OU_IGUAL => "Maior ou Igual",
    NAO_COMPREI_NO_PERIODO => "Não comprei no Periodo",
    IGUAL => "Igual",
    ENTRE => "Entre"
  }

  OPERADOR_FREQUENCIA = [NAO_COMPREI_NO_PERIODO, IGUAL, ENTRE]
  OPERADOR_VALOR = [MAIOR, MAIOR_OU_IGUAL, IGUAL, ENTRE]

  validates :tipo, presence: true
  validates :tipo, inclusion: { in: [FREQUENCIA, VALOR] }
  validates :legenda, presence: true
  validates :legenda, length: { maximum: 255 }
  validates :legenda, uniqueness: { case_sensitive: false, :scope => [:conjunto_indicador_id, :tipo] }
  validates :operador, presence: true
  validates :operador, inclusion: { in: [NAO_COMPREI_NO_PERIODO, IGUAL, ENTRE] }, if: :frequencia?
  validates :operador, inclusion: { in: [MAIOR, MAIOR_OU_IGUAL, IGUAL, ENTRE] }, if: :valor?
  validates :operador, :uniqueness => {:scope => [:conjunto_indicador_id]}, if: :frequencia_and_nao_comprou_no_periodo?
  validates :valor_minimo, presence: true, if: :valor?
  validates :valor_minimo, numericality: { greater_than: 0 }, if: :valor?
  validates :valor_maximo, presence: true, if: :valor_and_entre?
  validates :valor_maximo, numericality: { greater_than: 0 }, if: :valor_and_entre?
  validates :valor_maximo, interval: { allow_equals: false, start_at: :valor_minimo }, if: :valor_and_entre?
  validates :frequencia_mimima, presence: true, if: :frequencia_and_not_nao_comprou_no_periodo?
  validates :frequencia_mimima, numericality: { greater_than: 0, only_integer: true}, if: :frequencia_and_not_nao_comprou_no_periodo?
  validates :frequencia_maxima, presence: true, if: :frequencia_and_entre?
  validates :frequencia_maxima, numericality: {greater_than: 0, only_integer: true}, if: :frequencia_and_entre?
  validates :frequencia_maxima, interval: { allow_equals: false, start_at: :frequencia_mimima }, if: :frequencia_and_entre?
  validates :descricao, presence: true

  scope :frequencia, where(tipo: FREQUENCIA)
  scope :valor, where(tipo: VALOR)


  def frequencia?
    tipo == FREQUENCIA
  end

  def self.init_frequencia
    IndicadorValor.new tipo: FREQUENCIA
  end

  def self.init_valor
    IndicadorValor.new tipo: VALOR
  end

  def valor?
    tipo == VALOR
  end

  def valor_and_entre?
    valor? && operador == ENTRE
  end

  def frequencia_and_not_nao_comprou_no_periodo?
    frequencia? && operador != NAO_COMPREI_NO_PERIODO
  end

  def frequencia_and_nao_comprou_no_periodo?
    frequencia? && operador == NAO_COMPREI_NO_PERIODO
  end

  def frequencia_and_entre?
    frequencia? && operador == ENTRE
  end

  def operador_verbose
    OPERADOR_VERBOSE[operador]
  end

  def valor_entre valor
    if valor.blank?
      false
    else
      valor_minimo <= valor && valor_maximo >= valor
    end
  end

  def frequencia_verbose
    if frequencia_maxima.blank?
      frequencia_mimima
    else
      "#{frequencia_mimima} a #{frequencia_maxima}"
    end
  end

  def valor_verbose
    if valor_maximo.blank? || valor_maximo == 0
      "#{valor_minimo_verbose}"
    else
      "#{valor_minimo_verbose} ao #{valor_maximo_verbose}"
    end
  end

  def valor_minimo_verbose
    "#{"%.2f" % valor_minimo}" rescue ""
  end

  def valor_maximo_verbose
    "#{"%.2f" % valor_maximo}" rescue ""
  end

  def valor_minimo_verbose= value
    valor_minimo = value.to_f
  end

  def valor_maximo_verbose= value
    valor_maximo = value.to_f
  end

  def frequencia_entre frequencia
    if frequencia.blank?
      false
    else
      frequencia_mimima <= frequencia && frequencia_maxima >= frequencia
    end
  end
end
