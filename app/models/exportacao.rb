#encoding: UTF-8

class Exportacao

	def self.gera_arquivo_agile(unidade)
		begin
			folder = Rails.root.join('app', 'assets', 'exportacoes')
			Dir::mkdir(folder) unless Dir.exists?(folder)
  		file = File.open("#{folder}/#{unidade.slug}_#{DateTime.now.strftime('%Y%m%d_%H:%M')}", 'w')
  		NotaFiscal.where(unidade_id: unidade.id).limit(10).each do |item_nota|
  			### RJUST = Numérico
  			### LJUST = Alfanumérico
	  		
				### Código da empresa no sistema | 005
	  		file.write(item_nota.unidade.entidade.id.to_s[0..4].rjust(5, '0') + ';')
				### Código da filial | 006
				file.write(item_nota.unidade.id.to_s[0..5].rjust(6, '0') + ';')
				### Número da Nota Fiscal | 010
				file.write(item_nota.numero_documento.to_s[0..9].ljust(10) + ';')
				### Série da Nota Fiscal | 002 ----- NÃO TEMOS
				file.write(''.to_s[0..1].ljust(2) + ';')
				### Código do fabricante | 006
				file.write(''.to_s[0..5].rjust(6, '0') + ';')
				### Código do item do fabricante | 033
				file.write(item_nota.produto.codigo_sistema_legado.to_s[0..32].ljust(33) + ';')
				### Código do vendedor | 040
				file.write(item_nota.vendedor.codigo_sistema_legado.to_s[0..39].ljust(40) + ';')
				### Nome do Vendedor | 030
				file.write(item_nota.vendedor.nome.to_s[0..29].ljust(30) + ';')
				### Código de CNPJ | 014
				file.write(item_nota.cliente.cpf_cnpj.to_s.trata_cnpj[0..13].ljust(14) + ';')
				### Nome do cliente | 040
				file.write(item_nota.cliente.nome_razao_social.to_s[0..39].ljust(40) + ';')
				### Classificação do Cliente | 020
				file.write(''.to_s[0..19].ljust(20) + ';')
				### Telefone do cliente | 020
				file.write(item_nota.cliente.telefone.to_s[0..19].ljust(20) + ';')
				### Data da primeira compra | 008
				file.write(item_nota.cliente.pesquisa_data_primeira_compra.to_s.trata_data[0..7].rjust(8, '0') + ';')
				### Município do cliente | 030
				file.write(item_nota.cliente.cidade_nome.to_s[0..29].ljust(30) + ';')
				### UF | 002
				file.write(item_nota.cliente.estado.to_s[0..1].ljust(2) + ';')
				### Email do contato | 055
				file.write(item_nota.cliente.email.to_s[0..54].ljust(55) + ';')
				### Contato | 020 ----- NÃO TEMOS
				file.write(''.to_s[0..20].ljust(20) + ';')
				### Telefone residencial do contato | 016 ----- NÃO TEMOS
				file.write(''.to_s[0..15].ljust(16) + ';')
				### Telefone celular do contato | 016 ----- NÃO TEMOS
				file.write(''.to_s[0..15].ljust(16) + ';')
				### CEP | 009 ----- NÃO TEMOS
				file.write(''.to_s[0..8].ljust(9) + ';')
				### Grupe de classificação da peça | 025 ----- NÃO TEMOS
				file.write(''.to_s[0..24].ljust(25) + ';')
				### Nome do Item | 025
				file.write(item_nota.produto.nome.to_s[0..24].ljust(25) + ';')
				### Data da venda | 008
				file.write(item_nota.data_emissao.to_s.trata_data[0..7].rjust(8, '0') + ';')
				### Percentual de desconto | 007
				file.write(item_nota.valor_porcentagem_desconto.to_s.trata_valores(7) + ';')
				### Margem de lucro | 008 ----- NÃO TEMOS
				file.write(''.to_s.trata_valores(8) + ';')
				### Condição de pagamento | 002 ----- NÃO TEMOS
				file.write(''.to_s[0..1].ljust(2) + ';')
				### Tipo de faturamento | 002 ----- NÃO TEMOS
				file.write('OU'.to_s[0..1].ljust(2) + ';')
				### Valor total vendido do item | 011
				file.write(item_nota.calcula_valor_total_item.to_s.trata_valores(11) + ';')
				### Quantidade vendida do item | 006
				file.write(item_nota.quantidade.to_i.to_s[0..5].rjust(6, '0'))
				file.write("\n")
			end
		rescue IOError => e
  		p e.message
		ensure
  		file.close unless file == nil
		end
	end

end
