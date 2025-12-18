-- ============================================================================
-- MIGRATION #2: Decks e Flashcards (CORRIGIDA)
-- ============================================================================
-- Descrição: Cria tabelas para decks (agrupamento de flashcards) e os
--            flashcards em si, com suporte a repetição espaçada (Anki-like)
-- ============================================================================


-- ----------------------------------------------------------------------------
-- TABELA: content.decks
-- ----------------------------------------------------------------------------
-- Deck = agrupamento de flashcards dentro de um workspace
-- Cada deck pertence a UM workspace
-- Suporta soft-delete
-- ----------------------------------------------------------------------------

CREATE TABLE content.decks
(
    id           UUID PRIMARY KEY     DEFAULT uuid_generate_v4(),

    -- Relacionamento com workspace
    workspace_id UUID        NOT NULL REFERENCES content.workspaces (id) ON DELETE CASCADE,
    user_id      UUID        NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

    -- Dados do deck
    name         TEXT        NOT NULL,
    description  TEXT,
    color        TEXT,
    icon         TEXT,

    -- Ordenação customizada
    sort_order   INTEGER     NOT NULL DEFAULT 0,

    -- Configurações do deck
    settings     JSONB                DEFAULT '{
      "cards_per_session": 20,
      "show_answer_automatically": false,
      "shuffle_cards": true
    }'::jsonb,

    -- Soft-delete
    deleted_at   TIMESTAMPTZ,

    -- Auditoria
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()

    -- ❌ REMOVIDO: CHECK constraint com subquery não funciona
    -- Vamos validar isso via TRIGGER na migration #5
);

-- Índices para queries comuns
CREATE INDEX idx_decks_workspace_active
    ON content.decks (workspace_id, sort_order)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_decks_user_active
    ON content.decks (user_id)
    WHERE deleted_at IS NULL;

-- Índice para contar decks por workspace (validação de limite)
CREATE INDEX idx_decks_workspace_count
    ON content.decks (workspace_id)
    WHERE deleted_at IS NULL;

-- Índice composto para validação rápida (workspace + user)
CREATE INDEX idx_decks_workspace_user
    ON content.decks (workspace_id, user_id)
    WHERE deleted_at IS NULL;


-- ----------------------------------------------------------------------------
-- RLS: content.decks
-- ----------------------------------------------------------------------------

ALTER TABLE content.decks
    ENABLE ROW LEVEL SECURITY;

-- Policy 1: Usuário vê apenas seus decks ativos
CREATE POLICY "select_own_decks"
    ON content.decks
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL);

-- Policy 2: Usuário pode criar decks (forçando user_id)
CREATE POLICY "insert_own_decks"
    ON content.decks
    FOR INSERT
    TO authenticated
    WITH CHECK (
    user_id = auth.uid()
        AND workspace_id IN (SELECT id
                             FROM content.workspaces
                             WHERE user_id = auth.uid()
                               AND deleted_at IS NULL)
    );

-- Policy 3: Usuário pode atualizar seus decks
CREATE POLICY "update_own_decks"
    ON content.decks
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL)
    WITH CHECK (user_id = auth.uid());

-- Policy 4: service_role pode tudo
CREATE POLICY "admin_manage_decks"
    ON content.decks
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);


-- ----------------------------------------------------------------------------
-- TABELA: content.flashcards
-- ----------------------------------------------------------------------------
-- Flashcard = unidade básica de estudo (frente/verso)
-- Implementa algoritmo de repetição espaçada (Anki SM-2)
-- Suporta soft-delete
-- ----------------------------------------------------------------------------

CREATE TABLE content.flashcards
(
    id              UUID PRIMARY KEY       DEFAULT uuid_generate_v4(),

    -- Relacionamento
    deck_id         UUID          NOT NULL REFERENCES content.decks (id) ON DELETE CASCADE,
    user_id         UUID          NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

    -- Conteúdo do flashcard
    front           TEXT          NOT NULL,              -- Pergunta/termo
    back            TEXT          NOT NULL,              -- Resposta/definição

    -- Metadados opcionais
    hint            TEXT,                                -- Dica antes de revelar resposta
    explanation     TEXT,                                -- Explicação adicional após resposta
    tags            TEXT[]                 DEFAULT '{}', -- Tags para filtros (ex: ['difícil', 'importante'])

    -- Mídia (URLs ou base64)
    front_image_url TEXT,
    back_image_url  TEXT,
    audio_url       TEXT,

    -- Algoritmo de Repetição Espaçada (Anki SM-2)
    ease_factor     NUMERIC(4, 2) NOT NULL DEFAULT 2.5,  -- Facilidade (1.3 a 2.5+)
    interval_days   INTEGER       NOT NULL DEFAULT 0,    -- Intervalo atual em dias
    repetitions     INTEGER       NOT NULL DEFAULT 0,    -- Quantas vezes acertou seguidas
    next_review_at  TIMESTAMPTZ,                         -- Quando deve revisar próximo

    -- Estado do card
    status          TEXT          NOT NULL DEFAULT 'new'
        CHECK (status IN ('new', 'learning', 'reviewing', 'suspended')),

    -- Estatísticas rápidas (cache)
    total_reviews   INTEGER       NOT NULL DEFAULT 0,
    correct_reviews INTEGER       NOT NULL DEFAULT 0,

    -- Ordenação customizada
    sort_order      INTEGER       NOT NULL DEFAULT 0,

    -- Soft-delete
    deleted_at      TIMESTAMPTZ,

    -- Auditoria
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()

    -- ❌ REMOVIDO: CHECK constraint com subquery não funciona
    -- Vamos validar isso via TRIGGER na migration #5
);

-- Índices para queries comuns
CREATE INDEX idx_flashcards_deck_active
    ON content.flashcards (deck_id, sort_order)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_flashcards_user_active
    ON content.flashcards (user_id)
    WHERE deleted_at IS NULL;

-- Índice para algoritmo de repetição espaçada (query mais crítica!)
CREATE INDEX idx_flashcards_next_review
    ON content.flashcards (user_id, next_review_at, status)
    WHERE deleted_at IS NULL AND next_review_at IS NOT NULL;

-- Índice para buscar cards "new" (nunca estudados)
CREATE INDEX idx_flashcards_status
    ON content.flashcards (user_id, deck_id, status)
    WHERE deleted_at IS NULL;

-- Índice para contar flashcards por deck (validação de limite)
CREATE INDEX idx_flashcards_deck_count
    ON content.flashcards (deck_id)
    WHERE deleted_at IS NULL;

-- Índice GIN para busca por tags
CREATE INDEX idx_flashcards_tags
    ON content.flashcards USING GIN (tags);

-- Índice composto para validação rápida (deck + user)
CREATE INDEX idx_flashcards_deck_user
    ON content.flashcards (deck_id, user_id)
    WHERE deleted_at IS NULL;


-- ----------------------------------------------------------------------------
-- RLS: content.flashcards
-- ----------------------------------------------------------------------------

ALTER TABLE content.flashcards
    ENABLE ROW LEVEL SECURITY;

-- Policy 1: Usuário vê apenas seus flashcards ativos
CREATE POLICY "select_own_flashcards"
    ON content.flashcards
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL);

-- Policy 2: Usuário pode criar flashcards
CREATE POLICY "insert_own_flashcards"
    ON content.flashcards
    FOR INSERT
    TO authenticated
    WITH CHECK (
    user_id = auth.uid()
        AND deck_id IN (SELECT id
                        FROM content.decks
                        WHERE user_id = auth.uid()
                          AND deleted_at IS NULL)
    );

-- Policy 3: Usuário pode atualizar seus flashcards
CREATE POLICY "update_own_flashcards"
    ON content.flashcards
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL)
    WITH CHECK (user_id = auth.uid());

-- Policy 4: service_role pode tudo
CREATE POLICY "admin_manage_flashcards"
    ON content.flashcards
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);


-- ============================================================================
-- COMENTÁRIOS (Documentação)
-- ============================================================================

COMMENT ON TABLE content.decks IS 'Agrupamento de flashcards dentro de um workspace';
COMMENT ON TABLE content.flashcards IS 'Unidade básica de estudo com algoritmo de repetição espaçada';

COMMENT ON COLUMN content.flashcards.ease_factor IS 'Fator de facilidade do algoritmo SM-2 (quanto maior, mais fácil o card)';
COMMENT ON COLUMN content.flashcards.interval_days IS 'Intervalo atual em dias até próxima revisão';
COMMENT ON COLUMN content.flashcards.repetitions IS 'Quantas vezes seguidas acertou (reset ao errar)';
COMMENT ON COLUMN content.flashcards.next_review_at IS 'Data/hora da próxima revisão agendada';
COMMENT ON COLUMN content.flashcards.status IS 'new=nunca estudado, learning=aprendendo, reviewing=em revisão, suspended=pausado';
COMMENT ON COLUMN content.decks.user_id IS 'Desnormalizado para performance - deve sempre ser igual ao user_id do workspace';
COMMENT ON COLUMN content.flashcards.user_id IS 'Desnormalizado para performance - deve sempre ser igual ao user_id do deck';
