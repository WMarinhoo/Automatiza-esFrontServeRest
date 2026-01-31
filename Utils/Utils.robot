*** Settings ***
Library                 SeleniumLibrary
Library                 Collections
Library                 String
Library                 Libraries/RPA_Utils.py
Library                 DateTime
Library                 DatabaseLibrary
Library                 OperatingSystem
Library                 RequestsLibrary
Library                 RPA.Excel.Files
Library                 RPA.JSON
Library                 RPA.Tables
Library                 RPA.PDF
Library                 XML
Library                 RPA.FTP
Library                 FakerLibrary


*** Variables ***
${TIMEOUT}                        20

*** Keywords ***

Seleciona Frame
  [Arguments]                      ${NOME}
  Wait Until Element Is Visible    ${FRAME${NOME}}
  Select Frame                     ${FRAME${NOME}}

Retorna DIA_MES_ANO
  [Arguments]    ${NOME}
  ${DATA_HOJE}                              Get Current Date                  result_format=datetime
  ${NOME}=                                  Gera Frase Em String              ${NOME}
  IF    '${NOME}' == 'DIA'
      ${DATA}                              Convert Date                      ${DATA_HOJE}                    result_format=%d
  ELSE IF    '${NOME}' == 'MES'
      ${DATA}                              Convert Date                      ${DATA_HOJE}                    result_format=%m
    ELSE IF  '${NOME}' == 'ANO'
      ${DATA}                              Convert Date                      ${DATA_HOJE}                    result_format=%Y
  ELSE IF  '${NOME}' == 'HORA'
      ${DATA}                              Convert Date                      ${DATA_HOJE}                    result_format=%H
  ELSE IF  '${NOME}' == 'MIN'
      ${DATA}                              Convert Date                      ${DATA_HOJE}                    result_format=%M
  ELSE IF  '${NOME}' == 'SEG'
      ${DATA}                              Convert Date                      ${DATA_HOJE}                    result_format=%S
  
  END
    
  RETURN    ${DATA}

Conectar no Banco de Dados
  [Arguments]           ${DADOS}
  ${TIPO_BANCO}=        Convert To Upper Case  ${DADOS.TIPO_BD}

  IF  "${TIPO_BANCO}" == "ORACLE"
    ${TIPO_BANCO}=  Set Variable  cx_Oracle
  ELSE IF  "${TIPO_BANCO}" == "POSTGRESQL"
    ${TIPO_BANCO}=  Set Variable  psycopg2
  ELSE IF  "${TIPO_BANCO}" == "SQLSERVER"
    ${TIPO_BANCO}=  Set Variable  pyodbc
  ELSE IF  "${TIPO_BANCO}" == "MYSQL"
    ${TIPO_BANCO}=  Set Variable  pymysql
  END
  
  Connect To Database   ${TIPO_BANCO}   dbName=${DADOS}[DATABASE]   dbUsername=${DADOS}[USER]   dbPassword=${DADOS}[PASS]  dbHost=${DADOS}[HOST]   dbPort=${DADOS}[PORT]

Desconectar do Banco de Dados
  Disconnect From Database

Executar SQL
  [Arguments]          ${SCRIPT}
  Execute SQL String   sqlString=${SCRIPT}

Busca dados de conexão do Banco de dados
  [Documentation]            Esta keyword busca os dados de conexão na planilha quando lhe é passado o ambiente, retornando um dicionário
  [Arguments]                ${planilha}                     ${ambiente}
  ${ambiente}=               Gera Frase Em String            ${ambiente}
  ${CREDENCIAIS_BD}          Create Dictionary        
  ...                        HOST=${planilha}[BD_HOST_${ambiente}]
  ...                        DATABASE=${planilha}[BD_DATABASE_${ambiente}]
  ...                        USER=${planilha}[BD_USER_${ambiente}]
  ...                        PASS=${planilha}[BD_PASS_${ambiente}]
  ...                        PORT=${planilha}[BD_PORT_${ambiente}]  
  ...                        TIPO_BD=${planilha}[TIPO_BD_${ambiente}]
  RETURN                     ${CREDENCIAIS_BD}


Ler planilha de dados
  [Documentation]    Faz a leitura da planilha de dados, em orientação como linhas ou colunas, escolhe randomicamente 
  ...                qual linha será usada e retorna ela. Parametros: 
  ...                \\\${dados} - [Obrigatório] -> caminho da planilha
  ...                \\\${nome_aba} - [não obrigatório] -> valor default = '(vazio)' -> o nome da aba (caso não seja informado, pega a última caso tenha mais de uma ou a única). 
  ...                \\\${header} - [não obrigatório] -> valor default = 'True' -> cabeçalho - valor 'True' ou '1' retorna dados com cabeçalho, 'False' ou '0' restorna sem ele.
  ...                \\\${coluna} - [não obrigatório] -> valor default = 'linha' -> se a leitura da planilha deve ser considerando que ela esta orientada em linhas ou coluna
  
  [Arguments]      ${dados}                 ${nome_aba}=                ${header}=${True}        ${coluna}=${False}
  ${planilha}=     Preparando a planilha    ${dados}                    ${nome_aba}              ${header}
  ${linhas}        ${colunas}               Get Table Dimensions        ${planilha}
  #se vier linha, trata dessa forma, se vier coluna, tenho de converter 0:A, 1:B e mudar o random para ${coluna - 1}
  IF    ${coluna} is $False
    ${interessado}=                         Sorteia Numero                  0                        ${linhas-1}
    ${index} =                              Set Variable                -1
    FOR   ${linha}  IN  @{planilha}
      ${index} =                            Evaluate                    ${index} + 1
      IF    ${index} == ${interessado}
        RETURN        ${linha}
      END
    END
  ELSE
  IF    ${colunas} == 2
      ${CONVERTIDA}=                          Converte Planilha Em Dicionario    ${planilha}         ${colunas}
      RETURN         ${CONVERTIDA}
  ELSE IF    ${colunas} > 2
      ${interessado}=                         Sorteia Numero                  2                          ${colunas}
      ${CONVERTIDA}=                          Converte Planilha Em Dicionario    ${planilha}         ${interessado}
      RETURN         ${CONVERTIDA}
  END
  END
  

Preparando a planilha
  [Arguments]         ${local_planilha}        ${nome_aba}=        ${header}=True
  Open Workbook       ${local_planilha}   
  IF    '${nome_aba}' == ''
    ${planilha}=        Read Worksheet As Table    header=${header}
  ELSE
    ${nome_aba}=        Gera Frase Em String       ${nome_aba}      _
    ${planilha}=        Read Worksheet As Table    header=${header}        name=${nome_aba}
  END
  Close Workbook
  RETURN              ${planilha}


Gerar o token Swagger
  [Documentation]    Gera o token via 'CURL' do tipo BEARER para completar o header de conexão. Retorna a string 
  ...                pronta como exemplo "Bearer ¨54Fhgt%$$...kGHyvHVYTfrtDGcfdr¨". Recebe como parametro a URL
  [Arguments]        ${URL_TOKEN}
  ${json_string}=                               Run                                   ${URL_TOKEN}
  ${json}=                                      Convert String to JSON                ${json_string}
  ${access_token}=                              Set Variable                          Bearer ${json["access_token"]}
  Log                                           ${access_token}
  RETURN                                        ${access_token}

Criar Sessão na API Swagger
  [Documentation]    Cria a sessão para o começo da operação com a API
  [Arguments]        ${URL_SERVICE}           ${URL_TOKEN}                       ${NOME_CONEXAO}        
  ${AUTENTICACAO}=                            Gerar o token Swagger              ${URL_TOKEN}
  ${headers}                                  Create Dictionary                  content-type=application/json;charset=UTF-8         authorization=${AUTENTICACAO}
  Create Session                              alias=${NOME_CONEXAO}              url=${URL_SERVICE}                      headers=${headers}


Envia JSON
  [Arguments]                ${JSON}        ${NOME_CONEXAO}        ${URL}    ${STATUS_ESPERADO}    ${OPERACAO}=
  
  ${resposta}                                 POST On Session
  ...                                         alias=${NOME_CONEXAO}
  ...                                         url=${URL}
  ...                                         json=${JSON}
  ...                                         expected_status=any

  Trata retorno JSON        ${resposta}    ${OPERACAO}



Monta Json Transito AGERBA
  [Arguments]        ${planilha}
  ${PARCELAMENTOS}                                Create Dictionary      
  ...         nuParcela= ${planilha}[NUPARCELA]
  ...         dtVencimento= ${planilha}[DTVENCIMENTO]
  ...         dtVencimentoOriginal= ${planilha}[DTVENCIMENTOORIGINAL]
  ...         vlOriginal= ${planilha}[VLORIGINAL]
  ...         vlJuros= ${planilha}[VLJUROS]
  ...         vlIndice= ${planilha}[VLINDICE]
  ...         vlFinal= ${planilha}[VLFINAL]
  ...         vlFinalAtualizado= ${planilha}[VLFINALATUALIZADO]
  ...         vlFinalAtualizadoHoje= ${planilha}[VLFINALATUALIZADOHOJE]
  ...         dtPagamento= ${planilha}[DTPAGAMENTO]
  ...         nuBoletoDAE= ${planilha}[NUBOLETODAE]
  ...         deObservacaoBoleto= ${planilha}[DEOBSERVACAOBOLETO]
  ...         nuRefparcela= ${planilha}[NUREFPARCELA]
  ...         dtVencto= ${planilha}[DTVENCTO]
  ...         dtVenctoOriginal= ${planilha}[DTVENCTOORIGINAL]
  ...         deParcela= ${planilha}[DEPARCELA]
  ...         vlMulta= ${planilha}[VLMULTA]
  ...         vlParcela= ${planilha}[VLPARCELA]
  ...         flCndObrigatorio= ${planilha}[FLCNDOBRIGATORIO]
  ...         vlTotal= ${planilha}[VLTOTAL]
  ...         vlTotalAtual= ${planilha}[VLTOTALATUAL]
  
  ${DADOS}                                           Create Dictionary
  ...         cdGrupo = ${planilha}[CDGRUPO]
  ...         cdIndiceParcela = ${planilha}[CDINDICEPARCELA]
  ...         cdServico = ${planilha}[CDSERVICO]
  ...         cdSujeito = ${planilha}[CDSUJEITO]
  ...         dtPrimeiroVencimento = ${planilha}[DTPRIMEIROVENCIMENTO]
  ...         dtContareceber = ${planilha}[DTCONTARECEBER]
  ...         vlPercentualJuros = ${planilha}[VLPERCENTUALJUROS]
  ...         nuSituacaocr = ${planilha}[NUSITUACAOCR]
  ...         cdOrgaosetor = ${planilha}[CDORGAOSETOR]
  ...         nuAutoinfracao = ${planilha}[NUAUTOINFRACAO]
  ...         nuTiporeceita = ${planilha}[NUTIPORECEITA]
  ...         vlLiquido = ${planilha}[VLLIQUIDO]
  ...         vlTotalAtual = ${planilha}[FLJUROSPARCELA1]
  
  ${LISTA}                                            Create List    
  ...         ${PARCELAMENTOS}
  
  ${JSON_MULTA}                                        Create Dictionary    
  ...                                                  ${DADOS}
  ...                                                  parcelamentos=${PARCELAMENTOS}
  
  Log                                                  ${JSON_MULTA}
  RETURN                                               ${JSON_MULTA}

Monta JSOn Transito DERMG
  [Arguments]        ${planilha}
  ${NUMEROPROCESSO}=    GerarNumero    8

  ${MONTAAUDITINFO}                                Create Dictionary
    ...    cdSistema=${planilha}[CDSISTEMA]
    ...    cdUsuario=${planilha}[CDUSUARIO]
    ...    nmForm=${planilha}[NMFORM]      

  ${MONTADADOSASEREMIMPORTADOS}                    Create Dictionary
    ...    auditInfo=${MONTAAUDITINFO}
    ...    cdInfracao=${planilha}[CDINFRACAO]
    ...    cdMunicipio=${planilha}[CDMUNICIPIO]
    ...    cdSerie=${planilha}[CDSERIE]
    ...    nuAutoInfracao=${planilha}[NUAUTOINFRACAO]
    # ...    cdSujeito=${planilha}[CDSUJEITO]
    ...    nuCpfCnpj=${planilha}[NUCPFCNPJ]
    ...    nmProprietario=${planilha}[NMPROPRIETARIO]
    ...    deLocal=${planilha}[DELOCAL]
    ...    nuRenavam=${planilha}[NURENAVAM]
    ...    dePlaca=${planilha}[DEPLACA]
    ...    sgUfPlaca=${planilha}[SGUFPLACA]
    ...    dtInfracao=${planilha}[DTINFRACAO]
    ...    dtVencimento=${planilha}[DTVENCIMENTO]
    ...    dtNotificaoPenalidade=${planilha}[DTNOTIFICAOPENALIDADE]
    ...    nmMunicipio=${planilha}[NMMUNICIPIO]
    ...    nmRua=${planilha}[NMRUA]
    ...    nmBairro=${planilha}[NMBAIRRO]
    ...    nuCep=${planilha}[NUCEP]
    ...    nuEndereco=${planilha}[NUENDERECO]
    ...    sgUfMunicipio=${planilha}[SGUFMUNICIPIO]
    ...    tipoInfracao=${planilha}[TIPOINFRACAO]
    ...    tpProprietario=${planilha}[TPPROPRIETARIO]
    ...    vlInfracao=${planilha}[VLINFRACAO]
    ...    nuProcessamento=${NUMEROPROCESSO}
  
  ${DADOS}                                             Create List
  ...    ${MONTADADOSASEREMIMPORTADOS}

  ${JSON_MULTA}                                        Create Dictionary
    ...    auditInfo=${MONTAAUDITINFO}
    ...    dadosASeremImportados=${DADOS}
      
  Log                                                  ${JSON_MULTA}
  RETURN                                               ${JSON_MULTA}

Monta Json Consulta Conta a Receber DERMG
    [Arguments]        ${DADOS}
    ${JSON}            Create Dictionary
    ...                anoContaReceber=${DADOS}[anoContaReceber]
    ...                numeroAutoInfracao=${DADOS}[numeroAutoInfracao]
    ...                numeroContaReceber=${DADOS}[numeroContaReceber]
      
  Log                  ${JSON}
  RETURN               ${JSON}


Monta Json Cancelamento Conta a Receber DERMG
    [Arguments]        ${DADOS}
    ${JSON}            Create Dictionary
    ...                anoContaReceber=${DADOS}[anoContaReceber]
    ...                numeroAutoInfracao=${DADOS}[numeroAutoInfracao]
    ...                numeroContaReceber=${DADOS}[numeroContaReceber]
    ...                cdMotivocancelamento=${DADOS}[cdMotivocancelamento]
    ...                motivoCancelamento=${DADOS}[motivoCancelamento]  
  
  
  Log                  ${JSON}
  RETURN               ${JSON}



Monta JSOn Transporte DERMG
  [Arguments]        ${planilha}
  ${JSON_MULTA}                                        Create Dictionary
  ...  numeroAutoInfracao=${planilha}[NUMEROAUTOINFRACAO]
  ...  numeroDocumento=${planilha}[NUMERODOCUMENTO]
  ...  nomeCompleto=${planilha}[NOMECOMPLETO]
  ...  dataAutuacao=${planilha}[DATAAUTUACAO]
  ...  valorAutoInfracao=${planilha}[VALORAUTOINFRACAO]
  ...  dtcontareceber=${planilha}[DTCONTARECEBER]
  ...  dataVencimento=${planilha}[DATAVENCIMENTO]
  ...  dataNotificacao=${planilha}[DATANOTIFICACAO]
  ...  localInfracao=${planilha}[LOCALINFRACAO]
  ...  penalidade=${planilha}[PENALIDADE]
  ...  tipoDocumento=${planilha}[TIPODOCUMENTO]
  ...  logradouro=${planilha}[LOGRADOURO]
  ...  numero=${planilha}[NUMERO]
  ...  complemento=${planilha}[COMPLEMENTO]
  ...  bairro=${planilha}[BAIRRO]
  ...  codigoMunicipio=${planilha}[CODIGOMUNICIPIO]
  ...  nomeMunicipio=${planilha}[NOMEMUNICIPIO]
  ...  ufMunicipio=${planilha}[UFMUNICIPIO]
  ...  cep=${planilha}[CEP]
  ...  telefone=${planilha}[TELEFONE]
  ...  placa=${planilha}[PLACA]
  ...  tipo=${planilha}[TIPO]
  ...  codigoDelegatario=${planilha}[CODIGODELEGATARIO]
  ...  numeroLinha=${planilha}[NUMEROLINHA]
  ...  numeroPermissao=${planilha}[NUMEROPERMISSAO]
      
  Log                                                  ${JSON_MULTA}
  RETURN                                               ${JSON_MULTA}

Montando JSOn GRU DERMG
  [Arguments]        ${planilha}

  ${MONTAAUDITINFO}                                Create Dictionary
    ...    cdSistema=${planilha}[CDSISTEMA]
    ...    cdUsuario=${planilha}[CDUSUARIO]
    ...    nmForm=${planilha}[NMFORM]      

  ${MONTADADOSASEREMIMPORTADOS}                                Create Dictionary  
    ...    deObservacaoBoleto=${planilha}[DEOBSERVACAOBOLETO]
    ...    nuAnoContaReceber=${planilha}[NUANOCONTARECEBER]
    ...    nuContaReceber=${planilha}[NUCONTARECEBER]
    ...    nuParcelamento=${planilha}[NUPARCELAMENTO]
  
  ${DADOS}                                             Create List
  ...    ${MONTADADOSASEREMIMPORTADOS}

  ${JSON_MULTA}                                        Create Dictionary
    ...    auditInfo=${MONTAAUDITINFO}
    ...    parcelamentos=${DADOS}
      
  Log                                                  ${JSON_MULTA}
  RETURN                                               ${JSON_MULTA}



Montando Json Criação Boleto BANRISUL
    [Arguments]        ${DADOS}

    ${PAGADOR}                                              Create Dictionary   
    ...    tipo_pessoa=${DADOS}[TIPO_PESSOA_PAGADOR]
    ...    cpf_cnpj=${DADOS}[CPF_CNPJ_PAGADOR]
    ...    nome=${DADOS}[NOME_PAGADOR]
    ...    endereco=${DADOS}[ENDERECO_PAGADOR]
    ...    cep=${DADOS}[CEP_PAGADOR]
    ...    cidade=${DADOS}[CIDADE_PAGADOR]
    ...    uf=${DADOS}[UF_PAGADOR]
    ...    aceite=${DADOS}[ACEITE_PAGADOR]

    ${JUROS}                                                Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_JUROS]
    ...    data=${DADOS}[DATA_JUROS]
    ...    valor=${DADOS}[VALOR_JUROS]
    ...    taxa=${DADOS}[TAXA_JUROS]
    
    ${MULTA}                                                Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_MULTA]
    ...    data=${DADOS}[DATA_MULTA]
    ...    valor=${DADOS}[VALOR_MULTA]
    ...    taxa=${DADOS}[TAXA_MULTA]
        
    ${DESCONTO}                                             Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_DESCONTO]
    ...    data=${DADOS}[DATA_DESCONTO]
    ...    valor=${DADOS}[VALOR_DESCONTO]
    ...    taxa=${DADOS}[TAXA_DESCONTO]
    
    ${ABATIMENTO}                                           Create Dictionary   
    ...    valor=${DADOS}[VALOR_ABATIMENTO]

    ${PROTESTO}                                             Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_PROTESTO]
    ...    prazo=${DADOS}[PRAZO_PROTESTO]
    
    ${BAIXA}                                                Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_BAIXA]
    ...    prazo=${DADOS}[PRAZO_BAIXA]

    ${INSTRUCOES}                                           Create Dictionary   
    ...    juros=${JUROS}
    ...    multa=${MULTA}
    ...    desconto=${DESCONTO} 
    ...    abatimento=${ABATIMENTO}
    ...    protesto=${PROTESTO} 
    ...    baixa=${BAIXA}

    ${PAG_PARCIAL}                                          Create Dictionary   
    ...    autoriza=${DADOS}[AUTORIZA_PAG_PARCIAL]
    ...    codigo=${DADOS}[CODIGO_PAG_PARCIAL]
    ...    quantidade=${DADOS}[QUANTIDADE_PAG_PARCIAL]
    ...    tipo=${DADOS}[TIPO_PAG_PARCIAL]
    ...    valor_min=${DADOS}[VALOR_MIN_PAG_PARCIAL]
    ...    valor_max=${DADOS}[VALOR_MAX_PAG_PARCIAL]
    ...    percentual_min=${DADOS}[PERCENTUAL_MIN_PAG_PARCIAL]
    ...    percentual_max=${DADOS}[PERCENTUAL_MAX_PAG_PARCIAL]
    
    ${MENSAGEM}                                             Create Dictionary   
    ...    linha=${DADOS}[LINHA_MENSAGEM]
    ...    texto=${DADOS}[TEXTO_MENSAGEM]
    
    ${MENSAGENS}                                            Create List   
    ...    ${MENSAGEM}
        
    ${BENEFICIARIO}                                         Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_BENEFICIARIO]
    ...    tipo_pessoa=${DADOS}[TIPO_PESSOA_BENEFICIARIO]
    ...    cpf_cnpj=${DADOS}[CPF_CNPJ_BENEFICIARIO]
    ...    nome=${DADOS}[NOME_BENEFICIARIO]
    ...    nome_fantasia=${DADOS}[NOME_FANTASIA_BENEFICIARIO]
    ...    valor=${DADOS}[VALOR_BENEFICIARIO]
    ...    percentual=${DADOS}[PERCENTUAL_BENEFICIARIO]
    ...    parcela=${DADOS}[PARCELA_BENEFICIARIO]
    
    ${BENEFICIARIOS}                                        Create List   
    ...    ${BENEFICIARIO}
    
    ${RATEIO}                                               Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_RATEIO]
    ...    tipo_valor=${DADOS}[TIPO_VALOR_RATEIO]
    ...    beneficiarios=${BENEFICIARIOS}
    
    ${HIBRIDO}                                              Create Dictionary   
    ...    autoriza=${DADOS}[AUTORIZA_HIBRIDO]
    ...    situacao=${DADOS}[SITUACAO_HIBRIDO]
    ...    txid=${DADOS}[TXID_HIBRIDO]
    ...    location=${DADOS}[LOCATION_HIBRIDO]
    ...    copia_cola=${DADOS}[COPIA_COLA_HIBRIDO]

    ${TITULO}                                               Create Dictionary    
    ...    nosso_numero=${DADOS}[NOSSO_NUMERO_TITULO]
    ...    seu_numero=${DADOS}[SEU_NUMERO_TITULO]
    ...    data_vencimento=${DADOS}[DATA_VENCIMENTO_TITULO]
    ...    valor_nominal=${DADOS}[VALOR_NOMINAL_TITULO]
    ...    especie=${DADOS}[ESPECIE_TITULO]
    ...    data_emissao=${DADOS}[DATA_EMISSAO_TITULO]
    ...    valor_iof=${DADOS}[VALOR_IOF_TITULO]
    ...    id_titulo_empresa=${DADOS}[ID_TITULO_EMPRESA_TITULO]
    ...    pagador=${PAGADOR}
    ...    instrucoes=${INSTRUCOES}
    ...    pag_parcial=${PAG_PARCIAL}
    ...    mensagens=${MENSAGENS}
    ...    rateio=${RATEIO}
    ...    hibrido=${HIBRIDO}

    

    ${CRIACAO_BOLETO}                                        Create Dictionary
    ...    ambiente='T'
    ...    titulo=${TITULO}
      
  Log                                                  ${CRIACAO_BOLETO}
  RETURN                                               ${CRIACAO_BOLETO}


Monta Json Baixa Boleto BANRISUL
    [Arguments]        ${DADOS}

    ${BENEFICIARIO}                                         Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_BENEFICIARIO]
    ...    tipo_pessoa=${DADOS}[TIPO_PESSOA_BENEFICIARIO]
    ...    cpf_cnpj=${DADOS}[CPF_CNPJ_BENEFICIARIO]
    ...    nome=${DADOS}[NOME_BENEFICIARIO]
    ...    nome_fantasia=${DADOS}[NOME_FANTASIA_BENEFICIARIO]
    
    ${PAGADOR}                                              Create Dictionary   
    ...    tipo_pessoa=${DADOS}[TIPO_PESSOA_PAGADOR]
    ...    cpf_cnpj=${DADOS}[CPF_CNPJ_PAGADOR]
    ...    nome=${DADOS}[NOME_PAGADOR]
    ...    endereco=${DADOS}[ENDERECO_PAGADOR]
    ...    cep=${DADOS}[CEP_PAGADOR]
    ...    cidade=${DADOS}[CIDADE_PAGADOR]
    ...    uf=${DADOS}[UF_PAGADOR]
    ...    aceite=${DADOS}[ACEITE_PAGADOR]
    
    ${JUROS}                                                Create Dictionary   
    ...    codigo=${DADOS}[CODIGO_JUROS]

    ${INSTRUCOES}                                           Create Dictionary   
    ...    juros=${JUROS}
    
    ${PAG_PARCIAL}                                          Create Dictionary   
    ...    autoriza=${DADOS}[AUTORIZA_PAG_PARCIAL]
    ...    codigo=${DADOS}[CODIGO_PAG_PARCIAL]

    ${TITULO}                                               Create Dictionary    
    ...    nosso_numero=${DADOS}[NOSSO_NUMERO_TITULO]
    ...    seu_numero=${DADOS}[SEU_NUMERO_TITULO]
    ...    data_vencimento=${DADOS}[DATA_VENCIMENTO_TITULO]
    ...    valor_nominal=${DADOS}[VALOR_NOMINAL_TITULO]
    ...    especie=${DADOS}[ESPECIE_TITULO]
    ...    data_emissao=${DADOS}[DATA_EMISSAO_TITULO]
    ...    id_titulo_empresa=${DADOS}[ID_TITULO_EMPRESA_TITULO]
    ...    codigo_barras=${DADOS}[CODIGO_BARRAS_EMPRESA_TITULO]
    ...    linha_digitavel=${DADOS}[LINHA_DIGITAVEL_TITULO]
    ...    beneficiario=${BENEFICIARIO}
    ...    pagador=${PAGADOR}
    ...    instrucoes=${INSTRUCOES}
    ...    pag_parcial=${PAG_PARCIAL}

    

    ${BAIXA_BOLETO}                                        Create Dictionary
    ...    retorno='04'
    ...    titulo=${TITULO}
      
  Log                                                  ${BAIXA_BOLETO}
  RETURN                                               ${BAIXA_BOLETO}
    
Popula Planilha de geração do GRU
  [Documentation]            Após a criação da CR, insere uma linha na planilha para que o GRU crie o boleto/DAE
  [Arguments]                ${CONTA_RECEBER}        ${ANO_CONTA_RECEBER}      ${NUPARCELAMENTO}        ${PLANILHA}
  ${CDSISTEMA}               Set Variable            346
  ${CDUSUARIO}               Set Variable            SIDERWEB
  ${NMFORM}                  Set Variable            /rec/salvarCadConfigJurosReceitasVencidas
  ${DEOBSERVACAOBOLETO}      Set Variable            Criado via automação de testes - QA
  ${DADOS}                   Create Dictionary       
  ...                        CDSISTEMA=${CDSISTEMA}
  ...                        CDUSUARIO=${CDUSUARIO}
  ...                        NMFORM=${NMFORM}
  ...                        DEOBSERVACAOBOLETO=${DEOBSERVACAOBOLETO}
  ...                        NUANOCONTARECEBER=${ANO_CONTA_RECEBER}
  ...                        NUCONTARECEBER=${CONTA_RECEBER}
  ...                        NUPARCELAMENTO=${NUPARCELAMENTO}
  Open Workbook              ${PLANILHA}
  Append Rows To Worksheet   ${DADOS}                header=${True}
  Save Workbook
  Close Workbook

Cria a planilha
    [Documentation]        Criar uma planilha por cliente para evitar lentidão
    [Arguments]                                        ${nome}
    Create Workbook                                    ${CURDIR}/${nome}.xlsx    sheet_name=${nome}
    Save Workbook
    Close Workbook

Pegar credenciais BD e conecta
    [Arguments]                                        ${nome}
    ${planilha}=                                       Ler planilha de dados                                    ${login_${nome}}               header=${False}             coluna=${True}
    ${dados_bd}=                                       Busca dados de conexão do Banco de dados                 ${planilha}            DES
    Conectar no Banco de Dados                         ${dados_bd}


Salva dados no Excel
    [Documentation]        Salva linha a linha, fechando a planilha para evitar sujeira no cache e consumo 
    ...                    desnecessário de memória
                            
    [Arguments]                                        ${dados}        ${nome}        ${nome_aba}=
    Open Workbook                                      ${nome}
    IF    '${nome_aba}' == ''
        Append Rows To Worksheet                           ${dados}                                   header=${True}
    ELSE
        Append Rows To Worksheet                           ${dados}                                   header=${True}            name=${nome_aba}
    END
    
    Save Workbook
    Close Workbook

Cria dicionário para enviar ao Excel
    [Arguments]                                        ${sistema}                ${menu}                ${tela}         ${aba}
    ${dicionario}                                      Create Dictionary            
    ...                                                SISTEMA=${sistema}
    ...                                                MENU=${menu}
    ...                                                TELA=${tela}
    ...                                                BDD=
    ...                                                ROBOT=
    
    Salva dados no Excel                               ${dicionario}        ${aba}
    Log To Console                                     Salvando o Registro ${aba} > ${sistema} > ${menu} > ${tela}


Deleta linha da planilha
  [Arguments]                                        ${nome}                ${linha}        ${nome_aba}=
  Open Workbook                                      ${nome}     
  IF    '${nome_aba}' == ''
    Delete Rows                                        ${linha}
  ELSE
    Delete Rows                                        ${linha}                                   header=${True}            
    # Delete Rows                                        ${linha}                                   header=${True}            name=${nome_aba}
  END     
  Save Workbook
  Close Workbook

Retorna sequencia
    [Documentation]    Esta keyword tem a função de retornar uma sequencia do caracter informado ou espaço, de acordo com os parametros:
    ...                ${QTD} - indica a quantidade de vezes que o ${ITEM} será repetido na variável de retorno
    ...                ${ITEM}  - [não obrigatório] -indica o numero/letra/caracter/sequência que que será repetido ou caso vazia será repetido o ${SPACE}
    
    [Arguments]        ${QTD}       ${ITEM}=
    IF    '${QTD}' != ''
        ${VALOR}        Set Variable
        FOR    ${counter}    IN RANGE    0    ${QTD}
            IF    '${ITEM}' == ''
                ${VALOR}        Set Variable    ${SPACE}${VALOR}
            ELSE
                ${VALOR}        Set Variable    ${VALOR}${ITEM}
            END
            
        END                    
        RETURN        ${VALOR}
    ELSE
        RETURN        ERROR QTD VAZIA
    END

Normatiza no tamanho certo
    [Arguments]    ${ITEM}        ${TAMANHO}    ${COMPLETA}        ${LADO}
    ${ITEM}         Convert To String    ${ITEM}
    Log            ${ITEM}
    ${QTD}         Get Length    ${ITEM}
    ${QTD}         Evaluate      ${TAMANHO} - ${QTD}
    IF    '${COMPLETA}' == 'None'
        ${VALOR}            Retorna sequencia    ${QTD}
    ELSE
        ${VALOR}            Retorna sequencia    ${QTD}        ${COMPLETA}
    END                
    IF    '${LADO}' == 'E'
        ${VALOR}        Set Variable    ${VALOR}${ITEM}
    ELSE
        ${VALOR}        Set Variable    ${ITEM}${VALOR}    
    END
    RETURN        ${VALOR}
  
Enviar arquivo para o FTP
    [Arguments]        ${DADOS_LOGIN}                 ${NOME_ARQUIVO}        ${LOCAL_ARQUIVO}
    ${LOGIN}           Ler planilha de dados          ${DADOS_LOGIN}         header=${False}                    coluna=${True}
    Connect        ${LOGIN}[HOST_FTP_${LOGIN}[AMBIENTE]]    ${LOGIN}[PORTA_FTP_${LOGIN}[AMBIENTE]]    ${LOGIN}[USER_FTP_${LOGIN}[AMBIENTE]]    ${LOGIN}[SENHA_FTP_${LOGIN}[AMBIENTE]]
    Cwd            ${LOGIN}[DIRETORIO_FTP_${LOGIN}[AMBIENTE]] 
    Upload         ${LOCAL_ARQUIVO}/${NOME_ARQUIVO}       ${NOME_ARQUIVO}

Trata retorno JSON
    [Arguments]        ${JSON}        ${OPERACAO}=
    ${OPERACAO}        Gera Frase Em String    ${OPERACAO}
    
    IF    '${JSON}' == '<Response [200]>'
        IF    '${OPERACAO}' == 'TRANSITO'
            ${TESTE}=    Get From Dictionary    ${JSON}    key=multasInseridasComSucesso        default=${False}
            ${DICIONARIO}    Convert To Dictionary   ${TESTE}[0]
            Log To Console    \nGerada a CR ${DICIONARIO}[nuContaReceber]/${DICIONARIO}[nuAnoContaReceber]
        ELSE IF    '${OPERACAO}' == 'CANCELAR'
            Log To Console    \nConta a receber cancelada
        ELSE
            Log                                          ${JSON.json()} 
        END
    ELSE IF    '${JSON}' == '<Response [201]>'
        IF    '${OPERACAO}' == 'TRANSPORTE'
          ${json_obj}       Evaluate                        json.loads('''${JSON.content}''')    json
          Log To Console    \nGerada a CR ${json_obj['numero']}/${json_obj['ano']}
        ELSE
            Log                                          ${JSON.json()} 
        END
    ELSE IF    '${JSON}' == '<Response [500]>'
        Log                                          ${JSON.json()}
    ELSE
        Log                                          ${JSON.json()} 
    END
    
    