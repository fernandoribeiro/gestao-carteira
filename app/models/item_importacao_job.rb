#encoding: UTF-8

class ItemImportacaoJob < ActiveRecord::Base

   attr_accessible :item_importacao_id
   attr_accessible :status
   attr_accessible :arquivo
   attr_accessible :unidade_id
   attr_accessible :resultado

   belongs_to :unidade
   belongs_to :item_importacao

   ESPERA = 1
   EXECUCAO = 2
   SUCESSO = 3
   ERROS = 4


   def initialize(attributes = {})
	   attributes['status'] ||= ESPERA
	   super
   end

   def status_verbose
   		case status
        when ESPERA;"Espera"
		   	when EXECUCAO;"Execução"
		   	when SUCESSO;"Sucesso"
		   	when ERROS;"Erros"
   		end
   end

   def run_function
      retorno = self.execute_function
      if File.exists?(self.url_file)
         self.status = ERROS
         self.arquivo = self.url_file
      else
         self.status = SUCESSO
         @importacao = self.item_importacao.importacao
         @importacao.situacao = Importacao::EXECUTADA
         @importacao.save
      end
      unless retorno.blank?
         self.retorno = "Os registros foram salvos na tabela temporária com sucesso!"
      else 
         self.retorno = "Erro de importação!"
      end
      self.save
   end

   def url_file
   		"#{Rails.root.to_s}/log/java/importacoes/#{self.item_importacao.importacao.id}/erros_#{self.item_importacao.importacao.id}_#{self.item_importacao_id}_#{self.id}.log"
   end

   def execute_function
     begin
       operacao = Importacao::PROCESSAR_PLANILHA
       retorno = []
       @item_importacao = self.item_importacao
       path = @item_importacao.importacao.arquivo.file.path
       pasta = "importacao"
       tipo_importacao = Importacao::XLS
       index_sheet = @item_importacao.aba_trabalho_index
       importacao_id = @item_importacao.importacao_id
       item_importacao = @item_importacao.id
       tabela_destino = @item_importacao.tabela_sistema_destino
       de_para = @item_importacao.de_para.to_json
       unidade_id = @item_importacao.importacao.unidade_id
       saida = %x{java -jar -Xmx1024m #{ItemImportacao::PATH_JAVA} #{path} #{operacao} #{tipo_importacao} #{index_sheet} #{importacao_id} #{item_importacao} #{tabela_destino} '#{de_para}' #{unidade_id} #{pasta}}
       ActiveRecord::Base.connection.execute(saida)
       return true
      rescue Exception => e
         FileUtils.mkdir_p("#{Rails.root.to_s}/log/java/importacoes/#{self.item_importacao.importacao.id}/")
         File.open("#{Rails.root.to_s}/log/java/importacoes/#{self.item_importacao.importacao.id}/erros_#{self.item_importacao.importacao.id}_#{self.item_importacao_id}_#{self.id}.log", "wb") do |f|     
            f.write(e)   
          end
          return false
      end
   end

end
