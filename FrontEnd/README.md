## Arquivos

- index.html — interface principal e navegação
- css/style.css — estilos base
- css/upgrade.css — identidade visual e módulos novos
- js/app.js — fluxos de recebimento/expedição, estoque, auditoria
- js/modules.js — módulos demonstrativos de cadastro, relatório, importação/exportação
- assets/logo-depot.png — logo enviada

## Funcionalidades demonstrativas

- Visão geral e indicadores de operações.
- Fluxo de recebimento: pedido/fornecedor, conferência, divergências, criticidade, aprovação, condição perigosa, endereçamento e entrada no estoque.
- Fluxo de expedição: pedido, saldo, verificação FIFO declarada, separação, conferência, aprovação, expedição e entrega/devolução.
- Estoque por produto/lote/endereço; histórico, log local e CSV.
- Cadastros CRUD locais: produtos/lotes, compras, reservas, movimentações, aprovações, transportes/entregas, ocorrências/devoluções, parceiros, armazéns/zonas/locais, usuários/perfis.
- Relatórios, exportações CSV, impressão, backup/importação JSON.

## Limitações importantes

Este projeto é um **front-end de demonstração**, NÃO um WMS de produção. Os cadastros dos módulos adicionais são independentes e **não aplicam transações de estoque
em todas as tabelas**. A verificação FIFO e permissões são ilustrativas; não há autenticação real, bloqueios multiusuário, engine de aprovação, integração com 
transportadoras, SQL Server ou blockchain operacional. O cadastro de usuários NÃO autentica nem protege informações. As decisões dos fluxos dependem de informações
informadas manualmente no protótipo. A trilha de auditoria é local, editável e não deve ser considerada evidência legal. Para atender integralmente aos diagramas DER
e SQL é necessário avançarmos para a próxima etapa que é construir um back-end aplicando regras, integrando com o banco de dados, para realizar validações e testes.
