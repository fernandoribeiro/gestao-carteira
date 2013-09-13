#encoding: UTF-8

class ModuloEntidade::Administracao::ItemImportacaoJobsController < ModuloEntidade::AdminitracaoController


	def download_file
		@item_importacao = ItemImportacaoJob.find params[:id]
		if File.exists?(@item_importacao.url_file)
			send_file(@item_importacao.url_file, :type =>  "text/html", :filename => 'resultado_importacao.txt')
		else
			redirect_to [:entidade, :administracao, @item_importacao.item_importacao.importacao], notice: {success: 'O arquivo não existe!'}
		end
	end


end
