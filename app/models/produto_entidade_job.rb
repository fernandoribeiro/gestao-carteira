#encoding: UTF-8

class ProdutoEntidadeJob < ActiveRecord::Base

	### STATUS
  ESPERA  = 19875
  SUCESSO = 23545
  ERROS   = 43587

  attr_accessible :nome
  attr_accessible :status
  attr_accessible :resultado
  attr_accessible :arquivo
  attr_accessible :arquivo_cache
  attr_accessible :entidade_id

	mount_uploader :arquivo, ProdutoEntidadeJobUploader

  belongs_to :entidade

  validates :nome, presence: true
  validates :arquivo, presence: true
  validates :entidade, presence: true
  validates :status, inclusion: { in: [ESPERA, SUCESSO, ERROS] }


  def initialize(attributes = {})
    attributes['status'] ||= ESPERA
    super
  end

  def status_verbose
  	case status
    when ESPERA; 'Espera'
	 	when SUCESSO; 'Sucesso'
	 	when ERROS; 'Erros'
  	end
  end

  def run_importacao
  	begin
      spreadsheet = Excel.new(self.arquivo.path, nil, :ignore)
      header = spreadsheet.row(1)
      entidade_id = self.entidade_id
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        categoria = row['CATEGORIA'].strip.upcase
        descricao = row['DESCRIÇÃO'].strip.upcase
        ean = row['EAN - 13'].to_s.gsub('.0', '').strip rescue nil
        # peso_unid = row['PESO UNID.'].strip

        produto_base = ProdutoEntidade.find_by_entidade_id_and_marca_and_descricao(entidade_id, categoria, descricao)
        produto_base = ProdutoEntidade.new if produto_base.blank?
				produto_base.codigo      = ean
				produto_base.descricao   = descricao
				produto_base.marca       = categoria
				produto_base.ean         = ean
				# produto_base.peso        = peso_unid
  			produto_base.entidade_id = entidade_id
        produto_base.save
      end
      self.status = SUCESSO
      self.resultado = 'Importação executada com sucesso!'
      self.save
      return true
    rescue Exception => e
      FileUtils.mkdir_p("#{Rails.root.to_s}/log/java/produtos_base/produtos_base_#{self.id}/")
      File.open("#{Rails.root.to_s}/log/java/produtos_base/produtos_base_#{self.id}/erros_#{self.id}.log", "wb") do |f|
        f.write(e)   
      end
      self.status = ERROS
      self.resultado = 'A importação possui erros. Verifique o arquivo de log gerado.'
      self.save
      return false
    end
  end

end
