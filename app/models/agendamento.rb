#encoding: UTF-8

class Agendamento < ActiveRecord::Base

  ### TIPO
  PRODUTOS_DESTINO = 99
  CLIENTES_DESTINO = 100
  VENDEDORES_DESTINO = 101
  NOTA_FISCAL_DESTINO = 102
  
  ### STATUS
  CRIADA = 34
  EXECUTADA = 35
  EXECUTADA_COM_ERROS = 36
  
  attr_accessible :arquivo
  attr_accessible :status
  attr_accessible :nome
  #attr_accessible :entidade_id
  attr_accessible :unidade_id
  attr_accessible :arquivo_cache

  belongs_to :unidade
  belongs_to :entidade

  validates :arquivo, presence: true
  validates :unidade, presence: true
  validates :entidade,presence: true
  validates :status, inclusion: { in: [CRIADA,EXECUTADA,EXECUTADA_COM_ERROS] }

  mount_uploader :arquivo, AgendamentoUploader


  def initialize(attributes = {})
	 attributes['status'] ||= CRIADA
	 super
  end

  def run_importation
    self.importacao_cliente
    self.importacao_produto
    self.importacao_vendedor
    self.importacao_nota_fiscal
  end
  
  def status_verbose
    case status
      when CRIADA; 'Criada'
      when EXECUTADA; 'Executada'
      when EXECUTADA_COM_ERROS; 'Executada com erros'
    end
  end

  def importacao_cliente
    hash_base = {"8"=>"Cliente.codigo_sistema_legado", "9"=>"Cliente.nome_razao_social"}
    tipo_importacao = CLIENTES_DESTINO
    self.execute_function(hash_base,tipo_importacao)
  end

  def importacao_produto
    hash_base = {"21" =>"Produto.codigo_sistema_legado","22"=>"Produto.nome"}
    tipo_importacao = PRODUTOS_DESTINO
    self.execute_function(hash_base,tipo_importacao)
  end

  def importacao_nota_fiscal
    hash_base = {"3"=>"NotaFiscal.numero_documento","7"=>"NotaFiscal.vendedor_id","9"=>"NotaFiscal.cliente_id","21"=>"NotaFiscal.produto_id","23"=>"NotaFiscal.data_emissao","28"=>"NotaFiscal.valor","29"=>"NotaFiscal.quantidade","24"=>"NotaFiscal.valor_porcentagem_desconto"}
    tipo_importacao = PRODUTOS_DESTINO
    self.execute_function(hash_base,tipo_importacao)
  end

  def importacao_vendedor
    hash_base = {"7" =>"Vendedor.codigo_sistema_legado","8"=>"Vendedor.nome"}
    tipo_importacao = VENDEDORES_DESTINO
    self.execute_function(hash_base,tipo_importacao)
  end

  def importacao_geral_excel
    begin
      spreadsheet = Roo::Excel.new(self.arquivo.path, nil, :ignore)
      header = spreadsheet.row(1)
      unidade_id = self.unidade_id
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        codigo_cliente = row["Código de CNPJ"].to.s.gsub(".0", '') rescue nil
        nome_cliente = row["Nome do cliente"]
        id_cliente = nil
        cliente_temp = ClienteTemp.new
        
        if codigo_cliente.blank?
          cliente_temp.codigo_sistema_legado = "99999999"
          cliente_temp.nome_razao_social = "Cliente #{self.unidade.nome}"
        else
          cliente_temp.codigo_sistema_legado = codigo_cliente
          cliente_temp.nome_razao_social = nome_cliente
        end

        cliente_temp.unidade_id = unidade_id
        cliente_temp.save(:validate=>false)
        cliente_temp.reload
        id_cliente = cliente_temp.id


        codigo_vendedor = row["Código do vendedor"].to_s.gsub(".0", '') rescue nil
        nome_vendedor = row["Nome do Vendedor"]
        id_vendedor = nil
        vendedor_temp = VendedorTemp.new
        
        if codigo_vendedor.blank?
          vendedor_temp.codigo_sistema_legado = "99999999"
          vendedor_temp.nome = "Vendedor #{self.unidade.nome}"
        else
          vendedor_temp.codigo_sistema_legado = codigo_vendedor
          vendedor_temp.nome = nome_vendedor
        end

        vendedor_temp.unidade_id = unidade_id
        vendedor_temp.save(:validate=>false)
        vendedor_temp.reload
        id_vendedor = vendedor_temp.id

        codigo_produto = row["Código do Produto"].to_s.gsub(".0", '') rescue nil
        nome_produto = row["Nome da Item"]
        id_produto = nil
        objeto_produto = ProdutoTemp.new
        
        if codigo_produto.blank?
          objeto_produto.codigo_sistema_legado = "99999999"
          objeto_produto.nome = "Produto #{self.unidade.nome}"
        else
          objeto_produto.codigo_sistema_legado = codigo_produto
          objeto_produto.nome = nome_produto
        end

        objeto_produto.unidade_id = unidade_id
        objeto_produto.save(:validate=>false)
        objeto_produto.reload
        id_produto = objeto_produto.id


        objeto_nota_fiscal_temp = NotaFiscalTemp.new
        objeto_nota_fiscal_temp.produto_id = objeto_produto.codigo_sistema_legado
        objeto_nota_fiscal_temp.cliente_id = cliente_temp.codigo_sistema_legado
        objeto_nota_fiscal_temp.vendedor_id = vendedor_temp.codigo_sistema_legado
        objeto_nota_fiscal_temp.data_emissao = row["Data da venda"].blank? ? Date.today : row["Data da venda"].to_date
        objeto_nota_fiscal_temp.valor = row["Valor total vendido do item"]
        objeto_nota_fiscal_temp.quantidade = row["Quantidade vendida do item"]
        objeto_nota_fiscal_temp.valor_porcentagem_desconto = row["Percentual de desconto"]
        objeto_nota_fiscal_temp.unidade_id = unidade_id
        objeto_nota_fiscal_temp.save(:validate=>false)
      end
      self.status = EXECUTADA
      self.save
      return true
    rescue Exception => e
      FileUtils.mkdir_p("#{Rails.root.to_s}/log/java/agendamento/agendamento_#{self.id}/")
      File.open("#{Rails.root.to_s}/log/java/agendamento/agendamento_#{self.id}/erros_#{self.id}.log", "wb") do |f|     
        f.write(e)   
      end
      self.status = EXECUTADA_COM_ERROS
      self.save
      return false
    end
  end

  def execute_function(hash_base,variavel_importacao)
    begin
      operacao = Importacao::PROCESSAR_PLANILHA
      retorno = []
      path = self.arquivo.file.path
      tipo_importacao = Importacao::XLS
      pasta = "agendamento"
      index_sheet = 0
      importacao_id = "#{self.id}"
      item_importacao = "#{self.id}"
      tabela_destino = variavel_importacao
      de_para = hash_base.to_json
      unidade_id = self.unidade_id
      #p "83927498213478927893897423789234789"
      #p "java -jar -Xmx1024m #{ItemImportacao::PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} '#{de_para}' #{unidade_id} #{pasta}"
      saida = %x{java -jar -Xmx1024m #{ItemImportacao::PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} '#{de_para}' #{unidade_id} #{pasta}}
      ActiveRecord::Base.connection.execute(saida)
      self.status = EXECUTADA
      self.save
      return true
    rescue Exception => e
      p e.to_s
      p e.backtrace
      FileUtils.mkdir_p("#{Rails.root.to_s}/log/java/agendamento/agendamento_#{self.id}/")
      File.open("#{Rails.root.to_s}/log/java/agendamento/agendamento_#{self.id}/erros_#{self.id}.log", "wb") do |f|     
        f.write(e)   
      end
      self.status = EXECUTADA_COM_ERROS
      self.save
      return false
    end
  end

  def self.popula_tabelas_master
    ClienteTemp.popula_tabela_master
    ProdutoTemp.popula_tabela_master
    VendedorTemp.popula_tabela_master
    NotaFiscalTemp.popula_tabela_master
  end

end
