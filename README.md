# Carteira FIIs

App de gestão de carteira de Fundos Imobiliários.

## Stack
- Frontend: HTML + CSS + JS puro (sem frameworks)
- Banco: Supabase (PostgreSQL + Auth)
- Hospedagem: Netlify (site estático + 1 Netlify Function)
- Preços: brapi.dev (chamado por trás de uma Netlify Function, o token não fica exposto no navegador)

## Setup
1. Execute `supabase_setup.sql` no SQL Editor do Supabase.
2. Em **Authentication → Users**, crie o usuário (email + senha) que vai logar no app. Depois, no `index.html`, mapeie o "usuário" digitado na tela de login para esse email em `USER_EMAIL_MAP`.
3. Suba o repositório no GitHub.
4. Conecte o repositório no Netlify (deploy automático).
5. Em **Site configuration → Environment variables**, adicione `BRAPI_TOKEN` com o token da sua conta em brapi.dev (marcado como "Contains secret values").

## Deploy
Qualquer push na branch `main` atualiza o site automaticamente via Netlify.
