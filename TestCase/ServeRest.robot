*** Settings ***
Test Teardown           Close Browser
Resource    ../Utils/Utils.robot
Resource    ../Resource/ServeRest.robot

*** Test Cases ***
Cenário 01: realizar login no ServeRest
    Dado que esteja no Portal "ServeRest"
    E Inserir no campo "Email Usuario" o valor "wendelmarinhoo@qa.com.br"
    E Inserir no campo "Senha Usuario" o valor "teste"
    E Clicar no botão "Entrar"
    Sleep    5s

Cenário 02: cadastrar usuário no ServeRest (Com permissão de Administrador)
    Dado que esteja no Portal "ServeRest"
    E Clicar no botão "Cadastre se"
    E Inserir no campo "Nome Usuário" o valor "wesley marinho"
    E Inserir no campo "Email Usuário" o valor "wesleymarinho@example.com"
    E Inserir no campo "Senha Usuário" o valor "teste"
    E Clicar no botão "Cadastrar Adm"
    E Clicar no botão "Cadastrar"
    Sleep    5s

Cenário 03: cadastrar usuário no ServeRest (Sem permissão de Administrador)
    Dado que esteja no Portal "ServeRest"
    E Clicar no botão "Cadastre se"
    E Inserir no campo "Nome Usuário" o valor "wesley marinho"
    E Inserir no campo "Email Usuário" o valor "wesleymarinho@example.com"
    E Inserir no campo "Senha Usuário" o valor "teste"
    E Clicar no botão "Cadastrar"
    Sleep    5s