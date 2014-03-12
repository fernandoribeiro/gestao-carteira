#encoding: UTF-8

class DeParaProdutoJob < ActiveRecord::Base

	### STATUS
  ESPERA 	= 13421
  SUCESSO = 21549
  AVISOS 	= 67880
  ERROS 	= 34525

  attr_accessible :nome
  attr_accessible :status
  attr_accessible :resultado
  attr_accessible :arquivo
  attr_accessible :arquivo_cache
  attr_accessible :unidade_id

	mount_uploader :arquivo, ProdutoEntidadeJobUploader

  belongs_to :unidade

  validates :nome, presence: true
  validates :arquivo, presence: true
  validates :unidade, presence: true
  validates :status, inclusion: { in: [ESPERA, SUCESSO, ERROS, AVISOS] }


  def initialize(attributes = {})
    attributes['status'] ||= ESPERA
    super
  end

  def status_verbose
  	case status
    when ESPERA; 'Espera'
	 	when SUCESSO; 'Sucesso'
	 	when ERROS; 'Erros'
	 	when AVISOS; 'Advertências'
  	end
  end

  def run_importacao
  	begin
      spreadsheet = Roo::Excel.new(self.arquivo.path, nil, :ignore)
      header = spreadsheet.row(1)
      erros  = []
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        cod_prod_base 	 = row['COD PROD BASE'].to_s.gsub('.0', '').strip rescue nil
        nome_prod_base 	 = row['NOME PROD BASE'].strip.upcase
        cod_prod_unidade = row['COD PROD UNIDADE'].to_s.gsub('.0', '').strip rescue nil

        produto_base 		= ProdutoEntidade.find_by_entidade_id_and_codigo_and_descricao(
        																		self.unidade.entidade_id, cod_prod_base, nome_prod_base)
        produto_unidade = Produto.find_by_unidade_id_and_codigo_sistema_legado(self.unidade_id, cod_prod_unidade)

        if produto_base.blank?
        	erros << "Linha #{i}: O seguinte produto não foi encontrado na entidade #{self.unidade.entidade.nome}: (#{cod_prod_base}) - #{nome_prod_base}"
        end

        if produto_unidade.blank?
        	erros << "Linha #{i}: O seguinte produto não foi encontrado na unidade #{self.unidade.nome}: #{cod_prod_unidade}"
        end

        if produto_base.present? && produto_unidade.present?
	        de_para = DeParaProduto.where(produto_entidade_id: produto_base.id)
	        											 .where(produto_id: produto_unidade.id)
	        											 .first rescue nil
					if de_para.blank?
						DeParaProduto.create({
																	produto_entidade_id: produto_base.id,
																	produto_id: produto_unidade.id,
																	unidade_id: self.unidade_id
																})
					end
				end
      end

      if erros.blank?
      	self.status = SUCESSO
      	self.resultado = 'Importação executada com sucesso!'
      else
      	self.status = AVISOS
      	self.resultado = 'Importação executada com advertências!'
      	FileUtils.mkdir_p("#{Rails.root.to_s}/log/java/de_para_produtos/de_para_produtos_#{self.id}/")
      	File.open("#{Rails.root.to_s}/log/java/de_para_produtos/de_para_produtos_#{self.id}/erros_#{self.id}.log", 'wb') do |f|
        	f.write(erros.join("\n"))   
      	end
      end
      self.save
      return true
    rescue Exception => e
    	p e.backtrace
      FileUtils.mkdir_p("#{Rails.root.to_s}/log/java/de_para_produtos/de_para_produtos_#{self.id}/")
      File.open("#{Rails.root.to_s}/log/java/de_para_produtos/de_para_produtos_#{self.id}/erros_#{self.id}.log", 'wb') do |f|
        f.write(e)
      end
      self.status = ERROS
      self.resultado = 'A importação possui erros. Verifique o arquivo de log gerado.'
      self.save
      return false
    end
  end

end
