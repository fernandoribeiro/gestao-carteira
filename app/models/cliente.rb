# encoding: UTF-8

class Cliente < ActiveRecord::Base

  FISICA = 72910
  JURIDICA = 19632

	attr_accessible :nome_razao_social
  attr_accessible :cpf_cnpj
	attr_accessible :tipo_pessoa
	attr_accessible :codigo_sistema_legado
	attr_accessible :cidade_id
	attr_accessible :estado
	attr_accessible :email
	attr_accessible :cidade_nome
	attr_accessible :telefone
	attr_accessible :outros_campos
	attr_accessible :unidade_id
	attr_accessible :active

	belongs_to :unidade

  validates :unidade, presence: true
  validates :codigo_sistema_legado, presence: true,
                                    uniqueness: { case_sensitive: false, scope: [:unidade_id] },
                                    length: { maximum: 255 }
  validates :nome_razao_social, presence: true,
                                length: { maximum: 255 }
                                # uniqueness: { case_sensitive: false, scope: [:unidade_id] }


  def active_verbose
    case active
    when true; 'Ativo'
    when false; 'Inativo'
    end
  end

  def tipo_pessoa_verbose
    case tipo_pessoa
    when FISICA; 'Física'
    when JURIDICA; 'Jurídica'
    when nil; 'Não informado'
    end
  end

  def label_nome_razao_social
    case tipo_pessoa
    when FISICA; 'Nome'
    when JURIDICA; 'Razão Social'
    when nil; 'Nome/Razão Social'
    end
  end

  def self.pesquisa(entidade, params)
    if params[:texto].blank?
      Cliente.joins(:unidade)
             .where('unidades.entidade_id = ?', entidade.id)
             .order('clientes.nome_razao_social')
    else
      Cliente.joins(:unidade)
             .where("unidades.entidade_id = ? AND
                    (clientes.nome_razao_social ILIKE ? OR clientes.codigo_sistema_legado ILIKE ?)",
                    entidade.id, params[:texto].like, params[:texto].like)
             .order('clientes.nome_razao_social')
    end
  end

  def pesquisa_data_primeira_compra
    NotaFiscal.where(cliente_id: self.id).minimum(:data_emissao)
  end

end
