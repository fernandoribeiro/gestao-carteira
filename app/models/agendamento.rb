class Agendamento < ActiveRecord::Base

  CRIADA = 34
  EXECUTADA = 35
  
  attr_accessible :arquivo
  attr_accessible :status
  attr_accessible :nome
  #attr_accessible :entidade_id
  attr_accessible :unidade_id
  attr_accessible :arquivo_cache



  validates :arquivo, presence: true
  validates :unidade, presence: true
  validates :entidade,presence: true

  belongs_to :unidade
  belongs_to :entidade


  validates :status, inclusion: { in: [CRIADA,EXECUTADA] }

  mount_uploader :arquivo, AgendamentoUploader


  def initialize(attributes = {})
	 attributes['status'] ||= CRIADA
	 super
  end

  
  def status_verbose
    case status
      when CRIADA; 'Criada'
      when EXECUTADA; 'Executada'
    end
  end





end
