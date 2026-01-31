** Settings ***
Documentation    Essa suíte testa meu prjeto da automação de N cenários no front do ServeRest!
Resource    ../Utils/Utils.robot       


*** Variables ***
#TELA
${TELA_SERVEREST}                            https://front.serverest.dev/login

#INPUTS (CAIXA DE TEXTO)
${CAMPO_EMAIL}                               //input[@id='email']
${CAMPO_SENHA}                               //input[@id='password']
${CAMPO_NOME}                                //input[@id='nome']
${CAMPO_PRECO}                               //input[@id='price']
${CAMPO_DESCRICAO}                           //textarea[@id='description']
${CAMPO_QUANTIDADE}                          //input[@id='quantity']
${CAMPO_IMAGEM}                              //input[@id='imagem']
${NOME_IMAGEM}                               Ryzen7600x3D.png

#BOTÕES
${BOTAO_ENTRAR}                               //button[normalize-space()='Entrar']
${BOTAO_CADASTRE_SE}                          //a[normalize-space()='Cadastre-se']
${BOTAO_CADASTRAR_ADM}                        //input[@id='administrador']
${BOTAO_CADASTRAR}                            //button[normalize-space()='Cadastrar']
${BOTAO_LISTAR_USUARIOS}                      //a[@data-testid='listarUsuarios']
${BOTAO_EXCLUIR_USUARIO}                      //body[1]/div[1]/div[1]/div[1]/p[1]/table[1]/tbody[1]/tr[1]/td[5]/div[1]/button[2]
${BOTAO_CADASTRAR_PRODUTOS}                   //a[@data-testid='cadastrarProdutos']
${BOTAO_LISTAR_PRODUTOS}                      //a[@data-testid='listarProdutos']

#MENSAGENS
${MENSAGEM_ALERT}                             //div[@role='alert']

*** Keywords ***
Dado que esteja no Portal "ServeRest"
    Open Browser                                                          ${TELA_SERVEREST}                                 chrome 
    Maximize Browser Window

E Inserir no campo "${CAMPO}" o valor "${VALOR}"
    ${CAMPO}=    Gera Frase Em String                                     ${CAMPO} 
    Wait Until Element Is Visible                                         ${CAMPO_${CAMPO}}                                 ${TIMEOUT}
    Wait Until Element Is Enabled                                         ${CAMPO_${CAMPO}}
    Input Text                                                            ${CAMPO_${CAMPO}}                                 ${VALOR} 

E Clicar no botão "${NOME_BOTAO}"
    ${NOME_BOTAO}=    Gera Frase Em String                                ${NOME_BOTAO}
    Wait Until Element Is Visible                                         ${BOTAO_${NOME_BOTAO}}                            ${TIMEOUT}              
    Click Element                                                         ${BOTAO_${NOME_BOTAO}}

Printar tela
    Sleep    3s
    Capture Page Screenshot

Fazer Upload de Imagem Dinâmico
    [Arguments]    ${CAMPO_IMAGEM}    ${NOME_IMAGEM}

    ${CAMINHO_IMAGEM}=    Set Variable
    ...    ${EXECDIR}${/}Utils${/}Fixtures${/}Uploads${/}${NOME_IMAGEM}

    Log    Caminho da imagem: ${CAMINHO_IMAGEM}

    Wait Until Element Is Visible    ${CAMPO_IMAGEM}    10s
    Choose File    ${CAMPO_IMAGEM}    ${CAMINHO_IMAGEM}

E ler a mensagem "${NOME_MENSAGEM}"
    ${NOME_MENSAGEM}=    Gera Frase Em String                             ${NOME_MENSAGEM}
    Wait Until Element Is Visible                                         ${MENSAGEM_${NOME_MENSAGEM}}                          ${TIMEOUT}
    Element Should Contain                                                ${MENSAGEM_${NOME_MENSAGEM}}    None



Ler Mensagem De Erro Cadastro Produto
    [Documentation]    Lê o texto do banner de erro vermelho (toast/alert div) após tentar cadastrar produto duplicado.
    ...    Espera aparecer, captura o texto e retorna.
    ...    Opcionalmente valida com Should Contain ou Should Be Equal.
    [Arguments]    ${timeout}=10s    ${acao_apos}=NONE

    # Seletor principal - ajuste se precisar (testado com o texto da sua imagem)
    ${seletor_banner}    Set Variable    xpath=//div[contains(., 'Já existe produto com esse nome') or contains(@class, 'alert') or contains(@style, 'background')]

    # Espera o elemento aparecer (essencial, pois pode demorar 1-2s)
    Wait Until Element Is Visible    ${seletor_banner}    ${timeout}
    ...    msg=Banner de erro não apareceu em ${timeout}

    # Captura o texto completo do banner
    ${mensagem} =    Get Text    ${seletor_banner}

    # Limpa espaços extras e quebras de linha (comum em divs)
    ${mensagem_limpa} =    Strip String    ${mensagem}

    Log To Console    Mensagem capturada do banner vermelho: "${mensagem_limpa}"

    # Ação opcional: fechar o banner (clica no ×)
    Run Keyword If    '${acao_apos}' == 'FECHAR'
    ...    Click Element    ${seletor_banner}//button | ${seletor_banner}//span[contains(text(),'×')] | ${seletor_banner}//*[contains(@class,'close')]

    [Return]    ${mensagem_limpa}


Validar Mensagem Erro Produto Ja Existe
    [Documentation]    Valida exatamente a mensagem de erro esperada usando Should Be Equal ou Should Contain
    [Arguments]    ${mensagem_esperada}=Já existe produto com esse nome    ${timeout}=10s    ${modo}=EQUAL

    ${mensagem_real} =    Ler Mensagem De Erro Cadastro Produto    ${timeout}    FECHAR

    Run Keyword If    '${modo}' == 'EQUAL'
    ...    Should Be Equal As Strings    ${mensagem_real.strip()}    ${mensagem_esperada.strip()}
    ...    msg=Mensagem de erro diferente da esperada!\nEsperado: "${mensagem_esperada}"\nReal: "${mensagem_real}"

    Run Keyword If    '${modo}' == 'CONTAIN'
    ...    Should Contain    ${mensagem_real}    ${mensagem_esperada}
    ...    msg=Texto esperado não encontrado na mensagem!\nEsperado conter: "${mensagem_esperada}"\nReal: "${mensagem_real}"

    Log    ✅ Validação OK: Mensagem "${mensagem_real}" validada com sucesso!