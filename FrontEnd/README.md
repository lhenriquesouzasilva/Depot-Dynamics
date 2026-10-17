# Depot Dynamics — Front-end demonstrativo v2

## Como executar

1. Extraia o arquivo ZIP.
2. Abra `DepotDynamics_Refeito/index.html` com Chrome/Edge ou no VS Code usando Live Server.
3. Use o menu lateral para explorar os módulos.

**Não é necessário Node.js, instalação ou internet.** Os dados permanecem no `localStorage` do navegador. Para backup, vá em Configurações → Baixar backup JSON. A importação substitui os dados locais.

## Arquivos

- `index.html` — interface principal e navegação
- `css/style.css` — estilos base; `css/upgrade.css` — identidade visual e módulos novos
- `js/app.js` — fluxos de recebimento/expedição, estoque, auditoria
- `js/modules.js` — módulos demonstrativos de cadastro, relatório, importação/exportação
- `assets/logo-depot.png` — logo enviada
- `docs/` — SQL e diagramas originais, para servir de referência à implementação do servidor

## Funcionalidades demonstrativas

- Visão geral e indicadores de operações.
- Fluxo de recebimento: pedido/fornecedor, conferência, divergências, criticidade, aprovação, condição perigosa, endereçamento e entrada no estoque.
- Fluxo de expedição: pedido, saldo, verificação FIFO declarada, separação, conferência, aprovação, expedição e entrega/devolução.
- Estoque por produto/lote/endereço; histórico, log local e CSV.
- Cadastros CRUD locais: produtos/lotes, compras, reservas, movimentações, aprovações, transportes/entregas, ocorrências/devoluções, parceiros, armazéns/zonas/locais, usuários/perfis.
- Relatórios, exportações CSV, impressão, backup/importação JSON.

## Limitações importantes

Este projeto é um **front-end de demonstração**, NÃO um WMS de produção. Os cadastros dos módulos adicionais são independentes e **não aplicam transações de estoque em todas as tabelas**. A verificação FIFO e permissões são ilustrativas; não há autenticação real, bloqueios multiusuário, engine de aprovação, integração com transportadoras, SQL Server ou blockchain operacional. O cadastro de usuários NÃO autentica nem protege informações. As decisões dos fluxos dependem de informações informadas manualmente no protótipo. A trilha de auditoria é local, editável e não deve ser considerada evidência legal. Para atender integralmente aos diagramas DER e SQL é necessário construir back-end com regras, banco de dados, validações e testes.

## Próxima etapa recomendada

Criar back-end (Node.js/Express ou outra stack) e API para as entidades da modelagem `docs/modelagem.sql`, com autenticação RBAC, transações ACID, checagem de saldos e FIFO no servidor, registro de aprovações, trilha de auditoria, evidências rastreáveis e testes de integração. O SQL é referência fornecida e não é executado automaticamente.
