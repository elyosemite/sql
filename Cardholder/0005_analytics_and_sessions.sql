-- ============================================================================
-- MIGRATION #3: Tabelas de Analytics (Study Sessions e Reviews)
-- ============================================================================
-- Descrição: Cria tabelas para rastrear sessões de estudo e reviews
--            individuais de flashcards. Essas tabelas crescem MUITO,
--            então usamos HARD-DELETE (não soft-delete) e particionamento.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- TABELA: analytics.study_sessions
-- ----------------------------------------------------------------------------
-- Study session = período contínuo de estudo do usuário
-- Exemplo: Usuário abre o app, estuda 30 minutos, fecha = 1 sessão
-- Usado para métricas: tempo total de estudo, frequência, streaks
-- ----------------------------------------------------------------------------

CREATE TABLE analytics.study_sessions
(
    id               UUID PRIMARY KEY     DEFAULT uuid_generate_v4(),

    -- Usuário que estudou
    user_id          UUID        NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

    -- Workspace/deck estudado (opcional - pode ser sessão geral)
    workspace_id     UUID        REFERENCES content.workspaces (id) ON DELETE SET NULL,
    deck_id          UUID        REFERENCES content.decks (id) ON DELETE SET NULL,

    -- Timestamps da sessão
    started_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at         TIMESTAMPTZ,

    -- Coluna gerada: data sem hora (para calcular streaks)
    started_date DATE,

    -- Duração calculada (em segundos)
    duration_seconds INTEGER,

    -- Estatísticas da sessão
    cards_studied    INTEGER              DEFAULT 0,
    cards_correct    INTEGER              DEFAULT 0,
    cards_incorrect  INTEGER              DEFAULT 0,
    cards_skipped    INTEGER              DEFAULT 0,

    -- Metadata adicional (device, source, etc)
    metadata         JSONB                DEFAULT '{}'::jsonb,

    -- Auditoria
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- CONSTRAINT: ended_at deve ser após started_at
    CONSTRAINT check_session_times CHECK (ended_at IS NULL OR ended_at >= started_at),

    -- CONSTRAINT: duration deve bater com ended_at - started_at
    CONSTRAINT check_session_duration CHECK (
        duration_seconds IS NULL OR
        (ended_at IS NOT NULL AND duration_seconds = EXTRACT(EPOCH FROM (ended_at - started_at))::INTEGER)
        )
);

-- Índices para queries de métricas (CRÍTICOS!)
-- Query: "Tempo total de estudo nos últimos 30 dias"
CREATE INDEX idx_study_sessions_user_date
    ON analytics.study_sessions (user_id, started_at DESC);

-- Query: "Sessões por workspace/deck"
CREATE INDEX idx_study_sessions_workspace
    ON analytics.study_sessions (workspace_id, started_at DESC)
    WHERE workspace_id IS NOT NULL;

CREATE INDEX idx_study_sessions_deck
    ON analytics.study_sessions (deck_id, started_at DESC)
    WHERE deck_id IS NOT NULL;

-- Query: "Sessões concluídas (com ended_at)"
CREATE INDEX idx_study_sessions_completed
    ON analytics.study_sessions (user_id, ended_at DESC)
    WHERE ended_at IS NOT NULL;

-- Query: "Calcular streaks (dias consecutivos)" - USA A COLUNA GERADA
CREATE INDEX idx_study_sessions_user_date_only
  ON analytics.study_sessions(user_id, started_at);

-- Trigger para preencher started_date automaticamente
CREATE OR REPLACE FUNCTION set_started_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.started_date := (NEW.started_at AT TIME ZONE 'UTC')::DATE;
    return NEW;
end;
$$ LANGUAGE plpgsql;

create trigger trigger_set_started_date
    before insert or update on analytics.study_sessions
    for each row
    execute function set_started_date();

-- ----------------------------------------------------------------------------
-- RLS: analytics.study_sessions
-- ----------------------------------------------------------------------------

ALTER TABLE analytics.study_sessions
    ENABLE ROW LEVEL SECURITY;

-- Policy 1: Usuário vê apenas suas sessões
CREATE POLICY "select_own_sessions"
    ON analytics.study_sessions
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Policy 2: Usuário pode criar sessões
CREATE POLICY "insert_own_sessions"
    ON analytics.study_sessions
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Policy 3: Usuário pode atualizar suas sessões (fechar sessão)
CREATE POLICY "update_own_sessions"
    ON analytics.study_sessions
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Policy 4: service_role pode tudo
CREATE POLICY "admin_manage_sessions"
    ON analytics.study_sessions
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);


-- ----------------------------------------------------------------------------
-- TABELA: analytics.flashcard_reviews
-- ----------------------------------------------------------------------------
-- Review = cada vez que o usuário responde um flashcard
-- Tabela MUITO volumosa (milhões de registros)
-- Usamos particionamento por data (futuro) e hard-delete de dados antigos
-- ----------------------------------------------------------------------------

CREATE TABLE analytics.flashcard_reviews
(
    id                    UUID PRIMARY KEY     DEFAULT uuid_generate_v4(),

    -- Relacionamentos
    user_id               UUID        NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
    flashcard_id          UUID        NOT NULL REFERENCES content.flashcards (id) ON DELETE CASCADE,
    deck_id               UUID        NOT NULL REFERENCES content.decks (id) ON DELETE CASCADE,
    study_session_id      UUID        REFERENCES analytics.study_sessions (id) ON DELETE SET NULL,

    -- Quando foi revisado
    reviewed_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- ADICIONAR: Coluna gerada para data sem hora (para métricas)
    reviewed_date DATE GENERATED ALWAYS AS ((reviewed_at AT TIME ZONE 'UTC')::DATE) STORED,

    -- Resultado da revisão
    is_correct            BOOLEAN     NOT NULL,

    -- Tempo levado para responder (segundos)
    response_time_seconds INTEGER,

    -- Dificuldade auto-avaliada (1=fácil, 2=médio, 3=difícil, 4=esqueci)
    difficulty_rating     INTEGER CHECK (difficulty_rating BETWEEN 1 AND 4),

    -- Estado do algoritmo SM-2 ANTES da revisão (snapshot)
    ease_factor_before    NUMERIC(4, 2),
    interval_days_before  INTEGER,
    repetitions_before    INTEGER,

    -- Estado DEPOIS da revisão (novo cálculo)
    ease_factor_after     NUMERIC(4, 2),
    interval_days_after   INTEGER,
    repetitions_after     INTEGER,
    next_review_at        TIMESTAMPTZ,

    -- Metadata adicional
    metadata              JSONB                DEFAULT '{}'::jsonb,

    -- Auditoria
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para queries de métricas (SUPER CRÍTICOS!)
-- Query: "Taxa de acerto nos últimos 7 dias"
CREATE INDEX idx_flashcard_reviews_user_date
    ON analytics.flashcard_reviews (user_id, reviewed_at DESC, is_correct);

-- Query: "Reviews por flashcard (histórico)"
CREATE INDEX idx_flashcard_reviews_flashcard
    ON analytics.flashcard_reviews (flashcard_id, reviewed_at DESC);

-- Query: "Reviews por deck"
CREATE INDEX idx_flashcard_reviews_deck
    ON analytics.flashcard_reviews (deck_id, reviewed_at DESC);

-- Query: "Reviews de uma sessão"
CREATE INDEX idx_flashcard_reviews_session
    ON analytics.flashcard_reviews (study_session_id, reviewed_at)
    WHERE study_session_id IS NOT NULL;

-- Índice para análise de performance (tempo de resposta)
CREATE INDEX idx_flashcard_reviews_response_time
    ON analytics.flashcard_reviews (user_id, response_time_seconds)
    WHERE response_time_seconds IS NOT NULL;

-- Índice composto para métricas diárias
CREATE INDEX idx_flashcard_reviews_user_date_deck
    ON analytics.flashcard_reviews (user_id, reviewed_date, deck_id, is_correct);

-- ----------------------------------------------------------------------------
-- RLS: analytics.flashcard_reviews
-- ----------------------------------------------------------------------------

ALTER TABLE analytics.flashcard_reviews
    ENABLE ROW LEVEL SECURITY;

-- Policy 1: Usuário vê apenas seus reviews
CREATE POLICY "select_own_reviews"
    ON analytics.flashcard_reviews
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Policy 2: Usuário pode criar reviews
CREATE POLICY "insert_own_reviews"
    ON analytics.flashcard_reviews
    FOR INSERT
    TO authenticated
    WITH CHECK (
    user_id = auth.uid()
        AND flashcard_id IN (SELECT id
                             FROM content.flashcards
                             WHERE user_id = auth.uid()
                               AND deleted_at IS NULL)
    );

-- Policy 3: Usuário NÃO pode atualizar reviews (imutável após criação)
-- Apenas service_role pode corrigir dados

-- Policy 4: service_role pode tudo
CREATE POLICY "admin_manage_reviews"
    ON analytics.flashcard_reviews
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);


-- ============================================================================
-- COMENTÁRIOS (Documentação)
-- ============================================================================

COMMENT ON TABLE analytics.study_sessions IS 'Sessões de estudo do usuário (período contínuo de uso)';
COMMENT ON TABLE analytics.flashcard_reviews IS 'Reviews individuais de flashcards (cada resposta)';

COMMENT ON COLUMN analytics.study_sessions.duration_seconds IS 'Duração calculada: ended_at - started_at';
COMMENT ON COLUMN analytics.study_sessions.metadata IS 'Dados extras: device, browser, source, etc';

COMMENT ON COLUMN analytics.flashcard_reviews.difficulty_rating IS '1=fácil, 2=médio, 3=difícil, 4=esqueci completamente';
COMMENT ON COLUMN analytics.flashcard_reviews.ease_factor_before IS 'Snapshot do ease_factor ANTES de aplicar algoritmo SM-2';
COMMENT ON COLUMN analytics.flashcard_reviews.ease_factor_after IS 'Novo ease_factor APÓS aplicar algoritmo SM-2';
COMMENT ON COLUMN analytics.flashcard_reviews.response_time_seconds IS 'Tempo que levou para responder (útil para detectar cards difíceis)';