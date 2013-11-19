# whenever --update-crontab store

set :output, { error: 'log/error.log', standard: 'log/cron.log' }

# every 3.hours do
#   runner "RelatorioFrequenciaValor.popula_tabela"
# end

every 30.minutes do
	runner "Agendamento.popula_tabelas_master"
end
