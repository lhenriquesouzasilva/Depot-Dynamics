// Módulos de demonstração: persistência local, sem autenticação ou API de produção.
const moduleDefs = {
    produtos: { title: 'Produtos e lotes', desc: 'Cadastro de produtos, unidade de medida, lote, validade e localização.', fields: [['codigo', 'Código'], ['nome', 'Produto'], ['unidade', 'Unidade (UN/KG/CX)'], ['lote', 'Lote'], ['validade', 'Validade', 'date'], ['endereco', 'Endereço'], ['quantidade', 'Quantidade', 'number']], defaults: [] },
    compras: { title: 'Pedidos de compra', desc: 'Referências de compras para suportar o recebimento.', fields: [['numero', 'Pedido de compra'], ['fornecedor', 'Fornecedor'], ['produto', 'Produto'], ['quantidade', 'Qtd. solicitada', 'number'], ['previsao', 'Previsão', 'date'], ['status', 'Situação', 'select', 'Aberto|Aprovado|Recebido|Cancelado']] },
    reservas: { title: 'Reservas de estoque', desc: 'Reserva controlada por lote. Não substitui a baixa do estoque na expedição.', fields: [['pedido', 'Pedido de venda'], ['produto', 'Produto / SKU'], ['lote', 'Lote'], ['quantidade', 'Qtd. reservada', 'number'], ['responsavel', 'Responsável'], ['status', 'Situação', 'select', 'Ativa|Liberada|Atendida|Cancelada']] },
    movimentacoes: { title: 'Movimentações de estoque', desc: 'Registros de entradas, saídas e transferências para consulta e auditoria.', fields: [['tipo', 'Tipo', 'select', 'Entrada|Saída|Transferência|Ajuste'], ['produto', 'Produto'], ['lote', 'Lote'], ['origem', 'Origem'], ['destino', 'Destino'], ['quantidade', 'Quantidade', 'number'], ['motivo', 'Motivo']] },
    aprovacoes: { title: 'Solicitações de aprovação', desc: 'Tratar pendências com justificativa e decisão registrada.', fields: [['referencia', 'Pedido / operação'], ['motivo', 'Motivo'], ['solicitante', 'Solicitante'], ['responsavel', 'Aprovador'], ['status', 'Situação', 'select', 'Pendente|Aprovado|Reprovado'], ['observacao', 'Observação']] },
    transportes: { title: 'Transportes e entregas', desc: 'Cadastro e acompanhamento de transportadora, romaneio, rastreio e entrega.', fields: [['pedido', 'Pedido / expedição'], ['transportadora', 'Transportadora'], ['motorista', 'Motorista'], ['veiculo', 'Placa'], ['rastreamento', 'Rastreio'], ['previsao', 'Previsão', 'date'], ['status', 'Situação', 'select', 'Aguardando|Em transporte|Entregue|Ocorrência']] },
    ocorrencias: { title: 'Ocorrências e devoluções', desc: 'Ocorrências de entrega, retorno para inspeção e tratamento de devoluções.', fields: [['referencia', 'Pedido / entrega'], ['tipo', 'Tipo', 'select', 'Avaria|Falta|Atraso|Devolução|Outro'], ['produto', 'Produto'], ['quantidade', 'Quantidade', 'number'], ['motivo', 'Descrição da ocorrência'], ['status', 'Situação', 'select', 'Aberta|Em análise|Resolvida|Devolvida']] },
    parceiros: { title: 'Clientes e fornecedores', desc: 'Cadastros de entidades relacionadas a vendas e recebimentos.', fields: [['tipo', 'Tipo', 'select', 'Cliente|Fornecedor|Transportadora'], ['codigo', 'Código'], ['nome', 'Razão social / nome'], ['documento', 'Documento'], ['contato', 'Contato'], ['email', 'E-mail'], ['situacao', 'Situação', 'select', 'Ativo|Inativo']] },
    locais: { title: 'Armazéns, zonas e endereços', desc: 'Estrutura física de armazenamento, zonas e capacidade.', fields: [['armazem', 'Armazém'], ['zona', 'Zona'], ['endereco', 'Endereço'], ['tipo', 'Tipo', 'select', 'Padrão|Quarentena|Perigoso|Expedição|Recebimento'], ['capacidade', 'Capacidade', 'number'], ['situacao', 'Situação', 'select', 'Ativo|Bloqueado']] },
    usuarios: { title: 'Usuários e perfis', desc: 'Cadastro demonstrativo de operadores e papéis. Não concede acesso real ou proteção de dados.', fields: [['usuario', 'Usuário'], ['nome', 'Nome'], ['email', 'E-mail'], ['perfil', 'Perfil', 'select', 'Administrador|Gerente|Operador|Funcionário|Cliente|Transportadora'], ['situacao', 'Situação', 'select', 'Ativo|Inativo']] }
};
const modKey = 'depot-dynamics-modules-v2';
let modules = {};
try {
    modules = JSON.parse(localStorage.getItem(modKey)) || {};
}
catch { }
;
Object.keys(moduleDefs).forEach(k => { if (!Array.isArray(modules[k]))
    modules[k] = []; });
const modSave = () => { try {
    localStorage.setItem(modKey, JSON.stringify(modules));
}
catch (e) {
    alert('Não foi possível salvar: armazenamento local indisponível.');
} };
const mEsc = x => String(x ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
let modEditing = null;
function renderModule(k) { if (k === 'relatorios')
    return renderReports(); if (k === 'config')
    return renderConfig(); const def = moduleDefs[k]; if (!def)
    return ''; const recs = modules[k] || []; return `<section class="panel"><div class="module-head"><div><h2>${mEsc(def.title)}</h2><p class="module-sub">${mEsc(def.desc)}</p></div><button class="btn" type="button" onclick="toggleModuleForm('${k}')">+ Novo registro</button></div><div class="toolrow"><input placeholder="Filtrar registros..." aria-label="Filtrar registros" oninput="filterModuleRows(this.value)"><button class="btn secondary" onclick="exportModuleCSV('${k}')">Exportar CSV</button><span class="helper">${recs.length} registros</span></div><div id="moduleform" style="display:none"></div><div class="tablewrap"><table><thead><tr>${def.fields.map(f => `<th>${mEsc(f[1])}</th>`).join('')}<th>Ações</th></tr></thead><tbody id="modrows">${recs.length ? recs.map((r, i) => `<tr class="data-row">${def.fields.map(f => `<td>${mEsc(r[f[0]])}</td>`).join('')}<td><div class="actionbuttons"><button class="btn secondary mini" onclick="editModule('${k}',${i})">Editar</button><button class="mini danger" onclick="deleteModule('${k}',${i})">Excluir</button></div></td></tr>`).join('') : `<tr><td colspan="${def.fields.length + 1}"><div class="empty-box">Nenhum registro ainda. Clique em “Novo registro” para começar.</div></td></tr>`}</tbody></table></div></section><div class="info-strip">Os dados deste módulo ficam salvos apenas neste navegador. Regras corporativas, permissões e integridade referencial precisam ser implementadas no servidor.</div>`; }
function filterModuleRows(q) { document.querySelectorAll('.data-row').forEach(r => r.style.display = r.textContent.toLocaleLowerCase('pt-BR').includes(String(q).toLocaleLowerCase('pt-BR')) ? '' : 'none'); }
function toggleModuleForm(k, index = null) { const d = moduleDefs[k], box = document.getElementById('moduleform'); if (!box)
    return; if (box.style.display !== 'none' && index === null) {
    box.style.display = 'none';
    return;
} modEditing = index; let obj = index === null ? {} : modules[k][index]; box.style.display = 'block'; box.innerHTML = `<div class="formbox"><h3>${index === null ? 'Novo registro' : 'Editar registro'}</h3><form id="modform" onsubmit="submitModule(event,'${k}')"><div class="modform">${d.fields.map(f => `<div><label for="mf_${f[0]}">${mEsc(f[1])}</label>${f[2] === 'select' ? `<select id="mf_${f[0]}" name="${f[0]}" required>${f[3].split('|').map(x => `<option ${obj[f[0]] === x ? 'selected' : ''}>${mEsc(x)}</option>`).join('')}</select>` : `<input id="mf_${f[0]}" name="${f[0]}" type="${f[2] || 'text'}" value="${mEsc(obj[f[0]])}" ${f[2] === 'number' ? 'min="0" step="any"' : ''} required>`}</div>`).join('')}</div><div class="toolrow"><button class="btn" type="submit">Salvar registro</button><button class="btn secondary" type="button" onclick="document.getElementById('moduleform').style.display='none'">Cancelar</button></div></form></div>`; box.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }
function submitModule(e, k) { e.preventDefault(); const row = Object.fromEntries(new FormData(e.target).entries()); row.__at = modEditing !== null ? modules[k][modEditing].__at : new Date().toISOString(); if (modEditing === null)
    modules[k].unshift(row);
else
    modules[k][modEditing] = row; modSave(); if (typeof log === 'function')
    log(`Cadastro ${k}: ${Object.values(row)[0]} ${modEditing === null ? 'criado' : 'atualizado'}`); modEditing = null; render(); toast('Registro salvo no navegador'); }
function editModule(k, i) { toggleModuleForm(k, i); }
function deleteModule(k, i) { if (!confirm('Excluir este registro demonstrativo?'))
    return; const r = modules[k].splice(i, 1)[0]; modSave(); if (typeof log === 'function')
    log(`Cadastro ${k}: ${Object.values(r)[0]} excluído`); render(); }
function downloadCSV(rows, name) { const csv = '\ufeff' + rows.map(r => r.map(v => '"' + String(v ?? '').replace(/"/g, '""') + '"').join(';')).join('\r\n'); const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' }); const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = name + '.csv'; a.click(); setTimeout(() => URL.revokeObjectURL(a.href), 1000); }
function exportModuleCSV(k) { const fields = moduleDefs[k].fields; downloadCSV([fields.map(f => f[1]), ...modules[k].map(r => fields.map(f => r[f[0]]))], 'depot_' + k); }
function renderReports() { const ops = db.operations, by = x => ops.filter(o => o.type === x), pend = ops.filter(o => o.status !== 'Concluído'); return `<div class="panel"><div class="module-head"><div><h2>Indicadores e relatórios</h2><p class="module-sub">Consolidação dos dados demonstrativos deste navegador.</p></div><button class="btn secondary" onclick="window.print()">Imprimir relatório</button></div><div class="stats"><div class="metric"><small>Operações totais</small><strong>${ops.length}</strong></div><div class="metric"><small>Entradas registradas</small><strong>${by('Recebimento').length}</strong></div><div class="metric"><small>Expedições registradas</small><strong>${by('Expedição').length}</strong></div><div class="metric"><small>Pendências</small><strong>${pend.length}</strong></div><div class="metric"><small>Unidades em estoque</small><strong>${db.stock.reduce((s, r) => s + Number(r.qty || 0), 0)}</strong></div><div class="metric"><small>Ocorrências</small><strong>${modules.ocorrencias.length}</strong></div></div><div class="toolrow"><button class="btn" onclick="exportOpsReport()">Exportar operações CSV</button><button class="btn secondary" onclick="exportStockReport()">Exportar estoque CSV</button><button class="btn secondary" onclick="downloadFullBackup()">Backup JSON</button></div></div><section class="panel"><h2>Operações e status</h2>${tableOps(ops)}</section><div class="info-strip">Relatórios demonstrativos. Sem integração com SQL Server, dados multiusuário ou autenticação.</div>`; }
function exportOpsReport() { downloadCSV([['Identificador', 'Tipo', 'Produto', 'Quantidade', 'Situação', 'Data', 'Motivo'], ...db.operations.map(x => [x.id, x.type, x.product, x.qty, x.status, x.date, x.reason])], 'depot_operacoes'); }
function exportStockReport() { downloadCSV([['Código', 'Produto', 'Lote', 'Endereço', 'Quantidade', 'Bloqueado'], ...db.stock.map(x => [x.id, x.name, x.lot, x.address, x.qty, x.blocked ? 'Sim' : 'Não'])], 'depot_estoque'); }
function downloadFullBackup() { const contents = JSON.stringify({ version: 2, exportedAt: new Date().toISOString(), core: db, modules }, null, 2), a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([contents], { type: 'application/json' })); a.download = 'depot_backup.json'; a.click(); setTimeout(() => URL.revokeObjectURL(a.href), 1000); }
function renderConfig() { return `<div class="panel"><h2>Configurações e dados locais</h2><p class="module-sub">Exporte seus dados antes de limpar o navegador ou trocar de computador.</p><div class="toolrow"><button class="btn" onclick="downloadFullBackup()">Baixar backup JSON</button><label class="btn secondary" style="cursor:pointer">Importar backup <input type="file" accept=".json,application/json" onchange="importFullBackup(event)" hidden></label><button class="mini danger" onclick="resetDemo()">Restaurar demonstração</button></div><div class="info-strip">A importação substitui todos os registros locais deste projeto. Use somente backups confiáveis e gerados por esta versão.</div></div><div class="panel"><h2>Modelo de permissões previsto</h2><p class="module-sub">Administrador, Gerente, Funcionário, Operador, Cliente e Transportadora; na demonstração, os perfis são apenas campos de cadastro. A autorização real deve ocorrer no back-end.</p><h2>Integrações futuras</h2><p class="module-sub">SQL Server, autenticação e perfis, API de compras e pedidos, transações atômicas para reservas e expedições, trilha de auditoria imutável e evidência rastreável.</p></div>`; }
async function importFullBackup(e) { const file = e.target.files[0]; if (!file)
    return; try {
    if (file.size > 2e6)
        throw new Error('Arquivo muito grande');
    const b = JSON.parse(await file.text());
    if (b.version !== 2 || !b.core || !Array.isArray(b.core.stock) || !Array.isArray(b.core.operations) || !b.modules || typeof b.modules !== 'object')
        throw new Error('Formato de backup inválido');
    if (!confirm('Substituir todos os dados locais pelo backup?'))
        return;
    db = b.core;
    Object.keys(moduleDefs).forEach(k => modules[k] = Array.isArray(b.modules[k]) ? b.modules[k] : []);
    save();
    modSave();
    render();
    toast('Backup importado');
}
catch (err) {
    alert('Falha ao importar: ' + err.message);
} }
function resetDemo() { if (!confirm('Apagar os registros locais e restaurar os dados de demonstração?'))
    return; localStorage.removeItem('depot-dynamics-demo-v1'); localStorage.removeItem(modKey); location.reload(); }

