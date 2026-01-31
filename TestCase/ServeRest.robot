*** Settings ***
Test Teardown           Close Browser
Resource    ../Utils/Utils.robot
Resource    ../Resource/ServeRest.robot

*** Test Cases ***
Cenário 01: realizar login no ServeRest
    Dado que esteja no Portal "ServeRest"
    E Inserir no campo "Email Login" o valor "wendelmarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    Sleep    3s