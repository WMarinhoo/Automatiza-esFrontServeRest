** Settings ***
Documentation    Essa suíte testa meu prjeto da automação de N cenários no front do ServeRest!
Resource    ../Utils/Utils.robot       


*** Variables ***
#TELA
${TELA_SERVEREST}                            https://front.serverest.dev/login

#INPUTS (CAIXA DE TEXTO)
${CAMPO_EMAIL_USUARIO}                        //input[@id='email']
${CAMPO_SENHA_USUARIO}                        //input[@id='password']
${CAMPO_NOME_USUARIO}                         //input[@id='nome']

#BOTÕES
${BOTAO_ENTRAR}                               //button[normalize-space()='Entrar']
${BOTAO_CADASTRE_SE}                          //a[normalize-space()='Cadastre-se']
${BOTAO_CADASTRAR_ADM}                        //input[@id='administrador']
${BOTAO_CADASTRAR}                            //button[normalize-space()='Cadastrar']
${BOTAO_LISTAR_USUARIOS}                      //a[@data-testid='listarUsuarios']
${BOTAO_EXCLUIR_USUARIO}                      //body[1]/div[1]/div[1]/div[1]/p[1]/table[1]/tbody[1]/tr[1]/td[5]/div[1]/button[2]

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