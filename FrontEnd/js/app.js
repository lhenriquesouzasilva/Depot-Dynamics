const KEY = 'depot-dynamics-demo-v1';
const initial = { stock: [{ id: 'P001', name: 'Ração Premium 15 kg', lot: 'L-2601', qty: 120, address: 'A-01-01', blocked: false }, { id: 'P002', name: 'Embalagem 5 kg', lot: 'L-2602', qty: 38, address: 'B-02-03', blocked: false }, { id: 'P003', name: 'Produto em inspeção', lot: 'L-2603', qty: 25, address: 'Q-01-02', blocked: true }], operations: [], logs: [] };
let db;
try {
    db = JSON.parse(localStorage.getItem(KEY)) || structuredClone(initial);
}
catch {
    db = JSON.parse(JSON.stringify(initial));
}
let view = 'inicio', wizard = null;
const $ = id => document.getElementById(id);
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
function save() { localStorage.setItem(KEY, JSON.stringify(db)); }
function toast(s) { $('toast').textContent = s; $('toast').style.display = 'block'; setTimeout(() => $('toast').style.display = 'none', 3500); }
function log(s) { db.logs.unshift({ date: new Date().toLocaleString('pt-BR'), msg: s }); save(); }
function nav(v) { view = v; wizard = null; document.querySelectorAll('.side button').forEach(b => b.classList.toggle('active', b.dataset.view === v)); $('heading').textContent = ({ inicio: 'Visão geral', recebimento: 'Recebimento e armazenamento', expedicao: 'Pedidos e expedição', estoque: 'Posição de estoque', historico: 'Histórico e auditoria', ...Object.fromEntries(Object.entries(moduleDefs).map(([k, d]) => [k, d.title])), relatorios: 'Relatórios', config: 'Configurações' })[v]; render(); }
document.querySelectorAll('.side button').forEach(b => b.onclick = () => nav(b.dataset.view));
const now = () => new Date().toLocaleString('pt-BR');
function badge(x) { return '<span class="status ' + (/concluído|expedido|recebido/i.test(x) ? 'ok' : /pendente|análise/i.test(x) ? 'warn' : /bloqueado|reprovado|divergência|indisponível/i.test(x) ? 'bad' : '') + '">' + esc(x) + '</span>'; }
function render() {
    const n = db.operations.length, received = db.operations.filter(x => x.type === 'Recebimento' && x.status === 'Concluído').length, shipped = db.operations.filter(x => x.type === 'Expedição' && x.status === 'Concluído').length, issues = db.operations.filter(x => x.status !== 'Concluído').length;
    let h = '';
    if (view === 'inicio') {
        h = `<div class="cards"><div class="card"><span class="muted">Operações registradas</span><strong>${n}</strong></div><div class="card"><span class="muted">Recebimentos concluídos</span><strong>${received}</strong></div><div class="card"><span class="muted">Expedições concluídas</span><strong>${shipped}</strong></div><div class="card"><span class="muted">Pendências / bloqueios</span><strong>${issues}</strong></div></div><div class="panel"><h2>Escolha o processo</h2><p class="description">Os processos reproduzem as decisões e etapas previstas nos fluxogramas do projeto Depot Dynamics.</p><div class="choice"><button onclick="nav('recebimento')"><b>↓ Recebimento e armazenamento</b><span class="description">Validar pedido de compra, fornecedor, lote, aprovações e endereço antes de disponibilizar o estoque.</span></button><button onclick="nav('expedicao')"><b>↑ Pedido, separação e expedição</b><span class="description">Registrar pedido, conferir saldo, seguir FIFO, separar, conferir, expedir e registrar entrega ou devolução.</span></button></div></div><div class="panel"><div class="flex"><h2>Últimas operações</h2><button class="btn secondary" onclick="nav('historico')">Ver histórico</button></div>${tableOps(db.operations.slice(0, 5))}</div>`;
    }
    if (view === 'recebimento' || view === 'expedicao') {
        h = wizard ? renderWizard() : `<div class="panel"><h2>${view === 'recebimento' ? 'Registrar nova entrada' : 'Registrar novo pedido de expedição'}</h2><p class="description">O assistente orienta cada decisão do processo, mostrando bloqueios e pendências quando os requisitos não são atendidos.</p><button class="btn" onclick="start('${view}')">+ Iniciar ${view === 'recebimento' ? 'recebimento' : 'pedido'}</button></div><div class="panel"><h2>Operações deste processo</h2>${tableOps(db.operations.filter(x => x.type === (view === 'recebimento' ? 'Recebimento' : 'Expedição')).slice(0, 10))}</div>`;
    }
    if (view === 'estoque') {
        h = `<div class="panel"><div class="flex"><div><h2>Estoque disponível por produto e lote</h2><p class="description">Saldo local de demonstração atualizado ao concluir recebimentos e expedições.</p></div><button class="btn secondary" onclick="exportCSV()">Exportar CSV</button></div><div style="overflow-x:auto"><table><thead><tr><th>Código</th><th>Produto</th><th>Lote</th><th>Endereço</th><th>Quantidade</th><th>Situação</th></tr></thead><tbody>${db.stock.map(x => `<tr><td>${esc(x.id)}</td><td>${esc(x.name)}</td><td>${esc(x.lot)}</td><td>${esc(x.address)}</td><td>${x.qty}</td><td>${badge(x.blocked ? 'Bloqueado' : 'Disponível')}</td></tr>`).join('')}</tbody></table></div></div>`;
    }
    if (moduleDefs[view] || view === 'relatorios' || view === 'config') {
        h = renderModule(view);
    }
    if (view === 'historico') {
        h = `<div class="panel"><div class="flex"><h2>Rastreabilidade das operações</h2><button class="btn secondary" onclick="exportCSV()">Exportar estoque</button></div>${tableOps(db.operations)}</div><div class="panel"><h2>Trilha de eventos</h2><div class="history">${db.logs.length ? db.logs.map(x => `<p><time>${esc(x.date)}</time><br>${esc(x.msg)}</p>`).join('') : '<div class="empty">Nenhum evento registrado.</div>'}</div></div>`;
    }
    $('app').innerHTML = h;
}
function tableOps(list) { return list.length ? `<div style="overflow-x:auto"><table><thead><tr><th>ID</th><th>Processo</th><th>Produto</th><th>Quantidade</th><th>Status</th><th>Data</th></tr></thead><tbody>${list.map(x => `<tr><td>${esc(x.id)}</td><td>${esc(x.type)}</td><td>${esc(x.product)}</td><td>${x.qty}</td><td>${badge(x.status)}</td><td>${esc(x.date)}</td></tr>`).join('')}</tbody></table></div>` : '<div class="empty">Nenhuma operação registrada.</div>'; }
const phases = { recebimento: ['Mercadoria', 'Conferência', 'Regras e aprovações', 'Endereçamento', 'Confirmação'], expedicao: ['Pedido', 'Estoque e FIFO', 'Separação', 'Conferência e aprovação', 'Expedição e entrega'] };
function start(type) { wizard = { type, step: 0, form: {}, outcome: null }; render(); }
const field = (name, label, type = 'text', extra = '') => `<div class="field"><label for="${name}">${label}</label><input id="${name}" name="${name}" type="${type}" ${extra} required></div>`;
const sel = (name, label, options) => `<div class="field"><label for="${name}">${label}</label><select name="${name}" id="${name}">${options.map(([v, t]) => `<option value="${esc(v)}">${esc(t)}</option>`).join('')}</select></div>`;
function renderWizard() {
    const w = wizard, r = w.type === 'recebimento', p = phases[w.type], k = w.step;
    let f = '', info = '';
    if (r) {
        if (k === 0) {
            f = field('document', 'Pedido de compra / NF') + field('supplier', 'Fornecedor') + field('operator', 'Operador responsável');
            info = 'Receber mercadoria e consultar o pedido de compra associado.';
        }
        if (k === 1) {
            f = field('product', 'Descrição do produto') + field('sku', 'Código do produto') + field('lot', 'Lote') + field('qty', 'Quantidade recebida', 'number', 'min="1" step="1"') + sel('match', 'Pedido, fornecedor e itens conferem?', [['sim', 'Sim, conferem'], ['nao', 'Não, há divergência']]) + sel('conditions', 'Quantidades e condições estão corretas?', [['sim', 'Sim'], ['nao', 'Não']]);
            info = 'Em caso de divergência, a operação fica pendente para análise, sem entrada no estoque.';
        }
        if (k === 2) {
            f = field('validity', 'Data de validade', 'date') + sel('critical', 'Produto crítico ou operação de alto volume?', [['nao', 'Não'], ['sim', 'Sim']]) + sel('approval', 'Aprovação do supervisor (quando necessária)', [['sim', 'Aprovado'], ['pendente', 'Pendente'], ['nao', 'Reprovado']]) + sel('dangerous', 'Produto perigoso?', [['nao', 'Não'], ['sim', 'Sim']]) + sel('permission', 'Zona e operador autorizados?', [['sim', 'Sim'], ['nao', 'Não']]);
            info = 'Produtos críticos exigem aprovação; produtos perigosos exigem zona e acesso autorizados.';
        }
        if (k === 3) {
            f = field('address', 'Endereço de armazenagem (ex.: A-01-01)') + sel('capacity', 'Local adequado e com capacidade?', [['sim', 'Sim'], ['nao', 'Não']]);
            info = 'Selecionar local compatível e validar capacidade antes de confirmar o recebimento.';
        }
        if (k === 4) {
            f = sel('confirm', 'Confirmar recebimento e gerar movimentação rastreável?', [['sim', 'Sim, confirmar'], ['nao', 'Não, deixar pendente']]);
            info = 'Ao confirmar, serão criados o registro de entrada, o saldo por lote, o histórico de movimentação e a evidência demonstrativa.';
        }
    }
    else {
        if (k === 0) {
            f = field('document', 'Número do pedido de venda') + field('customer', 'Cliente') + field('operator', 'Responsável') + sel('product', 'Produto solicitado', db.stock.map((s, i) => [String(i), `${s.id} — ${s.name} | Lote ${s.lot} (${s.qty} un.)`])) + field('qty', 'Quantidade solicitada', 'number', 'min="1" step="1"');
            info = 'Registrar pedido de venda e validar itens e quantidades solicitadas.';
        }
        if (k === 1) {
            const s = db.stock[Number(w.form.product)];
            f = `<div class="field wide"><label>Produto e lote disponíveis</label><div class="notice">${esc(s?.name || '')} · ${esc(s?.lot || '')} · saldo atual ${s?.qty ?? 0} · ${s?.blocked ? 'BLOQUEADO' : 'Liberado'}</div></div>` + sel('fifo', 'Seleção respeita FIFO (lote mais antigo disponível)?', [['sim', 'Sim'], ['nao', 'Não, solicitar justificativa']]) + field('justification', 'Justificativa de exceção FIFO (se aplicável)') + sel('fifoApproval', 'Aprovação de exceção FIFO (se aplicável)', [['sim', 'Aprovada'], ['nao', 'Negada / pendente']]);
            info = 'O saldo é verificado no lote selecionado. Se insuficiente ou bloqueado, a operação é interrompida para tratamento.';
        }
        if (k === 2) {
            f = field('picked', 'Quantidade efetivamente separada', 'number', 'min="0" step="1"') + sel('restrictions', 'Há restrição ou bloqueio de estoque?', [['nao', 'Não'], ['sim', 'Sim']]);
            info = 'Gerar ordem de expedição e separar o material. Divergências de quantidade exigem conciliação.';
        }
        if (k === 3) {
            f = sel('checked', 'Itens conferidos e corretos?', [['sim', 'Sim'], ['nao', 'Não, registrar divergência']]) + sel('approvalRequired', 'Exige aprovação adicional?', [['nao', 'Não'], ['sim', 'Sim']]) + sel('approved', 'Resultado da aprovação (se exigida)', [['sim', 'Aprovado'], ['nao', 'Não aprovado']]);
            info = 'Conferência e eventual aprovação antecedem a liberação para expedição.';
        }
        if (k === 4) {
            f = field('carrier', 'Transportadora') + field('tracking', 'Código de rastreamento') + sel('delivered', 'Situação da entrega', [['entregue', 'Entregue'], ['transito', 'Em trânsito']]) + sel('returned', 'Houve devolução?', [['nao', 'Não'], ['sim', 'Sim, encaminhar para inspeção']]);
            info = 'A confirmação gera movimentação de saída, atualiza o estoque e registra dados de entrega. Devolução não retorna automaticamente ao saldo disponível.';
        }
    }
    return `<div class="panel"><button class="back" onclick="cancel()">← Voltar ao módulo</button><div class="flex" style="margin-top:20px"><h2>${r ? 'Novo recebimento' : 'Novo pedido de venda'}</h2><span class="muted">Etapa ${k + 1} de ${p.length}</span></div><div class="progress"><div style="width:${(k + 1) / p.length * 100}%"></div></div><div class="steps">${p.map((s, i) => `<span class="step ${i === k ? 'current' : i < k ? 'done' : ''}">${i + 1}. ${esc(s)}</span>`).join('')}</div><h2>${esc(p[k])}</h2><div class="notice">${info}</div><form id="wizardform"><div class="form">${f}</div><div class="actions"><button type="button" class="btn secondary" onclick="prev()" ${k === 0 ? 'disabled' : ''}>Voltar</button><button type="submit" class="btn">${k === 4 ? 'Finalizar operação' : 'Avançar →'}</button></div></form></div><div class="panel"><h2>Regras aplicadas</h2><p class="description">Recebimento: divergência → análise; criticidade → aprovação; produto perigoso → permissão; endereço sem capacidade → pendência. Expedição: saldo insuficiente → pendência; FIFO → justificativa; bloqueio → retenção; divergência → conciliação; aprovação negada → pendência; devolução → inspeção.</p></div>`;
}
function cancel() { wizard = null; render(); }
function prev() { if (wizard.step > 0) {
    wizard.step--;
    render();
    restore();
} }
function restore() { Object.entries(wizard.form).forEach(([k, v]) => { const e = document.getElementsByName(k)[0]; if (e)
    e.value = v; }); }
function stop(reason, status = 'Pendente de análise') { const w = wizard, r = w.type === 'recebimento'; const item = r ? w.form.product : db.stock[Number(w.form.product)]?.name; let op = { id: (r ? 'REC' : 'EXP') + '-' + Date.now().toString().slice(-9), type: r ? 'Recebimento' : 'Expedição', product: item || 'Não informado', qty: Number(w.form.qty) || 0, status, date: now(), data: { ...w.form }, reason }; db.operations.unshift(op); log(`${op.id}: ${reason}`); wizard = null; render(); toast('Operação registrada: ' + status); }
function finish() { const w = wizard, f = w.form, r = w.type === 'recebimento'; if (r) {
    if (f.confirm === 'nao') {
        stop('Recebimento não confirmado');
        return;
    }
    const same = db.stock.find(s => s.id === f.sku && s.lot === f.lot);
    if (same) {
        same.qty += Number(f.qty);
    }
    else {
        db.stock.push({ id: f.sku, name: f.product, lot: f.lot, qty: Number(f.qty), address: f.address, blocked: false });
    }
}
else {
    const s = db.stock[Number(f.product)];
    if (!s || s.qty < Number(f.qty)) {
        stop('Saldo alterado durante a operação');
        return;
    }
    s.qty -= Number(f.qty);
} let op = { id: (r ? 'REC' : 'EXP') + '-' + Date.now().toString().slice(-9), type: r ? 'Recebimento' : 'Expedição', product: r ? f.product : db.stock[Number(f.product)]?.name, qty: Number(f.qty), status: 'Concluído', date: now(), data: { ...f } }; db.operations.unshift(op); log(`${op.id}: ${r ? 'Recebimento confirmado e estoque atualizado' : 'Expedição confirmada e estoque baixado'}${!r && f.returned === 'sim' ? '; devolução encaminhada para inspeção' : ''}.`); wizard = null; render(); toast('Operação concluída com sucesso'); }
document.addEventListener('submit', e => { if (e.target.id !== 'wizardform')
    return; e.preventDefault(); const w = wizard, k = w.step, fd = new FormData(e.target); for (const [a, b] of fd.entries())
    w.form[a] = String(b).trim(); const f = w.form, r = w.type === 'recebimento'; if (r) {
    if (k === 1 && (f.match === 'nao' || f.conditions === 'nao')) {
        stop('Divergência no pedido, fornecedor, quantidade ou condições');
        return;
    }
    if (k === 2) {
        if (f.critical === 'sim' && f.approval !== 'sim') {
            stop('Produto crítico sem aprovação do supervisor', f.approval === 'nao' ? 'Reprovado' : 'Pendente de aprovação');
            return;
        }
        if (f.dangerous === 'sim' && f.permission !== 'sim') {
            stop('Produto perigoso sem zona ou acesso autorizado', 'Bloqueado');
            return;
        }
    }
    if (k === 3 && f.capacity === 'nao') {
        stop('Local sem capacidade ou incompatível; manter na área de recebimento');
        return;
    }
}
else {
    if (k === 1) {
        const s = db.stock[Number(f.product)];
        if (!s || s.qty < Number(f.qty)) {
            stop('Estoque insuficiente; pedido pendente de atendimento');
            return;
        }
        if (s.blocked) {
            stop('Bloqueio de estoque; pedido retido', 'Bloqueado');
            return;
        }
        if (f.fifo === 'nao' && (!f.justification || f.fifoApproval !== 'sim')) {
            stop('Exceção FIFO sem justificativa ou aprovação');
            return;
        }
    }
    if (k === 2) {
        if (f.restrictions === 'sim') {
            stop('Produto com restrição de separação', 'Bloqueado');
            return;
        }
        if (Number(f.picked) !== Number(f.qty)) {
            stop('Divergência de separação; conciliar quantidades');
            return;
        }
    }
    if (k === 3) {
        if (f.checked === 'nao') {
            stop('Divergência identificada na conferência');
            return;
        }
        if (f.approvalRequired === 'sim' && f.approved !== 'sim') {
            stop('Expedição pendente de autorização');
            return;
        }
    }
} if (k === 4) {
    finish();
    return;
} w.step++; render(); });
function exportCSV() { const rows = [['Codigo', 'Produto', 'Lote', 'Endereco', 'Quantidade', 'Bloqueado'], ...db.stock.map(x => [x.id, x.name, x.lot, x.address, x.qty, x.blocked ? 'Sim' : 'Nao'])]; const csv = '\uFEFF' + rows.map(r => r.map(x => '"' + String(x).replace(/"/g, '""') + '"').join(';')).join('\r\n'); const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' })); a.download = 'depot_estoque.csv'; a.click(); URL.revokeObjectURL(a.href); }
render();

