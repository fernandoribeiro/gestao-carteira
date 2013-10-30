#encoding: UTF-8

class Importacao < ActiveRecord::Base

 	XLS = 33
 	XLSX = 34
 	CSV = 35
 	TXT = 36
 	XML_NFE = 37
 	XML_NFSE = 38

 	#TABELAS
 	PRODUTOS = 99
 	CLIENTES = 100
 	VENDEDORES = 101
 	NOTA_FISCAL = 102

 	#SITUACOES
 	CRIADA = 34
 	EXECUTADA = 35

 	#OPERACOES JAVA
 	RETORNAR_COLUNAS = 1
 	PROCESSAR_PLANILHA = 2
 	RETORNAR_CABECALHO = 3
 	RETORNAR_ABAS = 4

 	#PATH_JAVA = "/Users/Marco/projetos/projetos_pessoais/projetos_rails/tripping-octo-java/target/import_gestao_carteira-1.0.jar"
 	#PATH_JAVA = "/home/guizao/projetos/dev/gestao_carteira_java/target/import_gestao_carteira-1.0.jar"
 	PATH_JAVA = "/Users/paulozeferino/projetos/devconnit/pdvcheck/gestao-carteira-java/target/import_gestao_carteira-1.0.jar"


	attr_accessible :nome
	attr_accessible :unidade_id
	attr_accessible :tipo_arquivo
	attr_accessible :situacao
	attr_accessible :arquivo
	attr_accessible :arquivo_cache

	validates :nome, presence: true
	validates :tipo_arquivo, presence: true
	validates :arquivo, presence: true
	validates :unidade, presence: true

	has_many :item_importacoes

  belongs_to :unidade
  belongs_to :entidade

	validates :tipo_arquivo, inclusion: { in: [XLS, XLSX, CSV, TXT, XML_NFE, XML_NFSE] }

	mount_uploader :arquivo, ImportacaoUploader


	def initialize(attributes = {})
		attributes['situacao'] ||= CRIADA
		super
	end

	def situacao_verbose
		case situacao
			when CRIADA; 'Criada'
			when EXECUTADA; 'Executada'
		end
	end

	def tipo_arquivo_verbose
		case tipo_arquivo
			when XLS; 'XLS'
			when XLSX; 'XLSX'
			when CSV; 'CSV'
			#when TXT; 'TXT'
			#when XML_NFE; 'XML NFE'
			#when XML_NFSE; 'XML NFSE'
		end
	end

	def self.return_tipo_arquivo_for_select
		[
			['XLS', XLS],
			['XLSX', XLSX],
			['CSV', CSV]#,
			#['TXT', TXT],
			#['XML NFE', XML_NFE],
			#['XML NFSE', XML_NFSE],
		]
	end

	def open_spreadsheet
		path = self.arquivo.file.path
		case self.get_extension_of_file
		    	when '.csv' then Csv.new(path, nil, :ignore)
			when '.xls' then Excel.new(path, nil, :ignore)
			when '.xlsx' then Excelx.new(path, nil, :ignore)
			else raise "Tipo de arquivo desconhcido: #{file.original_filename}"
		end
	end

	def get_extension_of_file
		File.extname(self.arquivo.file.original_filename)
	end

	def return_headers_of_spreadsheet_file(indice)
		unidade_id = self.unidade_id
		path = self.arquivo.file.path
	    operacao = RETORNAR_CABECALHO
	    retorno = []
	    pasta = "importacao"
	    tipo_importacao = XLS
	    index_sheet = indice
	    importacao_id = 0
	    item_importacao = 0
	    tabela_destino = 0
	    de_para = "null"
	    p "java -jar -Xmx1024m #{PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} #{de_para} #{unidade_id}"
	    saida = %x{java -jar -Xmx1024m #{PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} #{de_para} #{unidade_id} #{pasta}}
	    p saida
		saida.split("\t").reject!(&:blank?)
	end

	def return_number_of_columns
		unidade_id = self.unidade_id
	    path = self.arquivo.file.path
	    operacao = RETORNAR_COLUNAS
	    pasta = "importacao"
	    tipo_importacao = CSV
	    index_sheet = 0
	    importacao_id = 0
	    item_importacao = 0
	    tabela_destino = 0
	    de_para = "null"
	    saida = %x{java -jar -Xmx1024m #{PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} #{de_para} #{unidade_id} #{pasta}}
	    saida		
	end

	def return_sheets_of_spreadsheet_file
		unidade_id = self.unidade_id
	    path = self.arquivo.file.path
	    operacao = RETORNAR_ABAS
	    pasta = "importacao"
	    retorno = []
	    tipo_importacao = XLS
	    index_sheet = 0
	    importacao_id = 0
	    item_importacao = 0
	    tabela_destino = 0
	    de_para = "null"
	    p "java -jar -Xmx1024m #{PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} #{de_para} #{unidade_id}"
	    saida = %x{java -jar -Xmx1024m #{PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} #{de_para} #{unidade_id} #{pasta}}

	    saida.split("\n").each_with_index do |dado,index|
	      retorno << [dado, index]
	    end
	    retorno
   end

end
