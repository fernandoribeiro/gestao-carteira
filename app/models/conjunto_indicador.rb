# encoding: utf-8

class ConjuntoIndicador < ActiveRecord::Base

  ATIVO   = true
  INATIVO = false

  DIARIA  = 1
  SEMANAL = 2
  MENSAL  = 3
  ANUAL   = 4

  TIPO_PERIODO_VERBOSE = {
    DIARIA  => 'Diaria',
    SEMANAL => 'Semanal',
    MENSAL  => 'Mensal',
    ANUAL   => 'Anual'
  }

  UNIDADE  = 1
  ENTIDADE = 2
  AMBOS    = 3

  ABRANGENCIA_VERBOSE = {
    UNIDADE  => 'Unidade',
    ENTIDADE => 'Entidade',
    AMBOS    => 'Ambos'
  }

  attr_accessible :id
  attr_accessible :abrangencia
  attr_accessible :active
  attr_accessible :default
  attr_accessible :entidade_id
  attr_accessible :nome
  attr_accessible :numero_minimo_periodos
  attr_accessible :tipo_periodo
  attr_accessor   :abrangencia_entidade
  attr_accessible :abrangencia_entidade
  attr_accessor   :abrangencia_unidade
  attr_accessible :abrangencia_unidade
  attr_accessible :unidade_ids
  attr_accessible :indicador_valores_attributes


  belongs_to :entidade
  has_many :conjunto_indicador_unidades, dependent: :destroy
  has_many :unidades, through: :conjunto_indicador_unidades, uniq: true
  has_many :indicador_valores

  accepts_nested_attributes_for :indicador_valores, allow_destroy: true

  before_create :activate

  validates :entidade_id, presence: true
  validates :nome, presence: true
  validates :nome, uniqueness: { case_sensitive: false, :scope => [:entidade_id] }, if: :abrangencia_entidade
  validates :nome, exclusion: { in: Proc.new {|ci| ci.nomes_que_nao_posso_usar }}, if: :abrangencia_unidade
  validates :nome, length: { maximum: 255 }
  validates :tipo_periodo, presence: true, inclusion: { in: [DIARIA, SEMANAL, MENSAL, ANUAL] }
  validates :abrangencia, presence: true, inclusion: { in: [UNIDADE, ENTIDADE, AMBOS] }
  validates :numero_minimo_periodos, presence: true, numericality: { only_integer: true }, numericality: { greater_than: 0 }
  validates :unidade_ids, presence: true, if: :hasUnidades?
  validates :default, :uniqueness => {:scope => [:entidade_id]}, if: :default?
  validate  :validate_indicador_valores

  scope :active, where(active: true)
  scope :by_entidade_id, lambda { |entidade_id| where(entidade_id: entidade_id)}


  def validate_indicador_valores
    rodar = true
    indicador_valores.each do |current_indicador|
      rodar = false unless current_indicador.valid?
    end

    if rodar
      ax_valor = []
      ax_frequencia = []
      indicador_valores.each do |current_indicador|
        if current_indicador.valor?
          ax = {}
          ax[:minimo] = current_indicador.valor_minimo
          ax[:maximo] = current_indicador.valor_maximo || current_indicador.valor_minimo
          ax[:operador] = current_indicador.operador
          ax_valor << ax

          indicador_valores.each do |comparison_indicador|
            if comparison_indicador.valor?
              unless comparison_indicador == current_indicador
                tem_conflito_entre_os_indicadores_de_valor? current_indicador, comparison_indicador
              end
            end
          end
        else
          if current_indicador.operador != IndicadorValor::NAO_COMPREI_NO_PERIODO
            ax = {}
            ax[:minimo] = current_indicador.frequencia_mimima
            ax[:maximo] = current_indicador.frequencia_maxima || current_indicador.frequencia_mimima
            ax[:operador] = current_indicador.operador
            ax_frequencia << ax
          end
          indicador_valores.each do |comparison_indicador|
            if comparison_indicador.frequencia?

              unless comparison_indicador == current_indicador
                tem_conflito_entre_os_indicadores_de_frequencia? current_indicador, comparison_indicador
              end
            end
          end
        end
      end

      if errors[:indicador_valores_valor].blank? && !ax_valor.blank?
        ax_valor.sort! { |a,b| a[:minimo] <=> b[:minimo] }
        if ax_valor.first[:minimo] > 0.01
          errors.add :indicador_valores_valor, "Não Existe Indicadores para Valores Menores que #{ax_valor.first[:minimo]};"
        end
        if ax_valor.last[:operador] != IndicadorValor::MAIOR && ax_valor.last[:operador] != IndicadorValor::MAIOR_OU_IGUAL
          errors.add :indicador_valores_valor, "Não Existe Indicadores para Valores Maiores que #{ax_valor.last[:maximo] || ax_valor.last[:minimo]};"
        end
        if ax_valor.count > 1
          for key in 0 ... ax_valor.size - 1
            if (ax_valor[key + 1][:minimo] - ax_valor[key][:maximo]) == 0.02
              errors.add :indicador_valores_valor, "Não Existe Indicadores para o Valor igual #{"%.2f" % (ax_valor[key][:maximo]+0.01)};"
            elsif (ax_valor[key + 1][:minimo] - ax_valor[key][:maximo]) > 0.02
              errors.add :indicador_valores_valor, "Não Existe Indicadores para os Valores entre #{"%.2f" % (ax_valor[key][:maximo] + 0.01)} e #{"%.2f" % (ax_valor[key + 1][:minimo] - 0.01)};"
            end
          end
        end
      end

      if errors[:indicador_valores_frequencia].blank? && !ax_frequencia.blank?
        ax_frequencia.sort! { |a,b| a[:minimo] <=> b[:minimo]}
        if ax_frequencia.first[:minimo] > 1
          errors.add :indicador_valores_frequencia, "Não Existe Indicadores para Frequencias menores que #{ax_frequencia.first[:minimo]};"
        end
        if ax_frequencia.count > 1
          for key in 0 ... ax_frequencia.size - 1
            if (ax_frequencia[key + 1][:minimo] - ax_frequencia[key][:maximo]) == 2
              errors.add :indicador_valores_frequencia, "Não Existe Indicadores para a Frequencia igual #{ax_frequencia[key][:maximo]+1};"
            elsif (ax_frequencia[key + 1][:minimo] - ax_frequencia[key][:maximo]) > 2
              errors.add :indicador_valores_frequencia, "Não Existe Indicadores para as Frequencias entre #{ax_frequencia[key][:maximo] + 1} e #{ax_frequencia[key + 1][:minimo] - 1};"
            end
          end
        end
      end
    end
  end

  def tem_conflito_entre_os_indicadores_de_valor? current_indicador, comparison_indicador
    if current_indicador.operador == IndicadorValor::MAIOR
      if current_indicador.valor_minimo < comparison_indicador.valor_minimo
        errors.add :indicador_valores_valor, "O Valor minimo do Indicador '#{comparison_indicador.legenda}' não pode ser menor ao valor do indicador '#{current_indicador.legenda}';"
      end
      if current_indicador.valor_minimo < comparison_indicador.valor_maximo
        errors.add :indicador_valores_valor, "O Valor maximo do Indicador '#{comparison_indicador.legenda}' não pode ser menor ao valor do indicador '#{current_indicador.legenda}';"
      end
    elsif current_indicador.operador == IndicadorValor::MAIOR_OU_IGUAL
      if current_indicador.valor_minimo <= comparison_indicador.valor_minimo
        errors.add :indicador_valores_valor, "O Valor minimo do Indicador '#{comparison_indicador.legenda}' não pode ser menor/igual ao valor do indicador '#{current_indicador.legenda}';"
      end
      if current_indicador.valor_minimo <= comparison_indicador.valor_maximo
        errors.add :indicador_valores_valor, "O Valor maximo do Indicador '#{comparison_indicador.legenda}' não pode ser menor/igual ao valor do indicador '#{current_indicador.legenda}';"
      end
    elsif current_indicador.operador == IndicadorValor::IGUAL
      if current_indicador.valor_minimo == comparison_indicador.valor_minimo
        errors.add :indicador_valores_valor, "O Valor minimo do Indicador '#{comparison_indicador.legenda}' não pode ser igual ao valor do indicador '#{current_indicador.legenda}';"
      end
      if current_indicador.valor_minimo == comparison_indicador.valor_maximo
        errors.add :indicador_valores_valor, "O Valor maximo do Indicador '#{comparison_indicador.legenda}' não pode ser igual ao valor do indicador '#{current_indicador.legenda}';"
      end
    elsif current_indicador.operador == IndicadorValor::ENTRE
      if current_indicador.valor_entre(comparison_indicador.valor_minimo)
        errors.add :indicador_valores_valor, "O Valor minimo do Indicador '#{comparison_indicador.legenda}' está em conflito com o intervalo do indicador '#{current_indicador.legenda}';"
      end
      if current_indicador.valor_entre(comparison_indicador.valor_maximo)
        errors.add :indicador_valores_valor, "O Valor maximo do Indicador '#{comparison_indicador.legenda}' está em conflito com o intervalo do indicador '#{current_indicador.legenda}';"
      end
    end
  end

  def tem_conflito_entre_os_indicadores_de_frequencia? current_indicador, comparison_indicador
    if current_indicador.operador == IndicadorValor::IGUAL
      if current_indicador.frequencia_mimima == comparison_indicador.frequencia_mimima
        errors.add :indicador_valores_frequencia, "O frequencia minima do Indicador '#{comparison_indicador.legenda}' não pode ser igual a frequencia do indicador '#{current_indicador.legenda}';"
      end
      if current_indicador.frequencia_mimima == comparison_indicador.frequencia_mimima
        errors.add :indicador_valores_frequencia, "O frequencia maxima do Indicador '#{comparison_indicador.legenda}' não pode ser igual a frequencia do indicador '#{current_indicador.legenda}';"
      end
    elsif current_indicador.operador == IndicadorValor::ENTRE
      if current_indicador.frequencia_entre(comparison_indicador.frequencia_mimima)
        errors.add :indicador_valores_frequencia, "O frequencia minima do Indicador '#{comparison_indicador.legenda}' está em conflito com o intervalo do indicador '#{current_indicador.legenda}';"
      end
      if current_indicador.frequencia_entre(comparison_indicador.frequencia_maxima)
        errors.add :indicador_valores_frequencia, "O frequencia maxima do Indicador '#{comparison_indicador.legenda}' está em conflito com o intervalo do indicador '#{current_indicador.legenda}';"
      end
    end
  end

  def indicador_valores_valor
    indicador_valores.valor
  end

  def indicador_valores_frequencia
    indicador_valores.frequencia
  end

  def activate
    write_attribute :active, ATIVO unless read_attribute :active
  end

  def default?
    default
  end

  def default_verbose
    default? ? 'Sim' : 'Não'
  end

  def active_verbose
    active ? 'Ativo' : 'Inativo'
  end

  def abrangencia_verbose
    ABRANGENCIA_VERBOSE[abrangencia]
  end

  def tipo_periodo_verbose
    TIPO_PERIODO_VERBOSE[tipo_periodo]
  end

  def active?
    active
  end

  def toggle_active
    update_attribute :active, (active ? INATIVO : ATIVO)
  end

  def set_abrangencia
    if read_attribute(:abrangencia_entidade) && read_attribute(:abrangencia_unidade)
      write_attribute :abrangencia, AMBOS
    elsif read_attribute(:abrangencia_entidade)
      write_attribute :abrangencia, ENTIDADE
    elsif read_attribute(:abrangencia_unidade)
      write_attribute :abrangencia, UNIDADE
    else
      write_attribute :abrangencia, nil
    end
  end

  def get_abrangencia value
    if abrangencia == AMBOS
      true
    else
      abrangencia == value
    end
  end

  def abrangencia_entidade= value
    write_attribute :abrangencia_entidade, value.to_i == 1
    set_abrangencia
  end

  def abrangencia_unidade= value
    write_attribute :abrangencia_unidade, value.to_i == 1
    set_abrangencia
  end

  def abrangencia_entidade
    write_attribute :abrangencia_entidade, get_abrangencia(ENTIDADE)
    read_attribute :abrangencia_entidade
  end

  def abrangencia_unidade
    write_attribute :abrangencia_unidade, get_abrangencia(UNIDADE)
    read_attribute :abrangencia_unidade
  end

  def hasUnidades?
    abrangencia_unidade
  end

  def edit_attributes(attributes)
    self.attributes = attributes
  end

  def nomes_que_nao_posso_usar
    ConjuntoIndicador.joins(:conjunto_indicador_unidades)
      .where('unidade_id IN (?)', conjunto_indicador_unidades.pluck(:unidade_id))
      .where('conjunto_indicadores.id <> ?', id)
      .pluck(:nome)
  end

  def self.retorna_indicador_default(entidade_id)
    ConjuntoIndicador.where(entidade_id: entidade_id, default: true).first.id rescue nil
  end

end
