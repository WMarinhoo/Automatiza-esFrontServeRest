# 🚀 Automatizações Front ServeRest

> Conjunto de automações de testes E2E aplicadas ao **Front-end do ServeRest** — com testes organizados por cenários e resultados sendo registrados automaticamente.

---

## 🧠 Sobre o Projeto

Este repositório contém automações desenvolvidas para o **front do ServeRest**, que é uma aplicação utilizada como base de testes (incluindo automações Web/UI). A ideia principal é demonstrar cenários de testes organizados e prontos para serem integrados em pipelines de CI/CD (como **GitHub Actions** ou outro sistema de integração contínua), possibilitando **testes de regressão automáticos após cada deploy**.

---

## 📌 Objetivos

✔️ Criar automações organizadas por cenário  
✔️ Facilitar a execução de testes de regressão  
✔️ Preparar base para integração com pipelines de CI/CD  
✔️ Gerar evidências e resultados automáticos de testes

---

## 🧩 Estrutura do Repositório

.
├── Resource/ # Recursos de apoio (locators, dados, configs)
├── TestCase/ # Testes divididos por cenários
├── Utils/ # Funções utilitárias e helpers
├── results/ # Relatórios e evidências gerados automaticamente
└── README.md # Documentação


---

## 🛠️ Tecnologias Utilizadas

✅ **Robot Framework** – Base da automação  
✅ **Python** – Linguagem principal  
✅ **ServeRest (Front)** – Aplicação alvo das automações  
✅ **Estrutura modular de testes** – Separada por cenários

---

## ▶️ Como Executar

> **Requisitos**
- Python 3.8+
- Robot Framework
- Browsers + Drivers compatíveis

1. Clone este repositório  
   ```bash
   git clone https://github.com/WMarinhoo/Automatiza-esFrontServeRest.git

2.Acesse a pasta do projeto:
```bash
cd Automatiza-esFrontServeRest
```

3.Instale as dependências (exemplo com pip):
```bash
pip install -r requirements.txt
```

4.Execute os testes:
```bash
robot TestCase/
```
---

> Desenvolvido com 💛 e foco em qualidade de software. 🚀  
>  
> **Wendel Marinho**  
> QA | Automação de Testes | Robot Framework | Selenium | CI/CD