*** Settings ***
Test Teardown           Close Browser
Resource    ../Utils/Utils.robot
Resource    ../Resource/ServeRest.robot

*** Test Cases ***

#CENÁRIOS USUÁRIOS
Cenário 01: realizar login no ServeRest
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    Printar tela
    Sleep    5s

Cenário 02: cadastrar usuário no ServeRest (Com permissão de Administrador)
    Abrir Navegador Headless
    E Clicar no botão "Cadastre se"
    E Inserir no campo "Nome" o valor "Gustavo marinho"
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Cadastrar Adm"
    E Clicar no botão "Cadastrar"
    Printar tela
    Sleep    5s

Cenário 03: cadastrar usuário no ServeRest (Sem permissão de Administrador)
    Abrir Navegador Headless
    E Clicar no botão "Cadastre se"
    E Inserir no campo "Nome" o valor "Gustavo marinho"
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Cadastrar"
    Printar tela
    Sleep    5s

Cenário 04: Listar usuários no ServeRest
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    E Clicar no botão "Listar Usuários"
    Printar tela
    Sleep    5s

Cenário 05: Excluir usuários no ServeRest
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    E Clicar no botão "Listar Usuários"
    Printar tela
    E Clicar no botão "Excluir Usuário"
    Printar tela
    Sleep    5s

#CENÁRIOS PRODUTOS
Cenário 06: Cadastrar produtos no ServeRest
#CENÁRIOS PRODUTOS
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    E Clicar no botão "Cadastrar Produtos"
    E Inserir no campo "Nome" o valor "Ryzen 8 5800x3D"
    E Inserir no campo "Preço" o valor "2600"
    E Inserir no campo "Descrição" o valor "Teste QA"
    E Inserir no campo "Quantidade" o valor "20"
    Fazer Upload de Imagem Dinâmico    ${CAMPO_IMAGEM}    ${NOME_IMAGEM}
    E Clicar no botão "Cadastrar"
    Printar tela
    Sleep    5s

Cenário 07: Forçar Cadastrar produtos dubplicados no ServeRest
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    E Clicar no botão "Cadastrar Produtos"
    E Inserir no campo "Nome" o valor "Ryzen 8 5800x3D"
    E Inserir no campo "Preço" o valor "2600"
    E Inserir no campo "Descrição" o valor "Teste QA"
    E Inserir no campo "Quantidade" o valor "20"
    Fazer Upload de Imagem Dinâmico    ${CAMPO_IMAGEM}    ${NOME_IMAGEM}
    E Clicar no botão "Cadastrar"
    Ler Mensagem De Erro Cadastro Produto
    Printar tela
    Sleep    5s

Cenário 08: Listar produtos no ServeRest
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    E Clicar no botão "Listar Produtos"
    Printar tela
    Sleep    5s

Cenário 09: Excluir produtos no ServeRest
    Abrir Navegador Headless
    E Inserir no campo "Email" o valor "gustavomarinhoo@qa.com.br"
    E Inserir no campo "Senha" o valor "teste"
    E Clicar no botão "Entrar"
    E Clicar no botão "Listar Produtos"
    E Clicar no botão "Excluir Produto"
    Printar tela
    Sleep    5s