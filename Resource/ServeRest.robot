** Settings ***
Documentation    Essa suíte testa meu prjeto da automação de N cenários no front do ServeRest!
Resource    ../Utils/Utils.robot       


*** Variables ***
#TELA
${TELA_SERVEREST}                            https://front.serverest.dev/login

#INPUTS (CAIXA DE TEXTO)
${CAMPO_EMAIL_LOGIN}                         //input[@id='email']
${CAMPO_SENHA}                               //input[@id='password']

#BOTÕES
${BOTAO_ENTRAR}                              //button[normalize-space()='Entrar']

*** Keywords ***
Dado que esteja no Portal "ServeRest"
    Open Browser                                                          ${TELA_SERVEREST}                                  chrome 
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