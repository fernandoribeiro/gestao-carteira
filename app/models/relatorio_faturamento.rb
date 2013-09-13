class RelatorioFaturamento < ActiveRecord::Base


  def self.clientes_em_uma_faixa(params)
    parametros_consulta = Relatorio.trata_parametros(params)
    objeto_conjunto_indicador= ConjuntoIndicador.find parametros_consulta[:indicador_id] rescue return []
    #    conjunto_indicador = (objeto_conjunto_indicador).indicador_valores.group_by(&:tipo)
    obj_indicador_valor = IndicadorValor.find params["valor_id"]
    p obj_indicador_valor
    obj_indicador_frequencia = IndicadorValor.find params["frequencia_id"]

    p obj_indicador_frequencia
    numero_de_periodos_anteriores = objeto_conjunto_indicador.numero_minimo_periodos
    clausula_where_date = {}
    valor_total = params["total"].to_f.round(2)
    unidade_id = parametros_consulta[:unidade_id]

    if objeto_conjunto_indicador.tipo_periodo == ConjuntoIndicador::MENSAL
      data_base_anterior =  Date.today - numero_de_periodos_anteriores.months
      mes_inicio = data_base_anterior.month.to_i
      ano_inicio = data_base_anterior.year.to_i

      mes_corrente = nil

      if parametros_consulta[:mes].blank?
        mes_corrente = (Date.today - 1.month).month.to_i
      else
        mes_corrente = parametros_consulta[:mes].to_i - 1
      end

      if parametros_consulta[:ano].blank?
        ano_corrente = (Date.today.year).to_i
      else
        ano_corrente = parametros_consulta[:ano].to_i
      end


      mes_semestre = 0
      ano_semestre = 0
      if (mes_corrente - 6) < 0
        ano_semestre = ano_corrente - 1
        mes_semestre = (12 + (mes_corrente - 6)) +1 #O mais 1 é pq o 0 conta como mês
      else
        mes_semestre =  mes_corrente - 6
        ano_semestre = ano_corrente
      end

      clausula_where_semestre = {}
      (ano_semestre..ano_corrente).each do |ano|
        clausula_where_semestre[ano]||= []
        if ano < ano_corrente
          mes_semestre.upto(12).each do |mes|
            clausula_where_semestre[ano] << mes
          end
        else
          1.upto(mes_corrente).each do |mes|
            clausula_where_semestre[ano] << mes
          end
        end
      end



      (ano_inicio..ano_corrente).each do |ano|
        clausula_where_date[ano]||= []
        if ano == ano_inicio
          mes_inicio.upto(12).each do |mes|
            clausula_where_date[ano] << mes
          end
        elsif ano < ano_corrente
          1.upto(12).each do |mes|
            clausula_where_date[ano] << mes
          end
        elsif ano == ano_corrente
          1.upto(mes_corrente).each do |mes|
            clausula_where_date[ano] << mes
          end
        end
      end
    end

    hash_frequencia = {}
    hash_valor = {}
    retorno = {}

    hash_frequencia[obj_indicador_frequencia.legenda]||={}
    hash_frequencia[obj_indicador_frequencia.legenda]["id"] ||= obj_indicador_frequencia.id


    if obj_indicador_frequencia.operador == IndicadorValor::IGUAL
      hash_frequencia[obj_indicador_frequencia.legenda]["valor"] ||= ">= #{obj_indicador_frequencia.frequencia_mimima}"
    elsif obj_indicador_frequencia.operador == IndicadorValor::ENTRE
      hash_frequencia[obj_indicador_frequencia.legenda]["valor"] ||= "between #{obj_indicador_frequencia.frequencia_mimima} AND #{hash_frequencia.frequencia_maxima}"
    elsif obj_indicador_frequencia.operador == IndicadorValor::NAO_COMPREI_NO_PERIODO
      hash_frequencia[obj_indicador_frequencia.legenda]["valor"] ||= " = 0"
    end


    hash_valor[obj_indicador_valor.legenda]||={}
    hash_valor[obj_indicador_valor.legenda]["id"] ||= obj_indicador_valor.id


    if obj_indicador_frequencia.operador == IndicadorValor::IGUAL
      hash_valor[obj_indicador_valor.legenda]["valor"] ||= ">= #{obj_indicador_valor.valor_minimo}"
    elsif obj_indicador_frequencia.operador == IndicadorValor::ENTRE
      hash_valor[obj_indicador_valor.legenda]["valor"] ||= "between #{obj_indicador_valor.valor_minimo} AND #{hash_frequencia.valor_maximo}"
    elsif obj_indicador_frequencia.operador == IndicadorValor::NAO_COMPREI_NO_PERIODO
      hash_valor[obj_indicador_valor.legenda]["valor"] ||= " = 0"
    end





    #MONTANDO CLAUSULA where
    clausula_where = []
    clausula_where_date.each do |parametros|
      ano_where = parametros.first
      mes_inicio_where = parametros.last.min
      mes_final_where = parametros.last.max
      clausula_where << "((ano = #{ano_where} AND mes between #{mes_inicio_where} AND #{mes_final_where}))"
    end

    clausula_where_semestre_sql = []

    clausula_where_semestre.each do |parametros|
      ano_where = parametros.first
      mes_inicio_where = parametros.last.min
      mes_final_where = parametros.last.max
      clausula_where_semestre_sql << "((ano = #{ano_where} AND mes between #{mes_inicio_where} AND #{mes_final_where}))"
    end
    controle_numero_de_clientes = 0
    controle_faturamento = 0
    controle_faturamento_mes_corrente = 0


    hash_frequencia.each do |valores_frequencia|
      indicador_frequencia = valores_frequencia.first
      condicao_frequencia = valores_frequencia.last["valor"]
      id_indicador_frequencia = valores_frequencia.last["id"]
      hash_valor.each do |valores|

        indicador_valor = valores.first
        condicao_valor = valores.last["valor"]
        id_indicador_valor = valores.last["id"]
        retorno["#{indicador_frequencia}#{indicador_valor}"] ||= {}
        sql = nil
        sql_faturamento_mes_atual = nil
        sql_faturamento_semestre = nil

        if unidade_id.blank?
          sql = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where #{clausula_where.join(" OR ")}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_mes_atual = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where mes = #{Date.today.month} and ano = #{Date.today.year} AND cliente_id = ?
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_semestre = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where #{clausula_where_semestre_sql.join(" OR ")} AND cliente_id = ?
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

        else
          sql = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where (#{clausula_where.join(" OR ")}) AND unidade_id = #{unidade_id}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_semestre = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where (#{clausula_where_semestre_sql.join(" OR ")}) AND unidade_id = #{unidade_id} AND cliente_id = ?
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_mes_atual = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where mes = #{Date.today.month} and ano = #{Date.today.year} AND unidade_id = #{unidade_id} AND cliente_id = ?
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"


        end

        resultado_sql = ActiveRecord::Base.connection.execute(sql)
        retorno = {}
        resultado_sql.each do |resultado|
          #   p resultado
          cliente = Cliente.find resultado["cliente"]
          retorno[cliente.nome_razao_social] ||={}
          retorno[cliente.nome_razao_social]["total_comprado"] ||= resultado["valor_compra"].to_f.round(2)

          retorno[cliente.nome_razao_social]["porcentagem_compra"] ||= (retorno[cliente.nome_razao_social]["total_comprado"] /valor_total.to_f * 100).round(2)

          retorno[cliente.nome_razao_social]["media_no_periodo"] ||= (resultado["valor_compra"].to_f.round(2) / numero_de_periodos_anteriores).round(2)
          resultado_sql_mes_corrente = ActiveRecord::Base.connection.execute(sql_faturamento_mes_atual.sub("?",cliente.id.to_s))
          resultado_sql_semestre = ActiveRecord::Base.connection.execute(sql_faturamento_semestre.sub("?",cliente.id.to_s))

          if resultado_sql_semestre.to_a.blank?
            retorno[cliente.nome_razao_social]["valor_no_semestre"] = 0
            retorno[cliente.nome_razao_social]["valor_no_trimestre"] = 0
          else
            resultado_sql_semestre.each do |valor_semestre|
              p "aqui"
              p valor_semestre
            end
          end
        end

      end
    end
    p "******"
    p retorno
   retorno
  end



  def self.gera_relatorio_faturamento(params)
    parametros_consulta = Relatorio.trata_parametros(params)
    objeto_conjunto_indicador= ConjuntoIndicador.find parametros_consulta[:indicador_id] rescue return []
    conjunto_indicador = (objeto_conjunto_indicador).indicador_valores.group_by(&:tipo)
    numero_de_periodos_anteriores = objeto_conjunto_indicador.numero_minimo_periodos
    clausula_where_date = {}
    unidade_id = parametros_consulta[:unidade_id]

    if objeto_conjunto_indicador.tipo_periodo == ConjuntoIndicador::MENSAL
      data_base_anterior =  Date.today - numero_de_periodos_anteriores.months
      mes_inicio = data_base_anterior.month.to_i
      ano_inicio = data_base_anterior.year.to_i

      mes_corrente = nil

      if parametros_consulta[:mes].blank?
        mes_corrente = (Date.today - 1.month).month.to_i
      else
        mes_corrente = parametros_consulta[:mes].to_i - 1
      end

      if parametros_consulta[:ano].blank?
        ano_corrente = (Date.today.year).to_i
      else
        ano_corrente = parametros_consulta[:ano].to_i
      end


      mes_semestre = 0
      ano_semestre = 0
      if (mes_corrente - 6) < 0
        ano_semestre = ano_corrente - 1
        mes_semestre = (12 + (mes_corrente - 6)) +1 #O mais 1 é pq o 0 conta como mês
      else
        mes_semestre =  mes_corrente - 6
        ano_semestre = ano_corrente
      end

      clausula_where_semestre = {}
      (ano_semestre..ano_corrente).each do |ano|
        clausula_where_semestre[ano]||= []
        if ano < ano_corrente
          mes_semestre.upto(12).each do |mes|
            clausula_where_semestre[ano] << mes
          end
        else
          1.upto(mes_corrente).each do |mes|
            clausula_where_semestre[ano] << mes
          end
        end
      end



      (ano_inicio..ano_corrente).each do |ano|
        clausula_where_date[ano]||= []
        if ano == ano_inicio
          mes_inicio.upto(12).each do |mes|
            clausula_where_date[ano] << mes
          end
        elsif ano < ano_corrente
          1.upto(12).each do |mes|
            clausula_where_date[ano] << mes
          end
        elsif ano == ano_corrente
          1.upto(mes_corrente).each do |mes|
            clausula_where_date[ano] << mes
          end
        end
      end
    end

    hash_frequencia = {}
    hash_valor = {}
    retorno = {}
    conjunto_indicador.each do |indicadores|
      tipo_indicador = indicadores.first
      indicadores.last.each do |indicador|
        operador = indicador.operador

        if tipo_indicador == IndicadorValor::FREQUENCIA
          hash_frequencia[indicador.legenda]||={}
          hash_frequencia[indicador.legenda]["id"] ||= indicador.id
          if operador == IndicadorValor::IGUAL
            hash_frequencia[indicador.legenda]["valor"] ||= ">= #{indicador.frequencia_mimima}"
          elsif operador == IndicadorValor::ENTRE
            hash_frequencia[indicador.legenda]["valor"] ||= "between #{indicador.frequencia_mimima} AND #{indicador.frequencia_maxima}"
          elsif operador == IndicadorValor::NAO_COMPREI_NO_PERIODO
            hash_frequencia[indicador.legenda]["valor"] ||= " = 0"
          end
        elsif tipo_indicador == IndicadorValor::VALOR
          hash_valor[indicador.legenda] ||= {}
          hash_valor[indicador.legenda]["id"] ||= indicador.id
          if operador == IndicadorValor::MAIOR
            hash_valor[indicador.legenda]["valor"] ||= "> #{indicador.valor_minimo}"
          elsif operador == IndicadorValor::MAIOR_OU_IGUAL
            hash_valor[indicador.legenda]["valor"] ||= ">= #{indicador.valor_minimo}"
          elsif operador == IndicadorValor::IGUAL
            hash_valor[indicador.legenda]["valor"] ||= "= #{indicador.valor_minimo}"
          elsif operador == IndicadorValor::ENTRE
            hash_valor[indicador.legenda]["valor"] ||= "between #{indicador.valor_minimo} AND #{indicador.valor_maximo}"
          end
        end
      end
    end
    #MONTANDO CLAUSULA where
    clausula_where = []
    clausula_where_date.each do |parametros|
      ano_where = parametros.first
      mes_inicio_where = parametros.last.min
      mes_final_where = parametros.last.max
      clausula_where << "((ano = #{ano_where} AND mes between #{mes_inicio_where} AND #{mes_final_where}))"
    end

    clausula_where_semestre_sql = []

    clausula_where_semestre.each do |parametros|
      ano_where = parametros.first
      mes_inicio_where = parametros.last.min
      mes_final_where = parametros.last.max
      clausula_where_semestre_sql << "((ano = #{ano_where} AND mes between #{mes_inicio_where} AND #{mes_final_where}))"
    end
    controle_numero_de_clientes = 0
    controle_faturamento = 0
    controle_faturamento_mes_corrente = 0
    p hash_frequencia
    p hash_valor



    hash_frequencia.each do |valores_frequencia|
      indicador_frequencia = valores_frequencia.first
      condicao_frequencia = valores_frequencia.last["valor"]
      id_indicador_frequencia = valores_frequencia.last["id"]
      hash_valor.each do |valores|

        indicador_valor = valores.first
        condicao_valor = valores.last["valor"]
        id_indicador_valor = valores.last["id"]
        retorno["#{indicador_frequencia}#{indicador_valor}"] ||= {}
        sql = nil
        sql_faturamento_mes_atual = nil
        sql_faturamento_semestre = nil

        if unidade_id.blank?
          sql = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where #{clausula_where.join(" OR ")}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_mes_atual = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where mes = #{Date.today.month} and ano = #{Date.today.year}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_semestre = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where #{clausula_where_semestre_sql.join(" OR ")}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

        else
          sql = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where (#{clausula_where.join(" OR ")}) AND unidade_id = #{unidade_id}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_semestre = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where (#{clausula_where_semestre_sql.join(" OR ")}) AND unidade_id = #{unidade_id}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"

          sql_faturamento_mes_atual = "SELECT count(*) AS FREQUENCIA_DE_COMPRA_NO_PERIODO,cliente_id AS CLIENTE,SUM(valor_comprado_no_mes) AS VALOR_COMPRA from relatorio_frequencia_valores
               where mes = #{Date.today.month} and ano = #{Date.today.year} AND unidade_id = #{unidade_id}
               GROUP BY cliente_id
               HAVING count(*) #{condicao_frequencia} AND (SUM(valor_comprado_no_mes) / #{numero_de_periodos_anteriores} #{condicao_valor})"


        end
        resultado_sql = ActiveRecord::Base.connection.execute(sql)
        resultado_sql_mes_corrente = ActiveRecord::Base.connection.execute(sql_faturamento_mes_atual)
        resultado_sql_semestre = ActiveRecord::Base.connection.execute(sql_faturamento_semestre)

        valor_total_comprado = resultado_sql.inject(0) {|sum, hash| sum + hash["valor_compra"].to_f}
        controle_faturamento += valor_total_comprado.round(2)
        numero_de_clientes_na_carteira = resultado_sql.inject(0) {|sum, hash| sum + 1}

        valor_total_comprado_semestre = resultado_sql_semestre.inject(0) {|sum, hash| sum + hash["valor_compra"].to_f}
        valor_total_comprado_mes_corrente = resultado_sql_mes_corrente.inject(0) {|sum, hash| sum + hash["valor_compra"].to_f}
        numero_de_clientes_na_carteira_mes_corrente = resultado_sql_mes_corrente.inject(0) {|sum, hash| sum + 1}
        controle_numero_de_clientes += numero_de_clientes_na_carteira
        controle_faturamento_mes_corrente += valor_total_comprado_mes_corrente
        critico = numero_de_clientes_na_carteira - numero_de_clientes_na_carteira_mes_corrente

        #Coluna Valor no Periodo
        retorno["#{indicador_frequencia}#{indicador_valor}"]["id_conjunto_indicador"] = objeto_conjunto_indicador.id
        retorno["#{indicador_frequencia}#{indicador_valor}"]["id_indicador_frequencia"] = id_indicador_frequencia
        retorno["#{indicador_frequencia}#{indicador_valor}"]["id_indicador_valor"] = id_indicador_valor

        retorno["#{indicador_frequencia}#{indicador_valor}"]["total_comprado"] =  valor_total_comprado.round(2)
        #Coluna Média no Período
        retorno["#{indicador_frequencia}#{indicador_valor}"]["media_no_periodo"] = (valor_total_comprado.to_f / numero_de_periodos_anteriores).round(2)
        #Coluna Tot.Cliente
        retorno["#{indicador_frequencia}#{indicador_valor}"]["numero_de_clientes"] = numero_de_clientes_na_carteira
        retorno["#{indicador_frequencia}#{indicador_valor}"]["critico"] = critico
        retorno["#{indicador_frequencia}#{indicador_valor}"]["total_comprado_mes_corrente"] = valor_total_comprado_mes_corrente
        retorno["#{indicador_frequencia}#{indicador_valor}"]["total_comprado_semestre"] = valor_total_comprado_semestre.round(2)
        retorno["#{indicador_frequencia}#{indicador_valor}"]["porcentagem_clientes"] = 0
        retorno["#{indicador_frequencia}#{indicador_valor}"]["porcentagem_faturamento"] = 0




      end
    end

    hash_frequencia.each do |valores_frequencia|
      indicador_frequencia = valores_frequencia.first
      condicao_frequencia = valores_frequencia.last["valor"]

      hash_valor.each do |valores|
        indicador_valor = valores.first
        condicao_valor = valores.last["valor"]
        retorno["#{indicador_frequencia}#{indicador_valor}"]["porcentagem_clientes"] = ((retorno["#{indicador_frequencia}#{indicador_valor}"]["numero_de_clientes"].to_f/controle_numero_de_clientes)*100).round(2)
        retorno["#{indicador_frequencia}#{indicador_valor}"]["porcentagem_faturamento"] = ((retorno["#{indicador_frequencia}#{indicador_valor}"]["total_comprado"]/controle_faturamento)*100).round(2)
      end
    end

    retorno["medias"] ||={}
    retorno["medias"]["valor_no_periodo"] ||= (((controle_faturamento)/numero_de_periodos_anteriores)/100.0).round(2)
    retorno["medias"]["valor_faturado_mes_corrente"] ||= (controle_faturamento_mes_corrente).round(2)
    retorno
  end


end

