SET NOCOUNT ON;
GO
IF DB_ID(N'Depot_Dynamics') IS NULL CREATE DATABASE Depot_Dynamics;
GO
USE Depot_Dynamics;
GO

IF OBJECT_ID(N'Armazem', N'U') IS NULL
BEGIN
    CREATE TABLE Armazem
    (
        IdArmazem INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(100) NOT NULL,
        Descricao VARCHAR(255) NULL,
        Endereco VARCHAR(255) NOT NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Armazem PRIMARY KEY (IdArmazem)
    );
END;
GO

IF OBJECT_ID(N'Zona', N'U') IS NULL
BEGIN
    CREATE TABLE Zona
    (
        IdZona INT IDENTITY(1,1) NOT NULL,
        IdArmazem INT NOT NULL,
        Nome VARCHAR(100) NOT NULL,
        TipoZona VARCHAR(50) NOT NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Zona PRIMARY KEY (IdZona)
        ,CONSTRAINT CK_Zona_TipoZona CHECK (TipoZona IN ('Recebimento','Armazenagem','Separacao','Expedicao'))
    );
END;
GO

IF OBJECT_ID(N'Local', N'U') IS NULL
BEGIN
    CREATE TABLE Local
    (
        IdLocal INT IDENTITY(1,1) NOT NULL,
        IdZona INT NOT NULL,
        Codigo VARCHAR(50) NOT NULL,
        Descricao VARCHAR(255) NULL,
        Capacidade DECIMAL(12,2) NULL,
        CONSTRAINT CK_Local_Capacidade_NaoNegativo CHECK (Capacidade >= 0),
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Local PRIMARY KEY (IdLocal)
    );
END;
GO

IF OBJECT_ID(N'UnidadeMedida', N'U') IS NULL
BEGIN
    CREATE TABLE UnidadeMedida
    (
        IdUnidadeMedida INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(50) NOT NULL,
        Sigla VARCHAR(10) NOT NULL,
        Descricao VARCHAR(150) NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_UnidadeMedida PRIMARY KEY (IdUnidadeMedida)
    );
END;
GO

IF OBJECT_ID(N'Produto', N'U') IS NULL
BEGIN
    CREATE TABLE Produto
    (
        IdProduto INT IDENTITY(1,1) NOT NULL,
        Codigo VARCHAR(50) NOT NULL,
        Nome VARCHAR(150) NOT NULL,
        Descricao VARCHAR(500) NULL,
        IdUnidadeMedida INT NOT NULL,
        ControlaLote BIT NOT NULL,
        ProdutoPerigoso BIT NOT NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Produto PRIMARY KEY (IdProduto)
    );
END;
GO

IF OBJECT_ID(N'Lote', N'U') IS NULL
BEGIN
    CREATE TABLE Lote
    (
        IdLote INT IDENTITY(1,1) NOT NULL,
        IdProduto INT NOT NULL,
        CodigoLote VARCHAR(50) NOT NULL,
        DataFabricacao DATE NULL,
        DataValidade DATE NULL,
        QuantidadeInicial DECIMAL(12,3) NOT NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_Lote PRIMARY KEY (IdLote)
    );
END;
GO

IF OBJECT_ID(N'Usuario', N'U') IS NULL
BEGIN
    CREATE TABLE Usuario
    (
        IdUsuario INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(150) NOT NULL,
        Email VARCHAR(150) NOT NULL,
        Login VARCHAR(50) NOT NULL,
        SenhaHash VARCHAR(255) NOT NULL,
        Ativo BIT NOT NULL,
        DataCriacao DATETIME NOT NULL,
        UltimoAcesso DATETIME NULL
        ,CONSTRAINT PK_Usuario PRIMARY KEY (IdUsuario)
    );
END;
GO

IF OBJECT_ID(N'Perfil', N'U') IS NULL
BEGIN
    CREATE TABLE Perfil
    (
        IdPerfil INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(50) NOT NULL,
        Descricao VARCHAR(255) NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Perfil PRIMARY KEY (IdPerfil)
    );
END;
GO

IF OBJECT_ID(N'Permissao', N'U') IS NULL
BEGIN
    CREATE TABLE Permissao
    (
        IdPermissao INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(100) NOT NULL,
        Descricao VARCHAR(255) NULL,
        Modulo VARCHAR(80) NOT NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Permissao PRIMARY KEY (IdPermissao)
    );
END;
GO

IF OBJECT_ID(N'UsuarioPerfil', N'U') IS NULL
BEGIN
    CREATE TABLE UsuarioPerfil
    (
        IdUsuario INT NOT NULL,
        IdPerfil INT NOT NULL,
        DataAtribuicao DATETIME NOT NULL,
        IdUsuarioResponsavel INT NULL
        ,CONSTRAINT PK_UsuarioPerfil PRIMARY KEY (IdUsuario, IdPerfil)
    );
END;
GO

IF OBJECT_ID(N'PerfilPermissao', N'U') IS NULL
BEGIN
    CREATE TABLE PerfilPermissao
    (
        IdPerfil INT NOT NULL,
        IdPermissao INT NOT NULL,
        DataAtribuicao DATETIME NOT NULL
        ,CONSTRAINT PK_PerfilPermissao PRIMARY KEY (IdPerfil, IdPermissao)
    );
END;
GO

IF OBJECT_ID(N'Fornecedor', N'U') IS NULL
BEGIN
    CREATE TABLE Fornecedor
    (
        IdFornecedor INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(150) NOT NULL,
        Documento VARCHAR(20) NOT NULL,
        Email VARCHAR(150) NULL,
        Telefone VARCHAR(20) NULL,
        Endereco VARCHAR(255) NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Fornecedor PRIMARY KEY (IdFornecedor)
    );
END;
GO

IF OBJECT_ID(N'ProdutoFornecedor', N'U') IS NULL
BEGIN
    CREATE TABLE ProdutoFornecedor
    (
        IdProduto INT NOT NULL,
        IdFornecedor INT NOT NULL,
        CodigoProdutoFornecedor VARCHAR(50) NULL,
        PrecoUnitario DECIMAL(12,2) NULL,
        CONSTRAINT CK_ProdutoFornecedor_PrecoUnitario_NaoNegativo CHECK (PrecoUnitario >= 0),
        PrazoEntregaDias INT NULL
        ,CONSTRAINT PK_ProdutoFornecedor PRIMARY KEY (IdProduto, IdFornecedor)
    );
END;
GO

IF OBJECT_ID(N'PedidoCompra', N'U') IS NULL
BEGIN
    CREATE TABLE PedidoCompra
    (
        IdPedidoCompra INT IDENTITY(1,1) NOT NULL,
        IdFornecedor INT NOT NULL,
        IdUsuario INT NOT NULL,
        DataPedido DATETIME NOT NULL,
        DataPrevistaEntrega DATE NULL,
        Status VARCHAR(30) NOT NULL,
        Observacao VARCHAR(500) NULL
        ,CONSTRAINT PK_PedidoCompra PRIMARY KEY (IdPedidoCompra)
    );
END;
GO

IF OBJECT_ID(N'ItemPedidoCompra', N'U') IS NULL
BEGIN
    CREATE TABLE ItemPedidoCompra
    (
        IdItemPedidoCompra INT IDENTITY(1,1) NOT NULL,
        IdPedidoCompra INT NOT NULL,
        IdProduto INT NOT NULL,
        Quantidade DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemPedidoCompra_Quantidade_NaoNegativo CHECK (Quantidade >= 0),
        PrecoUnitario DECIMAL(12,2) NOT NULL,
        CONSTRAINT CK_ItemPedidoCompra_PrecoUnitario_NaoNegativo CHECK (PrecoUnitario >= 0),
        Observacao VARCHAR(255) NULL
        ,CONSTRAINT PK_ItemPedidoCompra PRIMARY KEY (IdItemPedidoCompra)
    );
END;
GO

IF OBJECT_ID(N'Entrada', N'U') IS NULL
BEGIN
    CREATE TABLE Entrada
    (
        IdEntrada INT IDENTITY(1,1) NOT NULL,
        IdPedidoCompra INT NULL,
        IdFornecedor INT NOT NULL,
        IdUsuario INT NOT NULL,
        DataEntrada DATETIME NOT NULL,
        NumeroDocumento VARCHAR(50) NULL,
        Status VARCHAR(30) NOT NULL,
        Observacao VARCHAR(500) NULL
        ,CONSTRAINT PK_Entrada PRIMARY KEY (IdEntrada)
    );
END;
GO

IF OBJECT_ID(N'ItemEntrada', N'U') IS NULL
BEGIN
    CREATE TABLE ItemEntrada
    (
        IdItemEntrada INT IDENTITY(1,1) NOT NULL,
        IdEntrada INT NOT NULL,
        IdProduto INT NOT NULL,
        IdLote INT NULL,
        QuantidadeRecebida DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemEntrada_QuantidadeRecebida_NaoNegativo CHECK (QuantidadeRecebida >= 0),
        QuantidadeAprovada DECIMAL(12,3) NULL,
        CONSTRAINT CK_ItemEntrada_QuantidadeAprovada_NaoNegativo CHECK (QuantidadeAprovada >= 0),
        QuantidadeRejeitada DECIMAL(12,3) NULL,
        CONSTRAINT CK_ItemEntrada_QuantidadeRejeitada_NaoNegativo CHECK (QuantidadeRejeitada >= 0),
        Observacao VARCHAR(255) NULL
        ,CONSTRAINT PK_ItemEntrada PRIMARY KEY (IdItemEntrada)
    );
END;
GO

IF OBJECT_ID(N'ParcelaEstoque', N'U') IS NULL
BEGIN
    CREATE TABLE ParcelaEstoque
    (
        IdParcelaEstoque BIGINT IDENTITY(1,1) NOT NULL,
        IdItemEntrada INT NOT NULL,
        IdLocal INT NOT NULL,
        QuantidadeDisponivel DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ParcelaEstoque_QuantidadeDisponivel_NaoNegativo CHECK (QuantidadeDisponivel >= 0),
        QuantidadeReservada DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ParcelaEstoque_QuantidadeReservada_NaoNegativo CHECK (QuantidadeReservada >= 0),
        DataEntradaEstoque DATETIME NOT NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_ParcelaEstoque PRIMARY KEY (IdParcelaEstoque)
    );
END;
GO

IF OBJECT_ID(N'Reserva', N'U') IS NULL
BEGIN
    CREATE TABLE Reserva
    (
        IdReserva BIGINT IDENTITY(1,1) NOT NULL,
        CodigoReserva VARCHAR(50) NOT NULL,
        IdUsuario INT NOT NULL,
        DataReserva DATETIME NOT NULL,
        DataExpiracao DATETIME NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_Reserva PRIMARY KEY (IdReserva)
    );
END;
GO

IF OBJECT_ID(N'ItemReserva', N'U') IS NULL
BEGIN
    CREATE TABLE ItemReserva
    (
        IdItemReserva BIGINT IDENTITY(1,1) NOT NULL,
        IdReserva BIGINT NOT NULL,
        IdProduto INT NOT NULL,
        QuantidadeSolicitada DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemReserva_QuantidadeSolicitada_NaoNegativo CHECK (QuantidadeSolicitada >= 0)
        ,CONSTRAINT PK_ItemReserva PRIMARY KEY (IdItemReserva)
    );
END;
GO

IF OBJECT_ID(N'AlocacaoReserva', N'U') IS NULL
BEGIN
    CREATE TABLE AlocacaoReserva
    (
        IdAlocacaoReserva BIGINT IDENTITY(1,1) NOT NULL,
        IdItemReserva BIGINT NOT NULL,
        IdParcelaEstoque BIGINT NOT NULL,
        QuantidadeAlocada DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_AlocacaoReserva_QuantidadeAlocada_NaoNegativo CHECK (QuantidadeAlocada >= 0)
        ,CONSTRAINT PK_AlocacaoReserva PRIMARY KEY (IdAlocacaoReserva)
    );
END;
GO

IF OBJECT_ID(N'BloqueioEstoque', N'U') IS NULL
BEGIN
    CREATE TABLE BloqueioEstoque
    (
        IdBloqueioEstoque BIGINT IDENTITY(1,1) NOT NULL,
        IdParcelaEstoque BIGINT NOT NULL,
        IdUsuario INT NOT NULL,
        Motivo VARCHAR(500) NOT NULL,
        DataBloqueio DATETIME NOT NULL,
        DataDesbloqueio DATETIME NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_BloqueioEstoque PRIMARY KEY (IdBloqueioEstoque)
    );
END;
GO

IF OBJECT_ID(N'Movimentacao', N'U') IS NULL
BEGIN
    CREATE TABLE Movimentacao
    (
        IdMovimentacao BIGINT IDENTITY(1,1) NOT NULL,
        CodigoMovimentacao VARCHAR(50) NOT NULL,
        TipoMovimentacao VARCHAR(30) NOT NULL,
        IdUsuario INT NOT NULL,
        DataMovimentacao DATETIME NOT NULL,
        Motivo VARCHAR(255) NULL,
        Status VARCHAR(30) NOT NULL,
        IdSolicitacaoAprovacao BIGINT NULL
        ,CONSTRAINT PK_Movimentacao PRIMARY KEY (IdMovimentacao)
    );
END;
GO

IF OBJECT_ID(N'ItemMovimentacao', N'U') IS NULL
BEGIN
    CREATE TABLE ItemMovimentacao
    (
        IdItemMovimentacao BIGINT IDENTITY(1,1) NOT NULL,
        IdMovimentacao BIGINT NOT NULL,
        IdParcelaEstoque BIGINT NOT NULL,
        IdLocalOrigem INT NULL,
        IdLocalDestino INT NULL,
        Quantidade DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemMovimentacao_Quantidade_NaoNegativo CHECK (Quantidade >= 0)
        ,CONSTRAINT PK_ItemMovimentacao PRIMARY KEY (IdItemMovimentacao)
    );
END;
GO

IF OBJECT_ID(N'Cliente', N'U') IS NULL
BEGIN
    CREATE TABLE Cliente
    (
        IdCliente INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(150) NOT NULL,
        Documento VARCHAR(20) NULL,
        Email VARCHAR(150) NULL,
        Telefone VARCHAR(20) NULL,
        Endereco VARCHAR(255) NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Cliente PRIMARY KEY (IdCliente)
    );
END;
GO

IF OBJECT_ID(N'Pedido', N'U') IS NULL
BEGIN
    CREATE TABLE Pedido
    (
        IdPedido BIGINT IDENTITY(1,1) NOT NULL,
        CodigoPedido VARCHAR(50) NOT NULL,
        IdCliente INT NOT NULL,
        DataPedido DATETIME NOT NULL,
        Status VARCHAR(30) NOT NULL,
        Observacao VARCHAR(500) NULL
        ,CONSTRAINT PK_Pedido PRIMARY KEY (IdPedido)
    );
END;
GO

IF OBJECT_ID(N'ItemPedido', N'U') IS NULL
BEGIN
    CREATE TABLE ItemPedido
    (
        IdItemPedido BIGINT IDENTITY(1,1) NOT NULL,
        IdPedido BIGINT NOT NULL,
        IdProduto INT NOT NULL,
        Quantidade DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemPedido_Quantidade_NaoNegativo CHECK (Quantidade >= 0),
        Observacao VARCHAR(255) NULL
        ,CONSTRAINT PK_ItemPedido PRIMARY KEY (IdItemPedido)
    );
END;
GO

IF OBJECT_ID(N'PedidoVenda', N'U') IS NULL
BEGIN
    CREATE TABLE PedidoVenda
    (
        IdPedidoVenda BIGINT IDENTITY(1,1) NOT NULL,
        IdPedido BIGINT NULL,
        NumeroPedidoVenda VARCHAR(50) NOT NULL,
        DataVenda DATETIME NOT NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_PedidoVenda PRIMARY KEY (IdPedidoVenda)
    );
END;
GO

IF OBJECT_ID(N'ItemPedidoVenda', N'U') IS NULL
BEGIN
    CREATE TABLE ItemPedidoVenda
    (
        IdItemPedidoVenda BIGINT IDENTITY(1,1) NOT NULL,
        IdPedidoVenda BIGINT NOT NULL,
        IdProduto INT NOT NULL,
        Quantidade DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemPedidoVenda_Quantidade_NaoNegativo CHECK (Quantidade >= 0)
        ,CONSTRAINT PK_ItemPedidoVenda PRIMARY KEY (IdItemPedidoVenda)
    );
END;
GO

IF OBJECT_ID(N'OrdemExpedicao', N'U') IS NULL
BEGIN
    CREATE TABLE OrdemExpedicao
    (
        IdOrdemExpedicao BIGINT IDENTITY(1,1) NOT NULL,
        CodigoOrdem VARCHAR(50) NOT NULL,
        IdPedido BIGINT NULL,
        IdUsuario INT NOT NULL,
        DataCriacao DATETIME NOT NULL,
        DataExpedicao DATETIME NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_OrdemExpedicao PRIMARY KEY (IdOrdemExpedicao)
    );
END;
GO

IF OBJECT_ID(N'ItemExpedicao', N'U') IS NULL
BEGIN
    CREATE TABLE ItemExpedicao
    (
        IdItemExpedicao BIGINT IDENTITY(1,1) NOT NULL,
        IdOrdemExpedicao BIGINT NOT NULL,
        IdProduto INT NOT NULL,
        Quantidade DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemExpedicao_Quantidade_NaoNegativo CHECK (Quantidade >= 0),
        IdParcelaEstoque BIGINT NULL
        ,CONSTRAINT PK_ItemExpedicao PRIMARY KEY (IdItemExpedicao)
    );
END;
GO

IF OBJECT_ID(N'Transportadora', N'U') IS NULL
BEGIN
    CREATE TABLE Transportadora
    (
        IdTransportadora INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(150) NOT NULL,
        Documento VARCHAR(20) NULL,
        Email VARCHAR(150) NULL,
        Telefone VARCHAR(20) NULL,
        Ativo BIT NOT NULL
        ,CONSTRAINT PK_Transportadora PRIMARY KEY (IdTransportadora)
    );
END;
GO

IF OBJECT_ID(N'Entrega', N'U') IS NULL
BEGIN
    CREATE TABLE Entrega
    (
        IdEntrega BIGINT IDENTITY(1,1) NOT NULL,
        IdOrdemExpedicao BIGINT NOT NULL,
        IdTransportadora INT NOT NULL,
        CodigoRastreamento VARCHAR(100) NULL,
        DataEnvio DATETIME NULL,
        PrevisaoEntrega DATETIME NULL,
        DataEntrega DATETIME NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_Entrega PRIMARY KEY (IdEntrega)
    );
END;
GO

IF OBJECT_ID(N'OcorrenciaEntrega', N'U') IS NULL
BEGIN
    CREATE TABLE OcorrenciaEntrega
    (
        IdOcorrenciaEntrega BIGINT IDENTITY(1,1) NOT NULL,
        IdEntrega BIGINT NOT NULL,
        DataOcorrencia DATETIME NOT NULL,
        TipoOcorrencia VARCHAR(50) NOT NULL,
        Descricao VARCHAR(500) NOT NULL,
        Localizacao VARCHAR(255) NULL
        ,CONSTRAINT PK_OcorrenciaEntrega PRIMARY KEY (IdOcorrenciaEntrega)
    );
END;
GO

IF OBJECT_ID(N'Devolucao', N'U') IS NULL
BEGIN
    CREATE TABLE Devolucao
    (
        IdDevolucao BIGINT IDENTITY(1,1) NOT NULL,
        IdPedido BIGINT NULL,
        IdUsuario INT NOT NULL,
        DataDevolucao DATETIME NOT NULL,
        Motivo VARCHAR(500) NOT NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_Devolucao PRIMARY KEY (IdDevolucao)
    );
END;
GO

IF OBJECT_ID(N'ItemDevolucao', N'U') IS NULL
BEGIN
    CREATE TABLE ItemDevolucao
    (
        IdItemDevolucao BIGINT IDENTITY(1,1) NOT NULL,
        IdDevolucao BIGINT NOT NULL,
        IdProduto INT NOT NULL,
        IdLote INT NULL,
        Quantidade DECIMAL(12,3) NOT NULL,
        CONSTRAINT CK_ItemDevolucao_Quantidade_NaoNegativo CHECK (Quantidade >= 0),
        CondicaoProduto VARCHAR(50) NULL
        ,CONSTRAINT PK_ItemDevolucao PRIMARY KEY (IdItemDevolucao)
    );
END;
GO

IF OBJECT_ID(N'SolicitacaoAprovacao', N'U') IS NULL
BEGIN
    CREATE TABLE SolicitacaoAprovacao
    (
        IdSolicitacaoAprovacao BIGINT IDENTITY(1,1) NOT NULL,
        TipoOperacao VARCHAR(50) NOT NULL,
        IdUsuarioSolicitante INT NOT NULL,
        DataSolicitacao DATETIME NOT NULL,
        Justificativa VARCHAR(1000) NOT NULL,
        Status VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_SolicitacaoAprovacao PRIMARY KEY (IdSolicitacaoAprovacao)
    );
END;
GO

IF OBJECT_ID(N'DecisaoAprovacao', N'U') IS NULL
BEGIN
    CREATE TABLE DecisaoAprovacao
    (
        IdDecisaoAprovacao BIGINT IDENTITY(1,1) NOT NULL,
        IdSolicitacaoAprovacao BIGINT NOT NULL,
        IdUsuarioAprovador INT NOT NULL,
        Decisao VARCHAR(30) NOT NULL,
        DataDecisao DATETIME NOT NULL,
        Observacao VARCHAR(500) NULL
        ,CONSTRAINT PK_DecisaoAprovacao PRIMARY KEY (IdDecisaoAprovacao)
        ,CONSTRAINT CK_DecisaoAprovacao_Decisao CHECK (Decisao IN ('Aprovada','Rejeitada'))
    );
END;
GO

IF OBJECT_ID(N'Auditoria', N'U') IS NULL
BEGIN
    CREATE TABLE Auditoria
    (
        IdAuditoria BIGINT IDENTITY(1,1) NOT NULL,
        IdUsuario INT NULL,
        TabelaAfetada VARCHAR(128) NOT NULL,
        IdRegistroAfetado VARCHAR(100) NOT NULL,
        Acao VARCHAR(30) NOT NULL,
        DataHora DATETIME NOT NULL,
        ValoresAnteriores NVARCHAR(MAX) NULL,
        ValoresNovos NVARCHAR(MAX) NULL,
        Justificativa VARCHAR(1000) NULL
        ,CONSTRAINT PK_Auditoria PRIMARY KEY (IdAuditoria)
        ,CONSTRAINT CK_Auditoria_Acao CHECK (Acao IN ('INSERT','UPDATE','DELETE'))
    );
END;
GO

IF OBJECT_ID(N'OperacaoRastreavel', N'U') IS NULL
BEGIN
    CREATE TABLE OperacaoRastreavel
    (
        IdOperacaoRastreavel BIGINT IDENTITY(1,1) NOT NULL,
        CodigoCorrelacao VARCHAR(100) NOT NULL,
        TipoOperacao VARCHAR(50) NOT NULL,
        IdUsuario INT NULL,
        DataHoraOperacao DATETIME NOT NULL,
        StatusRastreabilidade VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_OperacaoRastreavel PRIMARY KEY (IdOperacaoRastreavel)
    );
END;
GO

IF OBJECT_ID(N'EvidenciaOperacao', N'U') IS NULL
BEGIN
    CREATE TABLE EvidenciaOperacao
    (
        IdEvidenciaOperacao BIGINT IDENTITY(1,1) NOT NULL,
        IdOperacaoRastreavel BIGINT NOT NULL,
        HashEvidencia VARCHAR(256) NOT NULL,
        ReferenciaExterna VARCHAR(255) NULL,
        DataRegistro DATETIME NOT NULL,
        StatusConfirmacao VARCHAR(30) NOT NULL
        ,CONSTRAINT PK_EvidenciaOperacao PRIMARY KEY (IdEvidenciaOperacao)
    );
END;
GO

IF OBJECT_ID(N'TentativaEnvioEvidencia', N'U') IS NULL
BEGIN
    CREATE TABLE TentativaEnvioEvidencia
    (
        IdTentativaEnvio BIGINT IDENTITY(1,1) NOT NULL,
        IdEvidenciaOperacao BIGINT NOT NULL,
        DataTentativa DATETIME NOT NULL,
        Resultado VARCHAR(30) NOT NULL,
        MensagemErro NVARCHAR(1000) NULL,
        NumeroTentativa INT NOT NULL
        ,CONSTRAINT PK_TentativaEnvioEvidencia PRIMARY KEY (IdTentativaEnvio)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Zona_IdArmazem')
    ALTER TABLE Zona ADD CONSTRAINT FK_Zona_IdArmazem FOREIGN KEY (IdArmazem) REFERENCES Armazem (IdArmazem);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Local_IdZona')
    ALTER TABLE Local ADD CONSTRAINT FK_Local_IdZona FOREIGN KEY (IdZona) REFERENCES Zona (IdZona);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Produto_IdUnidadeMedida')
    ALTER TABLE Produto ADD CONSTRAINT FK_Produto_IdUnidadeMedida FOREIGN KEY (IdUnidadeMedida) REFERENCES UnidadeMedida (IdUnidadeMedida);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Lote_IdProduto')
    ALTER TABLE Lote ADD CONSTRAINT FK_Lote_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UsuarioPerfil_IdUsuario')
    ALTER TABLE UsuarioPerfil ADD CONSTRAINT FK_UsuarioPerfil_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UsuarioPerfil_IdPerfil')
    ALTER TABLE UsuarioPerfil ADD CONSTRAINT FK_UsuarioPerfil_IdPerfil FOREIGN KEY (IdPerfil) REFERENCES Perfil (IdPerfil);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PerfilPermissao_IdPerfil')
    ALTER TABLE PerfilPermissao ADD CONSTRAINT FK_PerfilPermissao_IdPerfil FOREIGN KEY (IdPerfil) REFERENCES Perfil (IdPerfil);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PerfilPermissao_IdPermissao')
    ALTER TABLE PerfilPermissao ADD CONSTRAINT FK_PerfilPermissao_IdPermissao FOREIGN KEY (IdPermissao) REFERENCES Permissao (IdPermissao);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ProdutoFornecedor_IdProduto')
    ALTER TABLE ProdutoFornecedor ADD CONSTRAINT FK_ProdutoFornecedor_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ProdutoFornecedor_IdFornecedor')
    ALTER TABLE ProdutoFornecedor ADD CONSTRAINT FK_ProdutoFornecedor_IdFornecedor FOREIGN KEY (IdFornecedor) REFERENCES Fornecedor (IdFornecedor);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PedidoCompra_IdFornecedor')
    ALTER TABLE PedidoCompra ADD CONSTRAINT FK_PedidoCompra_IdFornecedor FOREIGN KEY (IdFornecedor) REFERENCES Fornecedor (IdFornecedor);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PedidoCompra_IdUsuario')
    ALTER TABLE PedidoCompra ADD CONSTRAINT FK_PedidoCompra_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemPedidoCompra_IdPedidoCompra')
    ALTER TABLE ItemPedidoCompra ADD CONSTRAINT FK_ItemPedidoCompra_IdPedidoCompra FOREIGN KEY (IdPedidoCompra) REFERENCES PedidoCompra (IdPedidoCompra);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemPedidoCompra_IdProduto')
    ALTER TABLE ItemPedidoCompra ADD CONSTRAINT FK_ItemPedidoCompra_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Entrada_IdPedidoCompra')
    ALTER TABLE Entrada ADD CONSTRAINT FK_Entrada_IdPedidoCompra FOREIGN KEY (IdPedidoCompra) REFERENCES PedidoCompra (IdPedidoCompra);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Entrada_IdFornecedor')
    ALTER TABLE Entrada ADD CONSTRAINT FK_Entrada_IdFornecedor FOREIGN KEY (IdFornecedor) REFERENCES Fornecedor (IdFornecedor);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Entrada_IdUsuario')
    ALTER TABLE Entrada ADD CONSTRAINT FK_Entrada_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemEntrada_IdEntrada')
    ALTER TABLE ItemEntrada ADD CONSTRAINT FK_ItemEntrada_IdEntrada FOREIGN KEY (IdEntrada) REFERENCES Entrada (IdEntrada);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemEntrada_IdProduto')
    ALTER TABLE ItemEntrada ADD CONSTRAINT FK_ItemEntrada_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ParcelaEstoque_IdItemEntrada')
    ALTER TABLE ParcelaEstoque ADD CONSTRAINT FK_ParcelaEstoque_IdItemEntrada FOREIGN KEY (IdItemEntrada) REFERENCES ItemEntrada (IdItemEntrada);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Reserva_IdUsuario')
    ALTER TABLE Reserva ADD CONSTRAINT FK_Reserva_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemReserva_IdReserva')
    ALTER TABLE ItemReserva ADD CONSTRAINT FK_ItemReserva_IdReserva FOREIGN KEY (IdReserva) REFERENCES Reserva (IdReserva);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemReserva_IdProduto')
    ALTER TABLE ItemReserva ADD CONSTRAINT FK_ItemReserva_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_AlocacaoReserva_IdItemReserva')
    ALTER TABLE AlocacaoReserva ADD CONSTRAINT FK_AlocacaoReserva_IdItemReserva FOREIGN KEY (IdItemReserva) REFERENCES ItemReserva (IdItemReserva);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_AlocacaoReserva_IdParcelaEstoque')
    ALTER TABLE AlocacaoReserva ADD CONSTRAINT FK_AlocacaoReserva_IdParcelaEstoque FOREIGN KEY (IdParcelaEstoque) REFERENCES ParcelaEstoque (IdParcelaEstoque);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_BloqueioEstoque_IdParcelaEstoque')
    ALTER TABLE BloqueioEstoque ADD CONSTRAINT FK_BloqueioEstoque_IdParcelaEstoque FOREIGN KEY (IdParcelaEstoque) REFERENCES ParcelaEstoque (IdParcelaEstoque);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_BloqueioEstoque_IdUsuario')
    ALTER TABLE BloqueioEstoque ADD CONSTRAINT FK_BloqueioEstoque_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Movimentacao_IdUsuario')
    ALTER TABLE Movimentacao ADD CONSTRAINT FK_Movimentacao_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Movimentacao_IdSolicitacaoAprovacao')
    ALTER TABLE Movimentacao ADD CONSTRAINT FK_Movimentacao_IdSolicitacaoAprovacao FOREIGN KEY (IdSolicitacaoAprovacao) REFERENCES SolicitacaoAprovacao (IdSolicitacaoAprovacao);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemMovimentacao_IdMovimentacao')
    ALTER TABLE ItemMovimentacao ADD CONSTRAINT FK_ItemMovimentacao_IdMovimentacao FOREIGN KEY (IdMovimentacao) REFERENCES Movimentacao (IdMovimentacao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemMovimentacao_IdParcelaEstoque')
    ALTER TABLE ItemMovimentacao ADD CONSTRAINT FK_ItemMovimentacao_IdParcelaEstoque FOREIGN KEY (IdParcelaEstoque) REFERENCES ParcelaEstoque (IdParcelaEstoque);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Pedido_IdCliente')
    ALTER TABLE Pedido ADD CONSTRAINT FK_Pedido_IdCliente FOREIGN KEY (IdCliente) REFERENCES Cliente (IdCliente);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemPedido_IdPedido')
    ALTER TABLE ItemPedido ADD CONSTRAINT FK_ItemPedido_IdPedido FOREIGN KEY (IdPedido) REFERENCES Pedido (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemPedido_IdProduto')
    ALTER TABLE ItemPedido ADD CONSTRAINT FK_ItemPedido_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PedidoVenda_IdPedido')
    ALTER TABLE PedidoVenda ADD CONSTRAINT FK_PedidoVenda_IdPedido FOREIGN KEY (IdPedido) REFERENCES Pedido (IdPedido);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemPedidoVenda_IdPedidoVenda')
    ALTER TABLE ItemPedidoVenda ADD CONSTRAINT FK_ItemPedidoVenda_IdPedidoVenda FOREIGN KEY (IdPedidoVenda) REFERENCES PedidoVenda (IdPedidoVenda);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemPedidoVenda_IdProduto')
    ALTER TABLE ItemPedidoVenda ADD CONSTRAINT FK_ItemPedidoVenda_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_OrdemExpedicao_IdPedido')
    ALTER TABLE OrdemExpedicao ADD CONSTRAINT FK_OrdemExpedicao_IdPedido FOREIGN KEY (IdPedido) REFERENCES Pedido (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_OrdemExpedicao_IdUsuario')
    ALTER TABLE OrdemExpedicao ADD CONSTRAINT FK_OrdemExpedicao_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemExpedicao_IdOrdemExpedicao')
    ALTER TABLE ItemExpedicao ADD CONSTRAINT FK_ItemExpedicao_IdOrdemExpedicao FOREIGN KEY (IdOrdemExpedicao) REFERENCES OrdemExpedicao (IdOrdemExpedicao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemExpedicao_IdProduto')
    ALTER TABLE ItemExpedicao ADD CONSTRAINT FK_ItemExpedicao_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemExpedicao_IdParcelaEstoque')
    ALTER TABLE ItemExpedicao ADD CONSTRAINT FK_ItemExpedicao_IdParcelaEstoque FOREIGN KEY (IdParcelaEstoque) REFERENCES ParcelaEstoque (IdParcelaEstoque);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Entrega_IdOrdemExpedicao')
    ALTER TABLE Entrega ADD CONSTRAINT FK_Entrega_IdOrdemExpedicao FOREIGN KEY (IdOrdemExpedicao) REFERENCES OrdemExpedicao (IdOrdemExpedicao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Entrega_IdTransportadora')
    ALTER TABLE Entrega ADD CONSTRAINT FK_Entrega_IdTransportadora FOREIGN KEY (IdTransportadora) REFERENCES Transportadora (IdTransportadora);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_OcorrenciaEntrega_IdEntrega')
    ALTER TABLE OcorrenciaEntrega ADD CONSTRAINT FK_OcorrenciaEntrega_IdEntrega FOREIGN KEY (IdEntrega) REFERENCES Entrega (IdEntrega);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Devolucao_IdPedido')
    ALTER TABLE Devolucao ADD CONSTRAINT FK_Devolucao_IdPedido FOREIGN KEY (IdPedido) REFERENCES Pedido (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Devolucao_IdUsuario')
    ALTER TABLE Devolucao ADD CONSTRAINT FK_Devolucao_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemDevolucao_IdDevolucao')
    ALTER TABLE ItemDevolucao ADD CONSTRAINT FK_ItemDevolucao_IdDevolucao FOREIGN KEY (IdDevolucao) REFERENCES Devolucao (IdDevolucao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ItemDevolucao_IdProduto')
    ALTER TABLE ItemDevolucao ADD CONSTRAINT FK_ItemDevolucao_IdProduto FOREIGN KEY (IdProduto) REFERENCES Produto (IdProduto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_DecisaoAprovacao_IdSolicitacaoAprovacao')
    ALTER TABLE DecisaoAprovacao ADD CONSTRAINT FK_DecisaoAprovacao_IdSolicitacaoAprovacao FOREIGN KEY (IdSolicitacaoAprovacao) REFERENCES SolicitacaoAprovacao (IdSolicitacaoAprovacao);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Auditoria_IdUsuario')
    ALTER TABLE Auditoria ADD CONSTRAINT FK_Auditoria_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_OperacaoRastreavel_IdUsuario')
    ALTER TABLE OperacaoRastreavel ADD CONSTRAINT FK_OperacaoRastreavel_IdUsuario FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_EvidenciaOperacao_IdOperacaoRastreavel')
    ALTER TABLE EvidenciaOperacao ADD CONSTRAINT FK_EvidenciaOperacao_IdOperacaoRastreavel FOREIGN KEY (IdOperacaoRastreavel) REFERENCES OperacaoRastreavel (IdOperacaoRastreavel);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_TentativaEnvioEvidencia_IdEvidenciaOperacao')
    ALTER TABLE TentativaEnvioEvidencia ADD CONSTRAINT FK_TentativaEnvioEvidencia_IdEvidenciaOperacao FOREIGN KEY (IdEvidenciaOperacao) REFERENCES EvidenciaOperacao (IdEvidenciaOperacao);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Zona_IdArmazem' AND object_id = OBJECT_ID(N'Zona'))
    CREATE INDEX IX_Zona_IdArmazem ON Zona (IdArmazem);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Local_IdZona' AND object_id = OBJECT_ID(N'Local'))
    CREATE INDEX IX_Local_IdZona ON Local (IdZona);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Produto_IdUnidadeMedida' AND object_id = OBJECT_ID(N'Produto'))
    CREATE INDEX IX_Produto_IdUnidadeMedida ON Produto (IdUnidadeMedida);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Lote_IdProduto' AND object_id = OBJECT_ID(N'Lote'))
    CREATE INDEX IX_Lote_IdProduto ON Lote (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioPerfil_IdUsuario' AND object_id = OBJECT_ID(N'UsuarioPerfil'))
    CREATE INDEX IX_UsuarioPerfil_IdUsuario ON UsuarioPerfil (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioPerfil_IdPerfil' AND object_id = OBJECT_ID(N'UsuarioPerfil'))
    CREATE INDEX IX_UsuarioPerfil_IdPerfil ON UsuarioPerfil (IdPerfil);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioPerfil_IdUsuarioResponsavel' AND object_id = OBJECT_ID(N'UsuarioPerfil'))
    CREATE INDEX IX_UsuarioPerfil_IdUsuarioResponsavel ON UsuarioPerfil (IdUsuarioResponsavel);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PerfilPermissao_IdPerfil' AND object_id = OBJECT_ID(N'PerfilPermissao'))
    CREATE INDEX IX_PerfilPermissao_IdPerfil ON PerfilPermissao (IdPerfil);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PerfilPermissao_IdPermissao' AND object_id = OBJECT_ID(N'PerfilPermissao'))
    CREATE INDEX IX_PerfilPermissao_IdPermissao ON PerfilPermissao (IdPermissao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProdutoFornecedor_IdProduto' AND object_id = OBJECT_ID(N'ProdutoFornecedor'))
    CREATE INDEX IX_ProdutoFornecedor_IdProduto ON ProdutoFornecedor (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProdutoFornecedor_IdFornecedor' AND object_id = OBJECT_ID(N'ProdutoFornecedor'))
    CREATE INDEX IX_ProdutoFornecedor_IdFornecedor ON ProdutoFornecedor (IdFornecedor);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PedidoCompra_IdFornecedor' AND object_id = OBJECT_ID(N'PedidoCompra'))
    CREATE INDEX IX_PedidoCompra_IdFornecedor ON PedidoCompra (IdFornecedor);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PedidoCompra_IdUsuario' AND object_id = OBJECT_ID(N'PedidoCompra'))
    CREATE INDEX IX_PedidoCompra_IdUsuario ON PedidoCompra (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemPedidoCompra_IdPedidoCompra' AND object_id = OBJECT_ID(N'ItemPedidoCompra'))
    CREATE INDEX IX_ItemPedidoCompra_IdPedidoCompra ON ItemPedidoCompra (IdPedidoCompra);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemPedidoCompra_IdProduto' AND object_id = OBJECT_ID(N'ItemPedidoCompra'))
    CREATE INDEX IX_ItemPedidoCompra_IdProduto ON ItemPedidoCompra (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Entrada_IdPedidoCompra' AND object_id = OBJECT_ID(N'Entrada'))
    CREATE INDEX IX_Entrada_IdPedidoCompra ON Entrada (IdPedidoCompra);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Entrada_IdFornecedor' AND object_id = OBJECT_ID(N'Entrada'))
    CREATE INDEX IX_Entrada_IdFornecedor ON Entrada (IdFornecedor);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Entrada_IdUsuario' AND object_id = OBJECT_ID(N'Entrada'))
    CREATE INDEX IX_Entrada_IdUsuario ON Entrada (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemEntrada_IdEntrada' AND object_id = OBJECT_ID(N'ItemEntrada'))
    CREATE INDEX IX_ItemEntrada_IdEntrada ON ItemEntrada (IdEntrada);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemEntrada_IdProduto' AND object_id = OBJECT_ID(N'ItemEntrada'))
    CREATE INDEX IX_ItemEntrada_IdProduto ON ItemEntrada (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemEntrada_IdLote' AND object_id = OBJECT_ID(N'ItemEntrada'))
    CREATE INDEX IX_ItemEntrada_IdLote ON ItemEntrada (IdLote);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ParcelaEstoque_IdItemEntrada' AND object_id = OBJECT_ID(N'ParcelaEstoque'))
    CREATE INDEX IX_ParcelaEstoque_IdItemEntrada ON ParcelaEstoque (IdItemEntrada);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ParcelaEstoque_IdLocal' AND object_id = OBJECT_ID(N'ParcelaEstoque'))
    CREATE INDEX IX_ParcelaEstoque_IdLocal ON ParcelaEstoque (IdLocal);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Reserva_IdUsuario' AND object_id = OBJECT_ID(N'Reserva'))
    CREATE INDEX IX_Reserva_IdUsuario ON Reserva (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemReserva_IdReserva' AND object_id = OBJECT_ID(N'ItemReserva'))
    CREATE INDEX IX_ItemReserva_IdReserva ON ItemReserva (IdReserva);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemReserva_IdProduto' AND object_id = OBJECT_ID(N'ItemReserva'))
    CREATE INDEX IX_ItemReserva_IdProduto ON ItemReserva (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AlocacaoReserva_IdItemReserva' AND object_id = OBJECT_ID(N'AlocacaoReserva'))
    CREATE INDEX IX_AlocacaoReserva_IdItemReserva ON AlocacaoReserva (IdItemReserva);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AlocacaoReserva_IdParcelaEstoque' AND object_id = OBJECT_ID(N'AlocacaoReserva'))
    CREATE INDEX IX_AlocacaoReserva_IdParcelaEstoque ON AlocacaoReserva (IdParcelaEstoque);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BloqueioEstoque_IdParcelaEstoque' AND object_id = OBJECT_ID(N'BloqueioEstoque'))
    CREATE INDEX IX_BloqueioEstoque_IdParcelaEstoque ON BloqueioEstoque (IdParcelaEstoque);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BloqueioEstoque_IdUsuario' AND object_id = OBJECT_ID(N'BloqueioEstoque'))
    CREATE INDEX IX_BloqueioEstoque_IdUsuario ON BloqueioEstoque (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Movimentacao_IdUsuario' AND object_id = OBJECT_ID(N'Movimentacao'))
    CREATE INDEX IX_Movimentacao_IdUsuario ON Movimentacao (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Movimentacao_IdSolicitacaoAprovacao' AND object_id = OBJECT_ID(N'Movimentacao'))
    CREATE INDEX IX_Movimentacao_IdSolicitacaoAprovacao ON Movimentacao (IdSolicitacaoAprovacao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemMovimentacao_IdMovimentacao' AND object_id = OBJECT_ID(N'ItemMovimentacao'))
    CREATE INDEX IX_ItemMovimentacao_IdMovimentacao ON ItemMovimentacao (IdMovimentacao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemMovimentacao_IdParcelaEstoque' AND object_id = OBJECT_ID(N'ItemMovimentacao'))
    CREATE INDEX IX_ItemMovimentacao_IdParcelaEstoque ON ItemMovimentacao (IdParcelaEstoque);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemMovimentacao_IdLocalOrigem' AND object_id = OBJECT_ID(N'ItemMovimentacao'))
    CREATE INDEX IX_ItemMovimentacao_IdLocalOrigem ON ItemMovimentacao (IdLocalOrigem);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemMovimentacao_IdLocalDestino' AND object_id = OBJECT_ID(N'ItemMovimentacao'))
    CREATE INDEX IX_ItemMovimentacao_IdLocalDestino ON ItemMovimentacao (IdLocalDestino);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Pedido_IdCliente' AND object_id = OBJECT_ID(N'Pedido'))
    CREATE INDEX IX_Pedido_IdCliente ON Pedido (IdCliente);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemPedido_IdPedido' AND object_id = OBJECT_ID(N'ItemPedido'))
    CREATE INDEX IX_ItemPedido_IdPedido ON ItemPedido (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemPedido_IdProduto' AND object_id = OBJECT_ID(N'ItemPedido'))
    CREATE INDEX IX_ItemPedido_IdProduto ON ItemPedido (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PedidoVenda_IdPedido' AND object_id = OBJECT_ID(N'PedidoVenda'))
    CREATE INDEX IX_PedidoVenda_IdPedido ON PedidoVenda (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemPedidoVenda_IdPedidoVenda' AND object_id = OBJECT_ID(N'ItemPedidoVenda'))
    CREATE INDEX IX_ItemPedidoVenda_IdPedidoVenda ON ItemPedidoVenda (IdPedidoVenda);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemPedidoVenda_IdProduto' AND object_id = OBJECT_ID(N'ItemPedidoVenda'))
    CREATE INDEX IX_ItemPedidoVenda_IdProduto ON ItemPedidoVenda (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdemExpedicao_IdPedido' AND object_id = OBJECT_ID(N'OrdemExpedicao'))
    CREATE INDEX IX_OrdemExpedicao_IdPedido ON OrdemExpedicao (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrdemExpedicao_IdUsuario' AND object_id = OBJECT_ID(N'OrdemExpedicao'))
    CREATE INDEX IX_OrdemExpedicao_IdUsuario ON OrdemExpedicao (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemExpedicao_IdOrdemExpedicao' AND object_id = OBJECT_ID(N'ItemExpedicao'))
    CREATE INDEX IX_ItemExpedicao_IdOrdemExpedicao ON ItemExpedicao (IdOrdemExpedicao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemExpedicao_IdProduto' AND object_id = OBJECT_ID(N'ItemExpedicao'))
    CREATE INDEX IX_ItemExpedicao_IdProduto ON ItemExpedicao (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemExpedicao_IdParcelaEstoque' AND object_id = OBJECT_ID(N'ItemExpedicao'))
    CREATE INDEX IX_ItemExpedicao_IdParcelaEstoque ON ItemExpedicao (IdParcelaEstoque);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Entrega_IdOrdemExpedicao' AND object_id = OBJECT_ID(N'Entrega'))
    CREATE INDEX IX_Entrega_IdOrdemExpedicao ON Entrega (IdOrdemExpedicao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Entrega_IdTransportadora' AND object_id = OBJECT_ID(N'Entrega'))
    CREATE INDEX IX_Entrega_IdTransportadora ON Entrega (IdTransportadora);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OcorrenciaEntrega_IdEntrega' AND object_id = OBJECT_ID(N'OcorrenciaEntrega'))
    CREATE INDEX IX_OcorrenciaEntrega_IdEntrega ON OcorrenciaEntrega (IdEntrega);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Devolucao_IdPedido' AND object_id = OBJECT_ID(N'Devolucao'))
    CREATE INDEX IX_Devolucao_IdPedido ON Devolucao (IdPedido);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Devolucao_IdUsuario' AND object_id = OBJECT_ID(N'Devolucao'))
    CREATE INDEX IX_Devolucao_IdUsuario ON Devolucao (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemDevolucao_IdDevolucao' AND object_id = OBJECT_ID(N'ItemDevolucao'))
    CREATE INDEX IX_ItemDevolucao_IdDevolucao ON ItemDevolucao (IdDevolucao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemDevolucao_IdProduto' AND object_id = OBJECT_ID(N'ItemDevolucao'))
    CREATE INDEX IX_ItemDevolucao_IdProduto ON ItemDevolucao (IdProduto);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ItemDevolucao_IdLote' AND object_id = OBJECT_ID(N'ItemDevolucao'))
    CREATE INDEX IX_ItemDevolucao_IdLote ON ItemDevolucao (IdLote);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SolicitacaoAprovacao_IdUsuarioSolicitante' AND object_id = OBJECT_ID(N'SolicitacaoAprovacao'))
    CREATE INDEX IX_SolicitacaoAprovacao_IdUsuarioSolicitante ON SolicitacaoAprovacao (IdUsuarioSolicitante);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DecisaoAprovacao_IdSolicitacaoAprovacao' AND object_id = OBJECT_ID(N'DecisaoAprovacao'))
    CREATE INDEX IX_DecisaoAprovacao_IdSolicitacaoAprovacao ON DecisaoAprovacao (IdSolicitacaoAprovacao);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DecisaoAprovacao_IdUsuarioAprovador' AND object_id = OBJECT_ID(N'DecisaoAprovacao'))
    CREATE INDEX IX_DecisaoAprovacao_IdUsuarioAprovador ON DecisaoAprovacao (IdUsuarioAprovador);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Auditoria_IdUsuario' AND object_id = OBJECT_ID(N'Auditoria'))
    CREATE INDEX IX_Auditoria_IdUsuario ON Auditoria (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OperacaoRastreavel_IdUsuario' AND object_id = OBJECT_ID(N'OperacaoRastreavel'))
    CREATE INDEX IX_OperacaoRastreavel_IdUsuario ON OperacaoRastreavel (IdUsuario);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_EvidenciaOperacao_IdOperacaoRastreavel' AND object_id = OBJECT_ID(N'EvidenciaOperacao'))
    CREATE INDEX IX_EvidenciaOperacao_IdOperacaoRastreavel ON EvidenciaOperacao (IdOperacaoRastreavel);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TentativaEnvioEvidencia_IdEvidenciaOperacao' AND object_id = OBJECT_ID(N'TentativaEnvioEvidencia'))
    CREATE INDEX IX_TentativaEnvioEvidencia_IdEvidenciaOperacao ON TentativaEnvioEvidencia (IdEvidenciaOperacao);
GO

DECLARE @Schema NVARCHAR(128);
DECLARE @Tabela NVARCHAR(128);
DECLARE @IdObjeto INT;
DECLARE @Chaves NVARCHAR(MAX);
DECLARE @Condicao NVARCHAR(MAX);
DECLARE @ChaveInserida NVARCHAR(MAX);
DECLARE @ChaveExcluida NVARCHAR(MAX);
DECLARE @ColunaChave NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @NomeTrigger NVARCHAR(128);

DECLARE CursorTabelas CURSOR LOCAL FAST_FORWARD FOR
SELECT s.name, t.name, t.object_id
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.name <> N'Auditoria'
AND EXISTS (
    SELECT 1
    FROM sys.indexes ix
    WHERE ix.object_id = t.object_id
    AND ix.is_primary_key = 1
)
ORDER BY s.name, t.name;

OPEN CursorTabelas;

FETCH NEXT FROM CursorTabelas
INTO @Schema, @Tabela, @IdObjeto;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @Condicao = STUFF((
        SELECT N' AND i.' + QUOTENAME(c.name)
             + N' = d.' + QUOTENAME(c.name)
        FROM sys.indexes ix
        INNER JOIN sys.index_columns ic
            ON ic.object_id = ix.object_id
            AND ic.index_id = ix.index_id
        INNER JOIN sys.columns c
            ON c.object_id = ic.object_id
            AND c.column_id = ic.column_id
        WHERE ix.object_id = @IdObjeto
        AND ix.is_primary_key = 1
        ORDER BY ic.key_ordinal
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 5, N'');

    SELECT @Chaves = STUFF((
        SELECT N', i.' + QUOTENAME(c.name)
        FROM sys.indexes ix
        INNER JOIN sys.index_columns ic
            ON ic.object_id = ix.object_id
            AND ic.index_id = ix.index_id
        INNER JOIN sys.columns c
            ON c.object_id = ic.object_id
            AND c.column_id = ic.column_id
        WHERE ix.object_id = @IdObjeto
        AND ix.is_primary_key = 1
        ORDER BY ic.key_ordinal
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, N'');

    SELECT TOP (1) @ColunaChave = c.name
    FROM sys.indexes ix
    INNER JOIN sys.index_columns ic
        ON ic.object_id = ix.object_id
        AND ic.index_id = ix.index_id
    INNER JOIN sys.columns c
        ON c.object_id = ic.object_id
        AND c.column_id = ic.column_id
    WHERE ix.object_id = @IdObjeto
    AND ix.is_primary_key = 1
    ORDER BY ic.key_ordinal;

    SET @ChaveInserida =
        N'CONVERT(NVARCHAR(100), (SELECT ' + @Chaves
        + N' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))';

    SET @Chaves = REPLACE(@Chaves, N'i.', N'd.');

    SET @ChaveExcluida =
        N'CONVERT(NVARCHAR(100), (SELECT ' + @Chaves
        + N' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))';

    SET @NomeTrigger = N'trg_Auditoria_' + @Tabela;

    SET @SQL =
        N'CREATE OR ALTER TRIGGER '
        + QUOTENAME(@Schema) + N'.' + QUOTENAME(@NomeTrigger)
        + N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Tabela)
        + N' AFTER INSERT, UPDATE, DELETE AS
        BEGIN
            SET NOCOUNT ON;

            DECLARE @IdUsuario INT =
                TRY_CONVERT(INT, SESSION_CONTEXT(N''IdUsuario''));

            INSERT INTO Auditoria
                (IdUsuario, TabelaAfetada, IdRegistroAfetado,
                 Acao, DataHora, ValoresAnteriores, ValoresNovos,
                 Justificativa)
            SELECT
                @IdUsuario,
                N''' + REPLACE(@Tabela, N'''', N'''''') + N''',
                ' + @ChaveInserida + N',
                N''INSERT'',
                SYSDATETIME(),
                NULL,
                (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES),
                NULL
            FROM inserted i
            LEFT JOIN deleted d ON ' + @Condicao + N'
            WHERE d.' + QUOTENAME(@ColunaChave) + N' IS NULL;

            INSERT INTO Auditoria
                (IdUsuario, TabelaAfetada, IdRegistroAfetado,
                 Acao, DataHora, ValoresAnteriores, ValoresNovos,
                 Justificativa)
            SELECT
                @IdUsuario,
                N''' + REPLACE(@Tabela, N'''', N'''''') + N''',
                ' + @ChaveExcluida + N',
                N''DELETE'',
                SYSDATETIME(),
                (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES),
                NULL,
                NULL
            FROM deleted d
            LEFT JOIN inserted i ON ' + @Condicao + N'
            WHERE i.' + QUOTENAME(@ColunaChave) + N' IS NULL;

            INSERT INTO Auditoria
                (IdUsuario, TabelaAfetada, IdRegistroAfetado,
                 Acao, DataHora, ValoresAnteriores, ValoresNovos,
                 Justificativa)
            SELECT
                @IdUsuario,
                N''' + REPLACE(@Tabela, N'''', N'''''') + N''',
                ' + @ChaveInserida + N',
                N''UPDATE'',
                SYSDATETIME(),
                (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES),
                (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES),
                NULL
            FROM inserted i
            INNER JOIN deleted d ON ' + @Condicao + N';
        END;';

    EXEC sys.sp_executesql @SQL;

    FETCH NEXT FROM CursorTabelas
    INTO @Schema, @Tabela, @IdObjeto;
END;

CLOSE CursorTabelas;
DEALLOCATE CursorTabelas;
