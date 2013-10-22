#encoding: UTF-8
class ItemImportacao < ActiveRecord::Base

  attr_accessible :aba_trabalho_index
  attr_accessible :aba_trabalho_nome
  attr_accessible :de_para
  attr_accessible :ordem
  attr_accessible :tabela_sistema_destino
  attr_accessible :linha_inicio
  attr_accessible :linha_fim
  attr_accessible :situacao
  attr_accessible :dependentes

  belongs_to :importacao
  has_many :item_importacao_jobs
  before_validation :validate_de_para

  serialize :de_para, Hash


  validate :verifica_integridade_de_para
 # validate :verifica_se_possui_importacoes_de_outro_tipo
  validates :tabela_sistema_destino, presence: true
  validates :de_para, presence: true
  validates :aba_trabalho_index, presence: true, :if=>:is_spreadsheet_file?

  CRIADA = 44
  EXECUTADA = 45
  PROCESSADA_COM_SUCESSO = 45
  PROCESSADA_COM_ERROS = 46
 # PATH_JAVA = "/Users/Marco/projetos/projetos_pessoais/projetos_rails/tripping-octo-java/target/import_gestao_carteira-1.0.jar"
  #PATH_JAVA = "/home/guizao/projetos/dev/gestao_carteira_java/target/import_gestao_carteira-1.0.jar"
  PATH_JAVA = "/Users/paulozeferino/projetos/devconnit/pdvcheck/gestao-carteira-java/target/import_gestao_carteira-1.0.jar"

  def situacao_verbose
    case situacao
      when CRIADA; "Criada"
      when EXECUTADA; "Em Execução"
      when PROCESSADA_COM_SUCESSO; "Processada com sucesso"
      when PROCESSADA_COM_ERROS; "Processada com erros"
    end
  end

  def is_spreadsheet_file?
    if self.importacao.tipo_arquivo == Importacao::XLS || self.importacao.tipo_arquivo == Importacao::XLSX
      true
    else
      false
    end
  end

  def initialize(attributes = {})
    attributes["situacao"] ||= CRIADA
    super
  end

  def validate_de_para
    self.de_para = self.de_para.delete_if { |k, v| v.empty? }
   # self.de_para = self.de_para.invert unless self.de_para.blank?
  end

  def self.return_tables_of_the_system_to_select
    [
      ["Produtos",Importacao::PRODUTOS],
		  ["Clientes",Importacao::CLIENTES],
			["Vendedores",Importacao::VENDEDORES],
			["Nota Fiscal",Importacao::NOTA_FISCAL],
		]
	end

  def verifica_integridade_de_para
    de_para_invertido = self.de_para.invert
    unless self.de_para.blank?
      if tabela_sistema_destino == Importacao::PRODUTOS
        ["codigo_sistema_legado","nome"].each do |field|
            errors.add :base, "O atributo #{field} precisa ser mapeado" unless de_para_invertido.has_key?("Produto.#{field}")
        end
      elsif tabela_sistema_destino == Importacao::CLIENTES
          ["codigo_sistema_legado","nome_razao_social"].each do |field|
            errors.add :base, "O atributo #{field} precisa ser mapeado" unless de_para_invertido.has_key?("Cliente.#{field}")
        end

      elsif tabela_sistema_destino == Importacao::VENDEDORES
        ["codigo_sistema_legado","nome"].each do |field|
            errors.add :base ,"O atributo #{field} precisa ser mapeado" unless de_para_invertido.has_key?("Vendedor.#{field}")
        end
      elsif tabela_sistema_destino == Importacao::NOTA_FISCAL
        ["vendedor_id","cliente_id","numero_documento","data_emissao","produto_id","quantidade","valor"].each do |field|
            errors.add :base ,"O atributo #{field} precisa ser mapeado" unless de_para_invertido.has_key?("NotaFiscal.#{field}")
        end
      end
    end
  end

  def verifica_se_possui_importacoes_de_outro_tipo
    if tabela_sistema_destino == Importacao::NOTA_FISCAL
      [Importacao::CLIENTES,Importacao::PRODUTOS,Importacao::VENDEDORES].each do |tabela_destino|
        errors.add :base, "Para cadastrar uma importação deste tipo, é necessário executar ao menos uma vez uma importação de Clientes, Produtos e Vendedores."  if ItemImportacao.joins(:importacao).where("item_importacoes.situacao = ? AND tabela_sistema_destino = ? AND importacoes.unidade_id = ?",EXECUTADA,tabela_destino,self.importacao.unidade_id).blank?
      end
    end
  end

  
  def self.return_class_name(opcao)
    case opcao
      when Importacao::PRODUTOS;"Produto"
      when Importacao::CLIENTES;"Cliente"
      when Importacao::VENDEDORES;"Vendedor"
      when Importacao::NOTA_FISCAL;"NotaFiscal"
    end
  end

  def tabela_sistema_destino_verbose
    case tabela_sistema_destino
      when Importacao::PRODUTOS;"Produto"
      when Importacao::CLIENTES;"Cliente"
      when Importacao::VENDEDORES;"Vendedor"
      when Importacao::NOTA_FISCAL;"Nota Fiscal"
    end
  end

  def self.return_attributes_of_class(opcao,dependentes)
    retorno = [""]
    ignorar = ["id","created_at","updated_at","importacao_id","nota_fiscal_id","unidade_id"]
    if opcao.to_i == Importacao::PRODUTOS
      Produto.column_names.each do |coluna|
        unless ignorar.include?(coluna)
          if coluna.end_with?("_id")
            classe = coluna.split("_id").first.capitalize
            colunas_chave_estrangeira = eval("#{classe}.column_names") rescue nil
            if colunas_chave_estrangeira.blank?
              retorno << "Produto.#{coluna}"
            else
              colunas_chave_estrangeira.each do |col_foreign_key|
                retorno << "Produto.#{classe}.#{col_foreign_key}" unless ignorar.include?(col_foreign_key)
              end
            end
          else
            retorno << "Produto.#{coluna}"
          end
        end
      end
    elsif opcao.to_i == Importacao::CLIENTES
      Cliente.column_names.each do |coluna|
        unless ignorar.include?(coluna)
          if coluna.end_with?("_id")
            classe = coluna.split("_id").first.capitalize
            p classe
            colunas_chave_estrangeira = eval("#{classe}.column_names") rescue nil
            if colunas_chave_estrangeira.blank?
              retorno << "Cliente.#{coluna}"
            else
              colunas_chave_estrangeira.each do |col_foreign_key|
                retorno << "#{classe}.#{col_foreign_key}" unless ignorar.include?(col_foreign_key)
              end
            end
          else
            retorno << "Cliente.#{coluna}"
          end
        end
      end
    elsif opcao.to_i == Importacao::VENDEDORES
      Vendedor.column_names.each do |coluna|
        unless ignorar.include?(coluna)
          retorno << "Vendedor.#{coluna}"
        end
      end
    elsif opcao.to_i == Importacao::NOTA_FISCAL
      NotaFiscal.column_names.each do |coluna|
        unless ignorar.include?(coluna)
          if coluna.end_with?("_id") && dependentes == "true"
             classe = coluna.split("_id").first.capitalize
             colunas_chave_estrangeira = eval("#{classe}.column_names") rescue nil
             if colunas_chave_estrangeira.blank?
                retorno << "NotaFiscal.#{coluna}"
             else
                colunas_chave_estrangeira.each do |col_foreign_key|
                   retorno << "#{classe}.#{col_foreign_key}" unless ignorar.include?(col_foreign_key)
                end
             end
          else
            retorno << "NotaFiscal.#{coluna}"
          end
        end
      end
    end
    retorno
  end

end
