-- ============================================================================
-- SEED: Study Sessions e Flashcard Reviews (apenas para DEV local)
-- ============================================================================
-- ⚠️ NÃO rodar em produção! Apenas Docker local.
-- Cria histórico de estudos para o usuário especificado
-- ============================================================================


set global.workspace_id = '5d06b94b-f23a-4622-a930-478cc590836d';
set global.user_id      = '00000003-0000-0000-0000-000000000001';
set global.deck_id      = '94195bfd-f1c5-4a1f-b380-e9128e87f006';
set global.session_id   = 'a1111111-1111-1119-1111-111111111111';
set global.review_id    = 'b2222222-2222-2222-2222-222222222222';
-- ----------------------------------------------------------------------------
-- CONFIGURAÇÃO: IDs fixos para este seed
-- ----------------------------------------------------------------------------
DO
$$
    DECLARE
        -- ✅ ADICIONAR estas variáveis:
        v_started_at       TIMESTAMPTZ;
        v_ended_at         TIMESTAMPTZ;
        v_duration_seconds INTEGER;
        v_hour_offset      INTEGER;
        v_minute_duration  INTEGER;
        v_cards_studied    INTEGER;
        v_cards_correct    INTEGER;

        -- Variáveis para algoritmo SM-2
        v_is_correct       BOOLEAN;
        v_difficulty       INTEGER;
        v_new_ease_factor  NUMERIC(4, 2);
        v_new_interval     INTEGER;
        v_new_repetitions  INTEGER;
        v_next_review      TIMESTAMPTZ;
        v_user_id          UUID := current_setting('global.user_id')::UUID;
        v_workspace_id     UUID := current_setting('global.workspace_id')::UUID;
        v_deck_id          UUID := current_setting('global.deck_id')::UUID;
        v_session_id       UUID;
        v_flashcard_record RECORD;
        v_review_count     INTEGER;
        v_current_date     DATE;
        v_days_ago         INTEGER;

    BEGIN

        RAISE NOTICE '========================================';
        RAISE NOTICE 'Criando histórico de estudos';
        RAISE NOTICE 'User ID: %', v_user_id;
        RAISE NOTICE 'Workspace ID: %', v_workspace_id;
        RAISE NOTICE 'Deck ID: %', v_deck_id;
        RAISE NOTICE '========================================';

        -- ----------------------------------------------------------------------------
        -- PARTE 1: Validar que usuário, workspace e deck existem
        -- ----------------------------------------------------------------------------

        IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_user_id) THEN
            RAISE EXCEPTION 'Usuário % não encontrado', v_user_id;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM content.workspaces WHERE id = v_workspace_id) THEN
            RAISE EXCEPTION 'Workspace % não encontrado', v_workspace_id;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM content.decks WHERE id = v_deck_id) THEN
            RAISE EXCEPTION 'Deck % não encontrado', v_deck_id;
        END IF;

        RAISE NOTICE 'Validações OK! Iniciando criação de dados...';


        -- ----------------------------------------------------------------------------
        -- PARTE 2: Criar sessões de estudo dos últimos 30 dias
        -- ----------------------------------------------------------------------------
        -- Simulação realista:
        -- - Dias 1-7: usuário estudou 5 dias (engajamento inicial alto)
        -- - Dias 8-14: estudou 4 dias (mantendo ritmo)
        -- - Dias 15-21: estudou 3 dias (queda)
        -- - Dias 22-30: estudou 6 dias (retomada)
        -- ----------------------------------------------------------------------------

        RAISE NOTICE 'Criando sessões de estudo...';

        -- Últimos 30 dias com padrão realista
        FOR v_days_ago IN
            -- Semana 1 (dias 30-24): 5 sessões
            SELECT unnest(ARRAY [30, 28, 27, 25, 24]) AS day
            UNION ALL
            -- Semana 2 (dias 23-17): 4 sessões
            SELECT unnest(ARRAY [23, 21, 19, 17]) AS day
            UNION ALL
            -- Semana 3 (dias 16-10): 3 sessões (queda)
            SELECT unnest(ARRAY [16, 13, 11]) AS day
            UNION ALL
            -- Semana 4 (dias 9-3): 6 sessões (retomada)
            SELECT unnest(ARRAY [9, 8, 6, 5, 3, 2]) AS day
            UNION ALL
            -- Hoje: 1 sessão
            SELECT 0 AS day
            LOOP
                v_current_date := CURRENT_DATE - (v_days_ago || ' days')::INTERVAL;

                -- ✅ CALCULAR: Horário de início (8h-10h, 14h-16h, 20h-22h)
                v_hour_offset := CASE
                                     WHEN random() < 0.33 THEN 8 + floor(random() * 2)::INTEGER -- manhã: 8-9h
                                     WHEN random() < 0.66 THEN 14 + floor(random() * 2)::INTEGER -- tarde: 14-15h
                                     ELSE 20 + floor(random() * 2)::INTEGER -- noite: 20-21h
                    END;

                v_started_at := v_current_date + (v_hour_offset || ' hours')::INTERVAL;

                -- ✅ CALCULAR: Duração da sessão (15-45 minutos)
                v_minute_duration := 15 + floor(random() * 30)::INTEGER;
                v_ended_at := v_started_at + (v_minute_duration || ' minutes')::INTERVAL;

                -- ✅ CALCULAR: Duration em segundos (DEVE BATER com ended_at - started_at)
                v_duration_seconds := EXTRACT(EPOCH FROM (v_ended_at - v_started_at))::INTEGER;

                -- ✅ CALCULAR: Cards estudados e estatísticas
                v_cards_studied := 10 + floor(random() * 15)::INTEGER;
                v_cards_correct := floor(v_cards_studied * (0.6 + random() * 0.3))::INTEGER;

                -- Inserir sessão com valores CONSISTENTES
                INSERT INTO analytics.study_sessions (id,
                                                      user_id,
                                                      workspace_id,
                                                      deck_id,
                                                      started_at,
                                                      ended_at,
                                                      duration_seconds,
                                                      cards_studied,
                                                      cards_correct,
                                                      cards_incorrect,
                                                      cards_skipped,
                                                      metadata)
                VALUES (uuid_generate_v4(),
                        v_user_id,
                        v_workspace_id,
                        v_deck_id,
                        v_started_at,
                        v_ended_at,
                        v_duration_seconds, -- ✅ Agora calculado corretamente
                        v_cards_studied,
                        v_cards_correct,
                        v_cards_studied - v_cards_correct, -- incorrect = total - correct
                        floor(random() * 2)::INTEGER, -- skipped: 0-1
                        jsonb_build_object(
                                'device', (ARRAY ['desktop', 'mobile', 'tablet'])[1 + floor(random() * 3)::INTEGER],
                                'browser',
                                (ARRAY ['chrome', 'firefox', 'safari', 'edge'])[1 + floor(random() * 4)::INTEGER],
                                'session_type', 'regular_study'
                        ))
                RETURNING id INTO v_session_id;

                RAISE NOTICE '  → Sessão criada: % (% dias atrás, duração: %min)',
                    v_session_id, v_days_ago, v_minute_duration;

            END LOOP;

        RAISE NOTICE 'Sessões criadas com sucesso!';
        RAISE NOTICE '';


        -- ----------------------------------------------------------------------------
        -- PARTE 3: Criar reviews para flashcards do deck
        -- ----------------------------------------------------------------------------
        -- Para cada flashcard do deck, criar histórico de reviews
        -- Simulando algoritmo de repetição espaçada
        -- ----------------------------------------------------------------------------

        RAISE NOTICE 'Criando reviews de flashcards...';

        FOR v_flashcard_record IN
            SELECT id,
                   front,
                   ease_factor,
                   interval_days,
                   repetitions,
                   status
            FROM content.flashcards
            WHERE deck_id = v_deck_id
              AND deleted_at IS NULL
            ORDER BY created_at
            LIMIT 50 -- Limitar a 50 cards para não criar dados demais
            LOOP

                -- Cada card foi revisado entre 1 e 10 vezes
                v_review_count := 1 + floor(random() * 10)::INTEGER;

                RAISE NOTICE '  → Criando % reviews para card: %', v_review_count, substring(v_flashcard_record.front, 1, 50);

                -- Inicializar valores do algoritmo SM-2
                v_new_ease_factor := v_flashcard_record.ease_factor;
                v_new_interval := v_flashcard_record.interval_days;
                v_new_repetitions := 0;

                FOR i IN 1..v_review_count
                    LOOP

                        -- Simular acerto/erro (80% de acerto em média)
                        v_is_correct := random() < 0.8;

                        -- Dificuldade auto-avaliada
                        IF v_is_correct THEN
                            v_difficulty := (ARRAY [1, 2])[1 + floor(random() * 2)::INTEGER]; -- Fácil ou médio
                        ELSE
                            v_difficulty := (ARRAY [3, 4])[1 + floor(random() * 2)::INTEGER]; -- Difícil ou esqueci
                        END IF;

                        -- Aplicar algoritmo SM-2 simplificado
                        IF v_is_correct THEN
                            -- Acertou: aumentar intervalo
                            v_new_repetitions := v_new_repetitions + 1;

                            IF v_new_repetitions = 1 THEN
                                v_new_interval := 1;
                            ELSIF v_new_repetitions = 2 THEN
                                v_new_interval := 6;
                            ELSE
                                v_new_interval := (v_new_interval * v_new_ease_factor)::INTEGER;
                            END IF;

                            -- Ajustar ease_factor baseado na dificuldade
                            CASE v_difficulty
                                WHEN 1 THEN -- Fácil
                                v_new_ease_factor := LEAST(v_new_ease_factor + 0.15, 2.8);
                                WHEN 2 THEN -- Médio
                                v_new_ease_factor := v_new_ease_factor; -- mantém
                                END CASE;

                        ELSE
                            -- Errou: resetar
                            v_new_repetitions := 0;
                            v_new_interval := 1;

                            -- Diminuir ease_factor
                            v_new_ease_factor := GREATEST(v_new_ease_factor - 0.2, 1.3);
                        END IF;

                        -- Calcular próxima revisão
                        v_next_review := NOW() - ((v_review_count - i) * 2 || ' days')::INTERVAL +
                                         (v_new_interval || ' days')::INTERVAL;

                        -- Inserir review
                        INSERT INTO analytics.flashcard_reviews (user_id,
                                                                 flashcard_id,
                                                                 deck_id,
                                                                 study_session_id,
                                                                 reviewed_at,
                                                                 is_correct,
                                                                 response_time_seconds,
                                                                 difficulty_rating,
                                                                 ease_factor_before,
                                                                 interval_days_before,
                                                                 repetitions_before,
                                                                 ease_factor_after,
                                                                 interval_days_after,
                                                                 repetitions_after,
                                                                 next_review_at,
                                                                 metadata)
                        VALUES (v_user_id,
                                v_flashcard_record.id,
                                v_deck_id,
                                NULL, -- Poderia associar a uma sessão, mas simplificando
                                NOW() - ((v_review_count - i) * 2 || ' days')::INTERVAL, -- Espaçado no tempo
                                v_is_correct,
                                (3 + random() * 30)::INTEGER, -- Tempo de resposta: 3 a 33 segundos
                                v_difficulty,

                                   -- Estado ANTES
                                CASE WHEN i = 1 THEN v_flashcard_record.ease_factor ELSE v_new_ease_factor END,
                                CASE WHEN i = 1 THEN v_flashcard_record.interval_days ELSE v_new_interval END,
                                CASE WHEN i = 1 THEN 0 ELSE v_new_repetitions END,

                                   -- Estado DEPOIS
                                v_new_ease_factor,
                                v_new_interval,
                                v_new_repetitions,
                                v_next_review,
                                jsonb_build_object(
                                        'review_number', i,
                                        'card_front_preview', substring(v_flashcard_record.front, 1, 50)
                                ));

                    END LOOP;

            END LOOP;

        RAISE NOTICE '';
        RAISE NOTICE 'Reviews criados com sucesso!';


        -- ----------------------------------------------------------------------------
        -- PARTE 4: Atualizar estatísticas dos flashcards
        -- ----------------------------------------------------------------------------

        RAISE NOTICE '';
        RAISE NOTICE 'Atualizando estatísticas dos flashcards...';

        UPDATE content.flashcards f
        SET total_reviews   = (SELECT COUNT(*)
                               FROM analytics.flashcard_reviews
                               WHERE flashcard_id = f.id),
            correct_reviews = (SELECT COUNT(*)
                               FROM analytics.flashcard_reviews
                               WHERE flashcard_id = f.id
                                 AND is_correct = true),

            -- Atualizar com último review
            ease_factor     = COALESCE((SELECT ease_factor_after
                                        FROM analytics.flashcard_reviews
                                        WHERE flashcard_id = f.id
                                        ORDER BY reviewed_at DESC
                                        LIMIT 1), f.ease_factor),

            interval_days   = COALESCE((SELECT interval_days_after
                                        FROM analytics.flashcard_reviews
                                        WHERE flashcard_id = f.id
                                        ORDER BY reviewed_at DESC
                                        LIMIT 1), f.interval_days),

            repetitions     = COALESCE((SELECT repetitions_after
                                        FROM analytics.flashcard_reviews
                                        WHERE flashcard_id = f.id
                                        ORDER BY reviewed_at DESC
                                        LIMIT 1), f.repetitions),

            next_review_at  = (SELECT next_review_at
                               FROM analytics.flashcard_reviews
                               WHERE flashcard_id = f.id
                               ORDER BY reviewed_at DESC
                               LIMIT 1),

            status          = CASE
                                  WHEN (SELECT COUNT(*) FROM analytics.flashcard_reviews WHERE flashcard_id = f.id) = 0
                                      THEN 'new'
                                  WHEN (SELECT COUNT(*) FROM analytics.flashcard_reviews WHERE flashcard_id = f.id) < 3
                                      THEN 'learning'
                                  ELSE 'reviewing'
                END

        WHERE deck_id = v_deck_id
          AND deleted_at IS NULL;

        RAISE NOTICE 'Estatísticas atualizadas!';
        RAISE NOTICE '';

    END
$$;

-- ============================================================================
-- VALIDAÇÕES: Queries para verificar dados criados
-- ============================================================================

-- Total de sessões criadas
SELECT COUNT(*)                                                               as total_sessions,
       MIN(started_at)                                                        as primeira_sessao,
       MAX(started_at)                                                        as ultima_sessao,
       SUM(duration_seconds) / 60                                             as total_minutos_estudados,
       SUM(cards_studied)                                                     as total_cards_estudados,
       ROUND(AVG(cards_correct::NUMERIC / NULLIF(cards_studied, 0) * 100), 2) as taxa_acerto_media
FROM analytics.study_sessions
WHERE user_id = current_setting('global.user_id')::UUID;

-- Total de reviews criados
SELECT COUNT(*)                                                                      as total_reviews,
       COUNT(*) FILTER (WHERE is_correct = true)                                     as reviews_corretos,
       COUNT(*) FILTER (WHERE is_correct = false)                                    as reviews_incorretos,
       ROUND(COUNT(*) FILTER (WHERE is_correct = true)::NUMERIC / COUNT(*) * 100, 2) as taxa_acerto,
       ROUND(AVG(response_time_seconds), 2)                                          as tempo_medio_resposta_seg
FROM analytics.flashcard_reviews
WHERE user_id = current_setting('global.user_id')::UUID;

-- Distribuição de reviews por dia
SELECT reviewed_date                              as dia,
       COUNT(*)                                   as total_reviews,
       COUNT(*) FILTER (WHERE is_correct = true)  as acertos,
       COUNT(*) FILTER (WHERE is_correct = false) as erros,
       ROUND(AVG(response_time_seconds), 1)       as tempo_medio
FROM analytics.flashcard_reviews
WHERE user_id = current_setting('global.user_id')::UUID
GROUP BY reviewed_date
ORDER BY dia DESC
LIMIT 10;

-- CORRIGIDO: Distribuição de reviews por dia (usa reviewed_date)
SELECT reviewed_date                              as dia,
       COUNT(*)                                   as total_reviews,
       COUNT(*) FILTER (WHERE is_correct = true)  as acertos,
       COUNT(*) FILTER (WHERE is_correct = false) as erros,
       ROUND(AVG(response_time_seconds), 1)       as tempo_medio
FROM analytics.flashcard_reviews
WHERE user_id = current_setting('global.user_id')::UUID
GROUP BY reviewed_date
ORDER BY dia DESC
LIMIT 10;

-- Flashcards mais revisados
SELECT f.front,
       f.total_reviews,
       f.correct_reviews,
       ROUND(f.correct_reviews::NUMERIC / NULLIF(f.total_reviews, 0) * 100, 2) as taxa_acerto,
       f.ease_factor,
       f.interval_days,
       f.status,
       f.next_review_at
FROM content.flashcards f
WHERE f.deck_id = current_setting('global.deck_id')::UUID
  AND f.deleted_at IS NULL
  AND f.total_reviews > 0
ORDER BY f.total_reviews DESC
LIMIT 10;

-- Resumo por dificuldade
SELECT difficulty_rating,
       CASE difficulty_rating
           WHEN 1 THEN 'Fácil'
           WHEN 2 THEN 'Médio'
           WHEN 3 THEN 'Difícil'
           WHEN 4 THEN 'Esqueci'
           END                                            as dificuldade,
       COUNT(*)                                           as total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM analytics.flashcard_reviews
WHERE user_id = current_setting('global.user_id')::UUID
GROUP BY difficulty_rating
ORDER BY difficulty_rating;

-- SEED SIMPLES: 1 Study Session + 1 Flashcard Review (hard coded)

insert into analytics.study_sessions (id,
                                      user_id,
                                      workspace_id,
                                      deck_id,
                                      started_at,
                                      ended_at,
                                      duration_seconds,
                                      cards_studied,
                                      cards_correct,
                                      cards_incorrect,
                                      cards_skipped,
                                      metadata,
                                      created_at)
values (current_setting('global.session_id')::UUID, -- ID fixo da sessão
        current_setting('global.user_id')::UUID, -- user_id
        current_setting('global.workspace_id')::UUID, -- workspace_id
        current_setting('global.deck_id')::UUID, -- deck_id
           -- Sessão começou hoje às 14:00
        CURRENT_DATE + INTERVAL '14 hours',

           -- Sessão terminou às 14:30 (30 minutos depois)
        CURRENT_DATE + INTERVAL '14 hours 30 minutes',

           -- Duração: 30 minutos = 1800 segundos
        EXTRACT(EPOCH FROM (
            (CURRENT_DATE + INTERVAL '14 hours 30 minutes') -
            (CURRENT_DATE + INTERVAL '14 hours')
            ))::INTEGER,

           -- Estudou 15 cards
        15,

           -- Acertou 12 cards
        12,

           -- Errou 3 cards
        3,

           -- Não pulou nenhum
        0,

           -- Metadata
        '{
          "device": "desktop",
          "browser": "chrome",
          "session_type": "regular_study"
        }'::jsonb,

           -- Criado agora
        NOW());

-- ----------------------------------------------------------------------------
-- 2. Pegar o ID de um flashcard do deck (primeiro disponível)
-- ----------------------------------------------------------------------------

-- Você pode substituir pelo ID real de um flashcard, ou usar esta query:
-- SELECT id FROM content.flashcards
-- WHERE deck_id = 'd4d462c3-6230-4067-b7e6-b2ab2e89c5da'
-- AND deleted_at IS NULL
-- LIMIT 1;

-- Assumindo que existe um flashcard, vou usar um ID genérico
-- Se der erro, substitua pelo ID real de um flashcard do seu deck


-- ----------------------------------------------------------------------------
-- 3. Inserir 1 Flashcard Review
-- ----------------------------------------------------------------------------

INSERT INTO analytics.flashcard_reviews (id,
                                         user_id,
                                         flashcard_id,
                                         deck_id,
                                         study_session_id,
                                         reviewed_at,
                                         is_correct,
                                         response_time_seconds,
                                         difficulty_rating,
                                         ease_factor_before,
                                         interval_days_before,
                                         repetitions_before,
                                         ease_factor_after,
                                         interval_days_after,
                                         repetitions_after,
                                         next_review_at,
                                         metadata,
                                         created_at)
VALUES (current_setting('global.review_id')::UUID, -- ID fixo do review
        current_setting('global.user_id')::UUID, -- user_id

           -- ⚠️ IMPORTANTE: Substitua pelo ID real de um flashcard do seu deck
           -- Ou rode esta query antes: SELECT id FROM content.flashcards WHERE deck_id = 'd4d462c3-6230-4067-b7e6-b2ab2e89c5da' LIMIT 1;
        (SELECT id
         FROM content.flashcards
         WHERE deck_id = current_setting('global.deck_id')::UUID
           AND deleted_at IS NULL
         LIMIT 1),
        current_setting('global.deck_id')::UUID, -- deck_id
        current_setting('global.session_id')::UUID, -- study_session_id (mesma sessão criada acima)

           -- Review feito hoje às 14:05 (durante a sessão)
        CURRENT_DATE + INTERVAL '14 hours 5 minutes',

           -- Acertou
        true,

           -- Levou 8 segundos para responder
        8,

           -- Dificuldade: 2 (médio)
        2,

           -- Estado ANTES do review (card era novo)
        2.5, -- ease_factor inicial
        0, -- interval_days (nunca estudado)
        0, -- repetitions (nenhuma)

           -- Estado DEPOIS do review (primeiro acerto)
        2.5, -- ease_factor mantém
        1, -- interval_days (próxima revisão em 1 dia)
        1, -- repetitions (primeira vez que acertou)

           -- Próxima revisão: amanhã às 14:00
        CURRENT_DATE + INTERVAL '1 day 14 hours',

           -- Metadata
        '{
          "review_number": 1,
          "card_front_preview": "Exemplo de pergunta"
        }'::jsonb,

           -- Criado agora
        NOW());


-- ============================================================================
-- VALIDAÇÕES: Verificar dados inseridos
-- ============================================================================

-- Ver a sessão criada
SELECT id,
       user_id,
       started_at,
       ended_at,
       duration_seconds,
       cards_studied,
       cards_correct,
       cards_incorrect
FROM analytics.study_sessions
WHERE id = current_setting('global.session_id')::UUID;

-- Ver o review criado
SELECT id,
       user_id,
       flashcard_id,
       reviewed_at,
       is_correct,
       response_time_seconds,
       difficulty_rating,
       ease_factor_before,
       ease_factor_after,
       interval_days_before,
       interval_days_after,
       next_review_at
FROM analytics.flashcard_reviews
WHERE id = current_setting('global.review_id')::UUID;

-- Verificar se estão linkados
SELECT s.id as session_id,
       s.started_at,
       s.cards_studied,
       r.id as review_id,
       r.reviewed_at,
       r.is_correct
FROM analytics.study_sessions s
         LEFT JOIN analytics.flashcard_reviews r ON r.study_session_id = s.id
WHERE s.id = current_setting('global.review_id')::UUID;
