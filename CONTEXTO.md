# CONTEXTO DO PROJETO — KRAKEN / Carteira de FIIs

> Este arquivo existe para dar contexto completo a qualquer assistente (Claude Code, Claude.ai, etc.)
> que for trabalhar neste projeto. Leia antes de mexer em qualquer coisa.
> Última atualização: agosto/2026 (revisado após a sessão de segurança de 09/08)

---

## 0. IMPORTANTE — leia antes de gerar/editar o `index.html`

Este projeto era editado por dois caminhos (um Claude.ai Project que gerava o `index.html`
inteiro via `atualizar.ps1`, e sessões de Claude Code). **A partir de agosto/2026 o trabalho
neste projeto acontece só via Claude Code** — o Claude.ai Project não é mais usado. O
`atualizar.ps1` continua no repo por enquanto, mas é um script legado.

Em 09/08/2026 uma sessão de Claude Code fez uma rodada de correções de segurança que
**mudou partes estruturais do arquivo**. Se qualquer sessão futura for reescrever grandes
trechos do `index.html`, preserve obrigatoriamente:

- A tag `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>` antes do
  `<script>` principal.
- O cliente `sbClient = supabase.createClient(SB_URL, SB_KEY)`, o `USER_EMAIL_MAP`, e as funções
  `authHeaders()`, `doLogin()`, `doLogout()` como estão — é login real via Supabase Auth, não mais
  usuário/senha fixos no JS.
- As funções `sbGet`/`sbPost`/`sbPatch`/`sbDelete` usando `await authHeaders()` (token da sessão
  logada), não uma constante `HEADERS` fixa.
- `fetchPrices()` chamando `/.netlify/functions/preco?ticker=...` — **não** a API da brapi.dev
  direto com um token na URL. O token vive só na variável de ambiente `BRAPI_TOKEN` da Netlify,
  lido pela function em `netlify/functions/preco.js`.
- `SB_KEY` é a **Publishable key** nova do Supabase (`sb_publishable_...`), não a anon key JWT antiga.

Reverter qualquer um desses pontos reabre os problemas de segurança que foram corrigidos
(login decorativo, banco público, chaves expostas).

---

## 1. O que é este projeto

App pessoal de gestão de carteira de investimentos do Guilherme (GitHub: `Lorin24308`).

Hoje cobre **apenas FIIs** (Fundos de Investimento Imobiliário brasileiros), mas foi
desenhado para crescer e virar um dashboard da carteira completa no futuro. Isso
importa na hora de sugerir arquitetura: **não criar soluções que dificultem essa expansão**.

**Objetivo de curto prazo do usuário:** atingir **R$ 30/mês em dividendos** dentro de FIIs
antes de começar a aportar nas outras classes de ativo.

---

## 2. Stack e infraestrutura

| Camada | Tecnologia |
|---|---|
| Frontend | HTML + CSS + JS **puro**, arquivo único `index.html` — **sem frameworks** (com exceção da lib `supabase-js`, carregada via CDN só para autenticação) |
| Banco de dados | Supabase (PostgreSQL + Auth) |
| Hospedagem | Netlify (deploy automático via GitHub), site estático + 1 Netlify Function |
| Cotações | brapi.dev (plano gratuito), chamada por trás da Netlify Function `netlify/functions/preco.js` |
| Autenticação | Supabase Auth real (email + senha). A tela de login pede um "usuário" (ex: `guilherme`), mapeado para o email cadastrado via `USER_EMAIL_MAP` no `index.html` |

**Endereços:**
- Repositório: `github.com/Lorin24308/carteira-fiis-lorin`
- Site: `carteiralorin.netlify.app`
- Supabase: `pcsnkxnxafwqzqrsrkjw.supabase.co`
- Pasta local: `C:\Users\Guilherme Lorin\Documents\PROJETO\carteira-fiis-projeto`

**Login:** usuário `guilherme`, autenticado de verdade via Supabase Auth (não é mais senha fixa no
código). O email associado à conta de login não é segredo (não é o e-mail que se usa pra dados
sensíveis do usuário), mas a senha real fica só no Supabase, nunca no código.

> ✅ **Segurança corrigida em 09/08/2026:** RLS de todas as tabelas travado para `authenticated`
> (antes era `public`, qualquer um com a URL do Supabase lia/escrevia tudo sem login). A anon key
> antiga (que ficava exposta no `index.html`) foi **desativada** — o app usa a Publishable key nova,
> que pode ser revogada sem derrubar sessões de Auth. O token da brapi.dev não aparece mais no
> navegador, fica só como variável de ambiente na Netlify.

---

## 3. Metodologia de investimento (KRAKEN)

O planejamento de longo prazo divide o patrimônio em 6 classes:

| Letra | Classe | % alvo |
|---|---|---|
| K | Caixa / Renda Fixa | 15% |
| R | Real Estate (FIIs) | 25% |
| A | Ações BR | 25% |
| K | Kripto (BTC) | 5% |
| E | Exterior (stocks internacionais) | 25% |
| N | Opções | 5% |

> Opções é um módulo distante — não priorizar.
> **Fase atual: ênfase total no módulo R (FIIs).**

### Alocação-alvo dentro dos FIIs

| Segmento | % alvo |
|---|---|
| Papel | 30,0% |
| Logística | 22,5% |
| Shopping | 20,0% |
| Renda Urbana | 10,0% |
| Lajes Corporativas | 10,0% |
| Híbrido/Outros | 7,5% |

**Estratégia:** Geração de Dividendos (metodologia do canal do Leo, "Geração Dividendos").

> ⚠️ **IMPORTANTE:** esses percentuais são referência de **longo prazo**. O usuário
> intencionalmente se desvia deles em meses específicos para aproveitar oportunidades.
> **Não tratar desvio como erro ou desalinhamento** — é ajuste tático esperado.

### Holdings atuais

| Ticker | Segmento |
|---|---|
| GARE11 | Renda Urbana |
| VGIR11 | Papel |
| GGRC11 | Logística |
| LVBI11 | Logística |
| HGBS11 | Shopping |
| MCCI11 | Papel |

**Lacunas conhecidas:** zero exposição a Lajes Corporativas (alvo 10%) e Híbrido/Outros (alvo 7,5%).
HGRE11 foi levantado como candidato a Lajes Corporativas (P/VP ~0,88x, dentro da faixa 0,87–1,0 que o usuário usa como filtro).

### Processo de triagem de novos FIIs (como o usuário faz hoje, manualmente)

1. Vai no **Fundamentus**, filtra por tipo (ex: só Logística)
2. Joga na planilha e elimina os que estão fora da faixa de **P/VP entre 0,87 e 1,0**
3. Avalia liquidez diária e preço da cota (vale para todos os tipos)
4. Para FIIs de **tijolo**: analisa quantidade de imóveis, vacância, inquilinos, localização
5. Para **papel**: analisa composição da carteira de CRIs e indexadores
6. Reduz a no máximo ~5 candidatos, lê o RI de cada um e escolhe o melhor

Existe interesse futuro em automatizar os passos 1–3 dentro do app. Também foi levantada a ideia
de um agente de IA que lê RIs por setor, resume e avisa sobre eventos que impactam o mercado —
ainda não iniciada, tratada como fase futura separada.

---

## 4. Estrutura do banco (Supabase)

Tabelas ativas hoje:

- `fiis` — ticker, tipo, cotas, pmedio, preco, pvp, dy, **pteto**, nome
- `dividendos` — data, ticker, mes_ref, valor
- `movimentos` — data, operacao, ticker, tipo, qtd, preco, taxa, total
- `estudo` — ticker, nome, tipo, pvp, dy, liquidez, status, notas
- `evolucao` — data, patrimonio (snapshot semanal automático)
- `cofrinhos` — id, nome, meta, atual (substituiu `reserva`; módulo em desenvolvimento)

**Tabelas legadas, sem uso pelo app** (ainda existem no banco, não removidas por segurança):
`reserva`, `reserva_locs` — foram substituídas por `cofrinhos`. Não usar em queries novas.

> ✅ Todas as tabelas (ativas e legadas) têm RLS habilitado com policy `authenticated_all`,
> restrita a `to authenticated` — não mais `public_all` aberto para qualquer um.

O schema completo e atualizado vive em `supabase_setup.sql`, na raiz do repositório — é a fonte
da verdade, mantida sincronizada com o banco real.

---

## 5. Estado atual das funcionalidades

**Implementado e no ar:**
- Login real via Supabase Auth (usuário mapeado para email)
- Tema claro/escuro com botão
- Dashboard: patrimônio, custo, resultado, DY médio, dividendos, reserva
- Gráfico donut de alocação atual + legenda
- Gráfico de evolução do patrimônio (snapshot semanal automático)
- Gráfico de dividendos por mês — 12 meses fixos com navegação por ano (setas ◀ ▶)
- Barras de alocação atual vs meta
- Sugestão de próximo aporte com valor em R$ para equilibrar
- Aporte rápido no dashboard (simulador inline)
- Alertas visuais: P/VP < 0,90, preço abaixo do teto, alocação fora da meta
- Carteira: tabela ordenável por qualquer coluna, filtro por tipo, edição via modal
- Colunas Valorização (só preço) e Retorno Total (preço + dividendos)
- Preço teto configurável por FII
- Movimentações via **modal compacto** com botões Compra/Venda, total calculado automático, sem campo de taxas
- Compra/venda atualiza a carteira automaticamente (recalcula preço médio, soma/subtrai cotas, remove FII se zerar)
- Simulador de aporte com sugestão de cotas aproximadas
- Reserva de emergência com meta, progresso e locais
- Aba Estudo para FIIs em análise
- **KRAKEN Dashboard** (tela de lobby pós-login) com donut de alocação por classe, hover interativo e overlays "em breve" nos módulos não implementados
- Busca de cotações em paralelo (`Promise.all`), com aviso visual (⚠️) quando uma cotação falha em atualizar

**Em desenvolvimento / aguardando decisão do usuário:**
- **Cofrinhos** — módulo de múltiplas metas de poupança. Tabela criada, mockup produzido com duas variantes de widget (anel de progresso vs. chips de barra vertical colorida). **Aguardando o usuário escolher a variante** antes de implementar.
- **Relatório Geral da Carteira** — mockup interativo pronto. Decisões abertas: estilo do botão (pill outline "A" vs. link sublinhado "B"), se mantém os chips "em breve", e ajustes de colunas/métricas.

**Descartado por enquanto (decisão explícita do usuário em 09/08):**
- Validações de formulário mais rígidas — baixa prioridade.
- Completar os módulos "em breve" do lobby (Renda Fixa, Ações BR, Cripto, Exterior) — considerado não valer a pena agora.

### Estrutura de caixinhas do usuário (para o módulo Cofrinhos)

| Caixinha | Onde | Meta |
|---|---|---|
| Reserva de emergência | Nubank | R$ 12.000 |
| Render | Mercado Pago | R$ 10.000 |
| Objetivos curtos | Mercado Pago | Compras pontuais (cadeira ergonômica, mesa, peças, roupas) |
| Viagem fim do ano | Mercado Pago | R$ 500/mês até dezembro |

---

## 6. Backlog de ideias (levantadas, ainda não implementadas)

**Alta prioridade / já discutidas em detalhe:**
- Modal compacto para registrar **tudo** (dividendos, reserva, estudo) — hoje só movimentações usa modal
- Autocomplete de ticker ao digitar
- Filtros/ordenação clicáveis em **todas** as tabelas (hoje só na Carteira)
- Módulo **Renda Fixa** separado da Reserva de Emergência
  - Reserva = colchão de segurança, liquidez imediata, fora do KRAKEN
  - Renda Fixa = investimento ativo (Tesouro, CDB, LCI), dentro do KRAKEN (15%)

**Médio prazo:**
- PWA (ícone na tela inicial do celular)
- Meta de dividendos mensais com barra de progresso (alvo atual: R$ 30/mês)
- Comparador de dois FIIs lado a lado
- Rentabilidade da carteira vs CDI e IPCA
- Calendário de dividendos (quais FIIs pagam em cada mês)
- Ferramenta de screening estilo Fundamentus dentro do app
- Monitor de RI / Fatos Relevantes com notificações
- Resumo automático de RI por IA (upload de PDF ou link) — cogitado usar um agente agendado
- Log de decisões dentro do próprio app (não documento separado)
- Notificações por e-mail para `guilhermelorin56@gmail.com` (FII atingiu preço teto, P/VP < 0,90) — precisaria de serviço tipo Resend
- ~~Alterar senha pelo próprio app~~ — feito em 12/08/2026 (botão 🔑 no cabeçalho, também trata login via link de recuperação por email)
- Relatório PDF mensal
- Refinamento visual do donut (usuário achou pequeno/simples — adiado)

---

## 7. Como trabalhar neste projeto

### Fluxo de deploy

O trabalho no projeto acontece só via Claude Code:
```
Editar index.html / supabase_setup.sql / etc. direto no repositório
  → git add / commit / push
  → Netlify faz deploy automático (~30s)
```
O usuário deu autorização permanente para commit/push automático neste repositório,
desde que a mudança tenha sido planejada e combinada com ele antes de executar.

Mudanças de SQL vão direto no **SQL Editor do Supabase** antes/depois do deploy do front,
conforme o caso.

`atualizar.ps1` é um script legado do antigo fluxo via Claude.ai (copiava um `index.html`
gerado em outro lugar para o repo e publicava). Não é mais usado, mas continua no repositório.

### Regras de trabalho atuais (via Claude Code)

1. **Visual primeiro.** Para qualquer coisa de UI/design, mostrar mockups com variações
   **antes** de escrever código de produção. Mostrar opções → usuário escolhe → aí sim implementar.

2. **Estilo de resposta:** direto ao ponto, sempre explicando o raciocínio por trás da mudança.
   Sem rodeios. O usuário está aprendendo — vale orientar quando algo for específico da ferramenta,
   e explicar termos técnicos em linguagem simples (ele avisou que não domina a maioria deles).

3. O usuário **decide** o que é executado. Sugestões e ideias são bem-vindas, mas ele escolhe.
   Dito isso, ele prefere deixar o máximo possível automático — não é necessário parar para
   confirmar cada passo pequeno depois que uma direção já foi combinada; reportar o que foi
   feito é suficiente, exceto para ações genuinamente arriscadas ou difíceis de reverter.

4. Commit/push direto no repositório está autorizado permanentemente, desde que a mudança
   tenha sido combinada com o usuário antes de executar.

> Regras antigas do fluxo via Claude.ai (planejamento único fechado antes de codar, uma entrega
> de arquivo inteiro por rodada, disciplina de chats separados por feature) não se aplicam mais —
> eram específicas daquele workflow, que foi descontinuado em agosto/2026.

### Regras técnicas importantes

- **Sempre buscar o arquivo vivo do GitHub antes de editar:**
  ```bash
  curl -sL https://raw.githubusercontent.com/Lorin24308/carteira-fiis-lorin/main/index.html
  ```
  A cópia local pode estar desatualizada. Edições em chats/sessões paralelas divergem a base —
  o usuário deve avisar sobre alterações paralelas antes da geração do arquivo.
- Validar sintaxe JS com Node antes de entregar; checar balanceamento estrutural com `grep`/`awk`.
- Arquivo único, sem build step, sem frameworks (exceto `supabase-js` via CDN para Auth). Manter assim.

---

## 8. Aprendizados sobre FIIs (contexto de domínio)

Coisas que já foram esclarecidas e não precisam ser reexplicadas:

- **brapi plano gratuito:** aceita **1 ticker por requisição**. Buscar em paralelo (`Promise.all`),
  não precisa ser sequencial — já corrigido.
- **brapi e P/VP:** o campo `priceToBook` frequentemente vem nulo para FIIs.
  Workaround implementado: calcular manualmente `regularMarketPrice / bookValue`.
- **Variação diária é sinal ruim para FII** — são pouco líquidos. O que importa é o
  **retorno total** (preço + dividendos). O usuário fica nervoso com queda de ~3% no dia;
  isso já foi reenquadrado como pouco informativo.
- **Data-ex:** queda de preço na data-ex é mecânica e esperada, não é problema do fundo.
- **Corte de Selic reduz distribuição** de fundos de papel indexados ao CDI (ex: VGIR11).
  É consequência matemática, não deterioração de crédito.
- **Preço da corretora ≠ preço da brapi** — fontes e horários de atualização diferentes.
  Não é bug.

### Notas sobre os fundos da carteira

- **LVBI11** — fundamentos sólidos (vacância zero, dívida baixa), mas sob a sombra da
  incorporação pelo HGLG11, pendente de aprovação da CVM, sem prazo definido.
- **HGBS11** — queda de preço acompanha movimento do IFIX, não deterioração do fundo;
  indicadores operacionais em melhora.
- **VGIR11** — distribuições em queda por efeito mecânico dos cortes de Selic sobre CRIs CDI.

---

## 9. Referências do usuário

- **Fundamentus** — screening de FIIs
- **RIs mensais** — relatórios gerenciais dos fundos
- **Canal "Geração Dividendos"** (Leo) — metodologia KRAKEN e estratégia de dividendos
- Revisão geral do projeto: **mensal**, alinhada ao dia dos aportes

---

## 10. Revisão de bugs (11-12/08/2026)

Uma revisão completa do `index.html` encontrou e corrigiu:
- Apagar uma movimentação não desfazia o efeito dela na carteira — corrigido: a posição de
  cada ticker agora é sempre **recalculada do zero** a partir do histórico de movimentações
  (`recalcularPosicao()`), tanto ao adicionar quanto ao remover uma movimentação.
- Vender mais cotas do que a posição atual apagava o FII silenciosamente — agora `addMov()`
  valida antes de gravar e avisa o usuário.
- Sessão expirada gerava erro técnico genérico — `authHeaders()` agora detecta sessão ausente
  e manda de volta pro login.
- Falha em uma tabela do Supabase travava o carregamento inteiro — `init()` usa
  `Promise.allSettled`, cada tabela falha de forma independente.
- Cálculo de "número da semana" do snapshot de patrimônio (`getISOWeek`) tinha risco de
  duplicar/pular na virada do ano — trocado por um controle simples de "6+ dias desde o
  último snapshot".
- **Categoria "FoF" removida** das metas de alocação e de todos os seletores de tipo — não
  fazia parte da estratégia real documentada. Meta de Logística ajustada de 20% para 22,5% e
  de Híbrido/Outros de 5% para 7,5%, para bater com a tabela da seção 3 deste documento.
- Decisão tomada: **não** adicionar um terceiro botão "Reinvestimento" no modal de
  movimentação — registrar como "Compra" já produz exatamente o mesmo efeito no cálculo de
  posição, então o botão extra seria redundante.

## 11. Log de mudanças

- **09/08/2026** — Sessão de correções de segurança (via Claude Code): login real via Supabase
  Auth, RLS travado para `authenticated` em todas as tabelas, anon key legada desativada (app
  migrado para Publishable key), token da brapi.dev escondido atrás de uma Netlify Function,
  `supabase_setup.sql` sincronizado com o schema real (`cofrinhos`, `evolucao`, `pteto`, sem
  `reserva`/`reserva_locs`), busca de cotações paralelizada com aviso visual de erro, README
  atualizado com o setup completo. Este arquivo (`CONTEXTO.md`) passou a viver no repositório.
- **11-12/08/2026** — Revisão de bugs (ver seção 10): correções de integridade de dados
  (recálculo de posição, validação de venda a descoberto), robustez (sessão expirada, falha
  parcial de tabelas, snapshot semanal) e remoção da categoria "FoF" das metas de alocação.
