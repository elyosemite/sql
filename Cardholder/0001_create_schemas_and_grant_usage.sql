-- ============================================================================
-- MIGRATION #1: Inicialização de Schemas e Tabelas Core
-- ============================================================================
-- Descrição: Cria schemas organizacionais, habilita extensões necessárias,
--            cria tabelas de billing e workspaces com RLS configurado.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PARTE 1: EXTENSÕES
-- ----------------------------------------------------------------------------
-- uuid-ossp: Para gerar UUIDs automaticamente (uuid_generate_v4())
-- pgcrypto: Para funções de criptografia (caso precise no futuro)
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------------
-- PARTE 2: CRIAÇÃO DE SCHEMAS
-- ----------------------------------------------------------------------------
-- billing: Tudo relacionado a pagamentos, planos, assinaturas
-- content: Workspaces, decks, flashcards (conteúdo do usuário)
-- analytics: Métricas, sessões de estudo, reviews
-- ----------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS content;
CREATE SCHEMA IF NOT EXISTS analytics;

-- ----------------------------------------------------------------------------
-- PARTE 3: PERMISSÕES DE SCHEMAS (GRANT USAGE)
-- ----------------------------------------------------------------------------
-- USAGE: Permite que o role "use" o schema (pré-requisito para acessar tabelas)
-- Sem isso, mesmo com GRANT nas tabelas, vai dar "permission denied for schema"
-- ----------------------------------------------------------------------------
GRANT USAGE ON SCHEMA billing TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA content TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA analytics TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- PARTE 4: PERMISSÕES PADRÃO (ALTER DEFAULT PRIVILEGES)
-- ----------------------------------------------------------------------------
-- Define permissões automáticas para TODAS as tabelas futuras criadas no schema
-- Assim você não precisa dar GRANT manualmente em cada migration
-- ----------------------------------------------------------------------------

-- Schema BILLING: anon e authenticated podem LER (planos são públicos)
ALTER DEFAULT PRIVILEGES IN SCHEMA billing
    GRANT SELECT ON TABLES TO anon, authenticated;

-- Schema CONTENT: authenticated pode TUDO (criar/ler/atualizar workspaces/decks)
ALTER DEFAULT PRIVILEGES IN SCHEMA content
    GRANT ALL ON TABLES TO authenticated;

-- Schema ANALYTICS: authenticated pode LER suas métricas
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT SELECT ON TABLES TO authenticated;

-- service_role SEMPRE pode tudo (admin) em todos os schemas
ALTER DEFAULT PRIVILEGES IN SCHEMA billing
    GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA content
    GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
    GRANT ALL ON TABLES TO service_role;

-- ----------------------------------------------------------------------------
-- TABELA 1: billing.subscription_plans
-- ----------------------------------------------------------------------------
-- Armazena os planos disponíveis: free, premium, pro
-- Esta tabela é PÚBLICA (qualquer um pode ver os planos)
-- Apenas admins (service_role) podem criar/editar
-- ----------------------------------------------------------------------------
CREATE TABLE billing.subscription_plans
(
    id                       UUID PRIMARY KEY     DEFAULT uuid_generate_v4(),
    plan_code                TEXT        NOT NULL UNIQUE CHECK (plan_code IN ('free', 'premium', 'pro')),
    display_name             TEXT        NOT NULL,
    description              TEXT,
    price_cents              INTEGER     NOT NULL DEFAULT 0,
    currency                 TEXT        NOT NULL DEFAULT 'BRL',
    max_workspaces           INTEGER,
    max_decks_per_workspaces INTEGER,
    max_flashcards_per_decks INTEGER,
    features                 JSON                 DEFAULT '{}'::json,
    is_active                BOOLEAN     NOT NULL DEFAULT true,
    created_adt              timestamptz NOT NULL default now(),
    updated_adt              timestamptz NOT NULL default now()
);

-- Índice para buscar planos ativos rapidamente
CREATE INDEX idx_subscription_plans_active ON billing.subscription_plans (is_active)
    WHERE is_active = true;

-- RLS: billing.subscription_plans
ALTER TABLE billing.subscription_plans
    ENABLE ROW LEVEL SECURITY;

-- Policy 1: Qualquer um (até não-logados) pode VER planos ativos
CREATE POLICY "public_read_active_plans"
    ON billing.subscription_plans
    FOR SELECT
    TO anon, authenticated
    USING (is_active = true);
-- Só mostra planos ativos

-- Policy 2: service_role pode tudo (criar, editar, desativar planos)
CREATE POLICY "admin_manage_plans"
    ON billing.subscription_plans
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ----------------------------------------------------------------------------
-- TABELA 2: billing.user_subscriptions
-- ----------------------------------------------------------------------------
-- Armazena a assinatura ATUAL de cada usuário
-- Relacionamento: 1 usuário = 1 assinatura ativa (pode ter histórico)
-- Apenas o próprio usuário pode VER sua assinatura
-- ----------------------------------------------------------------------------
CREATE table billing.user_subscriptions
(
    id                       uuid primary key     default uuid_generate_v4(),
    user_id                  uuid        not null references auth.users (id) on delete cascade,
    plan_id                  uuid        not null references billing.subscription_plans (id),
    status                   text        not null default 'active'
        check (status in ('active', 'canceled', 'expired', 'past_due')),
    started_at               timestamptz not null default now(),
    expires_at               timestamptz,
    canceled_at              timestamptz,
    external_subscription_id text,
    payment_provider         text,
    created_at               timestamptz not null default now(),
    updated_At               timestamptz not null default now(),

    -- CONSTRIANT: 1 usuário só pode ter 1 assinatura ativa por vez
    UNIQUE (user_id, status)
        deferrable initially deferred -- permite trocar de plano atomicamente
);

-- Índice para buscar assinatura ativa do usuário (query mais comum)
CREATE INDEX idx_user_subscriptions_user_active
    ON billing.user_subscriptions (user_id, status)
    WHERE status = 'active';

-- Índice para buscar por external_subscription_id (webhooks de pagamento)
CREATE INDEX idx_user_subscriptions_external
    ON billing.user_subscriptions (external_subscription_id, payment_provider)
    WHERE external_subscription_id IS NOT NULL;

-- RLS: billing.user_subscriptions
ALTER TABLE billing.user_subscriptions
    enable row level security;

-- Policy 1: Usuário pode VER apenas sua própria assinatura
create policy "select_own_subscription"
    on billing.user_subscriptions
    for select
    to authenticated
    using (user_id = auth.uid());

-- Policy 2: Apenas service_role pode CRIAR/ATUALIZAR assinaturas
-- (Mudanças de plano são feitas via backend após validação de pagamento)
CREATE POLICY "admin_manage_subscriptions"
    ON billing.user_subscriptions
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ----------------------------------------------------------------------------
-- TABELA 3: content.workspaces
-- ----------------------------------------------------------------------------
-- Workspace = agrupamento top-level (Medicina, Engenharia, etc)
-- Cada workspace pertence a UM usuário
-- Suporta soft-delete (deleted_at)
-- ----------------------------------------------------------------------------
CREATE TABLE content.workspaces
(
    id          UUID PRIMARY KEY     DEFAULT uuid_generate_v4(),

    -- Dono do workspace
    user_id     UUID        NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

    -- Dados do workspace
    name        TEXT        NOT NULL,
    description TEXT,
    color       TEXT, -- hex color para UI (#FF5733)
    icon        TEXT, -- emoji ou icon name

    -- Ordenação customizada pelo usuário
    sort_order  INTEGER     NOT NULL DEFAULT 0,

    -- Workspace padrão (cada usuário tem 1 default)
    is_default  BOOLEAN     NOT NULL DEFAULT false,

    -- Soft-delete
    deleted_at  TIMESTAMPTZ,

    -- Auditoria
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índice para listar workspaces ativos do usuário (query mais comum)
CREATE INDEX idx_workspaces_user_active
    ON content.workspaces (user_id, sort_order)
    WHERE deleted_at IS NULL;

-- Índice para encontrar workspace default rapidamente
CREATE INDEX idx_workspaces_user_default
    ON content.workspaces (user_id)
    WHERE is_default = true AND deleted_at IS NULL;

-- CONSTRAINT: Apenas 1 workspace default por usuário
CREATE UNIQUE INDEX uniq_workspaces_user_default
    ON content.workspaces (user_id)
    WHERE is_default = true AND deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- RLS: content.workspaces
-- ----------------------------------------------------------------------------

ALTER TABLE content.workspaces
    ENABLE ROW LEVEL SECURITY;

-- Policy 1: Usuário pode VER apenas seus workspaces ativos
CREATE POLICY "select_own_workspaces"
    ON content.workspaces
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL);

-- Policy 2: Usuário pode CRIAR workspaces (forçando user_id = ele mesmo)
CREATE POLICY "insert_own_workspaces"
    ON content.workspaces
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Policy 3: Usuário pode ATUALIZAR apenas seus workspaces
CREATE POLICY "update_own_workspaces"
    ON content.workspaces
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL)
    WITH CHECK (user_id = auth.uid());
-- não pode mudar o dono

-- Policy 4: Usuário pode SOFT-DELETE (setar deleted_at) seus workspaces
-- Nota: Soft-delete é um UPDATE, não DELETE
CREATE POLICY "soft_delete_own_workspaces"
    ON content.workspaces
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL);

-- Policy 5: service_role pode tudo (admin)
CREATE POLICY "admin_manage_workspaces"
    ON content.workspaces
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- COMENTÁRIOS (Documentação no banco)
-- ============================================================================

COMMENT ON SCHEMA billing IS 'Schema para gerenciamento de planos e assinaturas';
COMMENT ON SCHEMA content IS 'Schema para conteúdo do usuário (workspaces, decks, flashcards)';
COMMENT ON SCHEMA analytics IS 'Schema para métricas e estatísticas de estudo';

COMMENT ON TABLE billing.subscription_plans IS 'Planos disponíveis (free, premium, pro)';
COMMENT ON TABLE billing.user_subscriptions IS 'Assinatura atual de cada usuário';
COMMENT ON TABLE content.workspaces IS 'Agrupamento top-level de conteúdo do usuário';

COMMENT ON COLUMN billing.subscription_plans.price_cents IS 'Preço em centavos para evitar problemas com float';
COMMENT ON COLUMN billing.subscription_plans.features IS 'Features adicionais em JSON (flexibilidade futura)';
COMMENT ON COLUMN billing.user_subscriptions.external_subscription_id IS 'ID da assinatura no gateway de pagamento (Stripe, etc)';
COMMENT ON COLUMN content.workspaces.is_default IS 'Workspace padrão criado automaticamente para novos usuários';
