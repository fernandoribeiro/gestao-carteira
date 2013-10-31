# whenever --update-crontab store

set :output, { error: 'log/error.log', standard: 'log/cron.log' }

# every 3.hours do
#   runner "RelatorioFrequenciaValor.popula_tabela"
# end

every 30.minutes do
	runner "ClienteTemp.popula_tabela_master"
	runner "ProdutoTemp.popula_tabela_master"
	runner "VendedorTemp.popula_tabela_master"
  runner "NotaFiscalTemp.popula_tabela_master"
end
