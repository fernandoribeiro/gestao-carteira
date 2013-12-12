#encoding: UTF-8

class LogAcesso < ActiveRecord::Base
  
	attr_accessible :usuario_entidade_id
	attr_accessible :entidade_id

  belongs_to :usuario_entidade
  belongs_to :entidade

  validates :usuario_entidade, presence: true
  validates :entidade, presence: true

	scope :by_entidade_id, lambda { |entidade_id| where(entidade_id: entidade_id)}


  def self.pesquisa(entidade_id, pesquisa)
    logs = LogAcesso.joins(:usuario_entidade)
     				 				.by_entidade_id(entidade_id)
           	 				.order(:created_at)
		logs = logs.where('usuario_entidades.nome ILIKE ? OR usuario_entidades.username ILIKE ?',
           	 				 	 pesquisa[:texto].like, pesquisa[:texto].like) if pesquisa[:texto].present?
		logs = logs.where('DATE(log_acessos.created_at) >= ?', pesquisa[:data_inicial].to_date) if pesquisa[:data_inicial].present?
		logs = logs.where('DATE(log_acessos.created_at) <= ?', pesquisa[:data_final].to_date) if pesquisa[:data_final].present?
    logs
  end

end
