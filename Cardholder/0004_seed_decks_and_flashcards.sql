-- ============================================================================
-- SEED: Decks e Flashcards (apenas para DEV local)
-- ============================================================================
-- ⚠️ NÃO rodar em produção! Apenas Docker local.
-- Cria decks e flashcards distribuídos entre os usuários existentes
-- ============================================================================


-- ----------------------------------------------------------------------------
-- PARTE 1: Criar decks para usuários (respeitando limites dos planos)
-- ----------------------------------------------------------------------------

-- Free users: 2-5 decks por workspace (máximo 5 decks por workspace)
INSERT INTO content.decks (user_id, workspace_id, name, description, color, icon, sort_order, created_at)
SELECT w.user_id,
       w.id as workspace_id,
       deck_data.name,
       deck_data.description,
       deck_data.color,
       deck_data.icon,
       deck_data.sort_order,
       w.created_at + (deck_data.sort_order || ' hours')::INTERVAL
FROM content.workspaces w
         CROSS JOIN (VALUES (0, 'Vocabulário Básico', 'Palavras essenciais do dia a dia', '#FF6B6B', '📚'),
                            (1, 'Gramática Essencial', 'Regras gramaticais fundamentais', '#4ECDC4', '📖'),
                            (2, 'Anatomia Humana', 'Sistemas do corpo humano', '#95E1D3', '🫀'),
                            (3, 'Fisiologia Básica', 'Funções dos órgãos', '#F38181', '🧬'),
                            (4, 'Farmacologia', 'Medicamentos e dosagens', '#AA96DA',
                             '💊')) AS deck_data(sort_order, name, description, color, icon)
WHERE w.user_id::text LIKE '00000001-%' -- Free users
  AND w.deleted_at IS NULL
  AND NOT EXISTS (SELECT 1
                  FROM content.decks
                  WHERE workspace_id = w.id
                    AND name = deck_data.name);

-- Premium users: 5-15 decks por workspace (máximo 20 decks)
INSERT INTO content.decks (user_id, workspace_id, name, description, color, icon, sort_order, created_at)
SELECT w.user_id,
       w.id as workspace_id,
       deck_data.name,
       deck_data.description,
       deck_data.color,
       deck_data.icon,
       deck_data.sort_order,
       w.created_at + (deck_data.sort_order || ' hours')::INTERVAL
FROM content.workspaces w
         CROSS JOIN (VALUES (0, 'Limites e Continuidade', 'Fundamentos de cálculo', '#FF6B6B', '∞'),
                            (1, 'Derivadas', 'Regras de derivação', '#4ECDC4', '📈'),
                            (2, 'Integrais', 'Cálculo integral', '#95E1D3', '∫'),
                            (3, 'Cinemática', 'Movimento e velocidade', '#F38181', '🚀'),
                            (4, 'Dinâmica', 'Forças e energia', '#AA96DA', '⚡'),
                            (5, 'Termodinâmica', 'Calor e temperatura', '#FCBAD3', '🔥'),
                            (6, 'Estruturas de Dados', 'Arrays, listas, árvores', '#FFFFD2', '🌳'),
                            (7, 'Algoritmos', 'Ordenação e busca', '#A8E6CF', '🔍'),
                            (8, 'Python Basics', 'Sintaxe e fundamentos', '#FFD3B6', '🐍'),
                            (9, 'SQL Queries', 'SELECT, JOIN, WHERE', '#FFAAA5', '🗄️'),
                            (10, 'Git Commands', 'Controle de versão', '#FF8B94', '🌿'),
                            (11, 'React Hooks', 'useState, useEffect', '#FFC6C7', '⚛️'),
                            (12, 'TypeScript Types', 'Tipos e interfaces', '#C7CEEA', '📘'),
                            (13, 'Design Patterns', 'Padrões de projeto', '#B5EAD7', '🎨'),
                            (14, 'Redes de Computadores', 'TCP/IP e protocolos', '#E2F0CB',
                             '🌐')) AS deck_data(sort_order, name, description, color, icon)
WHERE w.user_id::text LIKE '00000002-%' -- Premium users
  AND w.deleted_at IS NULL
  AND NOT EXISTS (SELECT 1
                  FROM content.decks
                  WHERE workspace_id = w.id
                    AND name = deck_data.name);

-- Pro users: 10-30 decks por workspace (ilimitado)
INSERT INTO content.decks (user_id, workspace_id, name, description, color, icon, sort_order, created_at)
SELECT w.user_id,
       w.id as workspace_id,
       deck_data.name,
       deck_data.description,
       deck_data.color,
       deck_data.icon,
       deck_data.sort_order,
       w.created_at + (deck_data.sort_order || ' hours')::INTERVAL
FROM content.workspaces w
         CROSS JOIN (VALUES (0, 'Código Penal - Parte Geral', 'Arts. 1 ao 120', '#FF6B6B', '⚖️'),
                            (1, 'Código Penal - Crimes contra a Pessoa', 'Homicídio, lesões', '#4ECDC4', '👤'),
                            (2, 'Código Penal - Crimes contra o Patrimônio', 'Furto, roubo, estelionato', '#95E1D3',
                             '💰'),
                            (3, 'CPP - Inquérito Policial', 'Arts. 4 ao 23', '#F38181', '🔍'),
                            (4, 'CPP - Ação Penal', 'Pública e privada', '#AA96DA', '⚖️'),
                            (5, 'Código Civil - Parte Geral', 'Pessoas, bens, fatos', '#FCBAD3', '📚'),
                            (6, 'Obrigações', 'Modalidades e efeitos', '#FFFFD2', '📋'),
                            (7, 'Contratos', 'Compra e venda, locação', '#A8E6CF', '📝'),
                            (8, 'Responsabilidade Civil', 'Dano e indenização', '#FFD3B6', '⚠️'),
                            (9, 'Direitos Reais', 'Propriedade e posse', '#FFAAA5', '🏠'),
                            (10, 'CPC - Teoria Geral', 'Jurisdição e competência', '#FF8B94', '⚖️'),
                            (11, 'Procedimento Comum', 'Petição inicial ao trânsito', '#FFC6C7', '📄'),
                            (12, 'Recursos', 'Apelação, agravo, embargos', '#C7CEEA', '📤'),
                            (13, 'Execução', 'Títulos executivos', '#B5EAD7', '💵'),
                            (14, 'Tutelas Provisórias', 'Urgência e evidência', '#E2F0CB', '⏱️'),
                            (15, 'Princípios Fundamentais', 'Arts. 1 ao 4 CF', '#FFDFD3', '🏛️'),
                            (16, 'Direitos Fundamentais', 'Arts. 5 ao 17 CF', '#FEC8D8', '👥'),
                            (17, 'Organização do Estado', 'União, Estados, DF, Municípios', '#FFDFD3', '🗺️'),
                            (18, 'Controle de Constitucionalidade', 'ADI, ADC, ADPF', '#957DAD', '📜'),
                            (19, 'Remédios Constitucionais', 'HC, MS, MI', '#D291BC',
                             '🛡️')) AS deck_data(sort_order, name, description, color, icon)
WHERE w.user_id::text LIKE '00000003-%' -- Pro users
  AND w.deleted_at IS NULL
  AND NOT EXISTS (SELECT 1
                  FROM content.decks
                  WHERE workspace_id = w.id
                    AND name = deck_data.name);


-- ----------------------------------------------------------------------------
-- PARTE 2: Criar flashcards para os decks criados
-- ----------------------------------------------------------------------------

-- Função auxiliar para gerar flashcards variados
DO
$$
    DECLARE
        deck_record RECORD;
        card_count  INTEGER;
        i           INTEGER;
    BEGIN
        -- Iterar sobre todos os decks
        FOR deck_record IN
            SELECT d.id   as deck_id,
                   d.user_id,
                   d.name as deck_name,
                   sp.plan_code,
                   sp.max_flashcards_per_decks
            FROM content.decks d
                     JOIN billing.user_subscriptions us ON us.user_id = d.user_id AND us.status = 'active'
                     JOIN billing.subscription_plans sp ON sp.id = us.plan_id
            WHERE d.deleted_at IS NULL
            LOOP
                -- Definir quantidade de cards baseado no plano
                IF deck_record.plan_code = 'free' THEN
                    card_count := 10 + floor(random() * 20)::INTEGER; -- 10 a 30 cards
                ELSIF deck_record.plan_code = 'premium' THEN
                    card_count := 30 + floor(random() * 50)::INTEGER; -- 30 a 80 cards
                ELSE -- pro
                    card_count := 50 + floor(random() * 100)::INTEGER; -- 50 a 150 cards
                END IF;

                -- Criar flashcards para este deck
                FOR i IN 1..card_count
                    LOOP
                        INSERT INTO content.flashcards (deck_id,
                                                        user_id,
                                                        front,
                                                        back,
                                                        hint,
                                                        tags,
                                                        status,
                                                        ease_factor,
                                                        interval_days,
                                                        repetitions,
                                                        sort_order,
                                                        created_at)
                        VALUES (deck_record.deck_id,
                                deck_record.user_id,

                                   -- Front (pergunta) - exemplos variados
                                CASE
                                    WHEN deck_record.deck_name ILIKE '%vocabulário%' OR
                                         deck_record.deck_name ILIKE '%inglês%' THEN
                                        (ARRAY ['What is the meaning of "ubiquitous"?',
                                            'Translate: "The cat is on the table"',
                                            'How do you say "bom dia" in English?',
                                            'What does "serendipity" mean?',
                                            'Complete: "I ___ been studying for 2 hours"'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%anatomia%' OR
                                         deck_record.deck_name ILIKE '%medicina%' THEN
                                        (ARRAY ['Qual é a função do coração?',
                                            'Quantos ossos tem o corpo humano adulto?',
                                            'O que é a mitocôndria?',
                                            'Qual a diferença entre artéria e veia?',
                                            'O que são neurônios?'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%cálculo%' OR
                                         deck_record.deck_name ILIKE '%derivada%' THEN
                                        (ARRAY ['Qual a derivada de x²?',
                                            'Calcule: lim(x→0) sen(x)/x',
                                            'O que é uma função contínua?',
                                            'Regra da cadeia: como aplicar?',
                                            'Integral de 1/x é?'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%python%' OR
                                         deck_record.deck_name ILIKE '%programa%' THEN
                                        (ARRAY ['Como declarar uma lista em Python?',
                                            'O que é list comprehension?',
                                            'Diferença entre append() e extend()?',
                                            'Como criar uma função lambda?',
                                            'O que são decorators?'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%penal%' OR
                                         deck_record.deck_name ILIKE '%direito%' THEN
                                        (ARRAY ['O que é dolo eventual?',
                                            'Diferença entre furto e roubo?',
                                            'Quais são as excludentes de ilicitude?',
                                            'O que é crime culposo?',
                                            'Prescrição penal: como calcular?'])[1 + floor(random() * 5)::INTEGER]

                                    ELSE
                                        'Pergunta exemplo ' || i || ' do deck ' || deck_record.deck_name
                                    END,

                                   -- Back (resposta)
                                CASE
                                    WHEN deck_record.deck_name ILIKE '%vocabulário%' OR
                                         deck_record.deck_name ILIKE '%inglês%' THEN
                                        (ARRAY ['Presente em todos os lugares / onipresente',
                                            'O gato está na mesa',
                                            'Good morning',
                                            'Descoberta afortunada por acaso',
                                            'have'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%anatomia%' OR
                                         deck_record.deck_name ILIKE '%medicina%' THEN
                                        (ARRAY ['Bombear sangue para todo o corpo',
                                            '206 ossos',
                                            'Organela responsável pela produção de energia (ATP)',
                                            'Artéria leva sangue do coração; veia traz sangue ao coração',
                                            'Células do sistema nervoso que transmitem impulsos elétricos'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%cálculo%' OR
                                         deck_record.deck_name ILIKE '%derivada%' THEN
                                        (ARRAY ['2x',
                                            '1',
                                            'Função sem "saltos" ou descontinuidades',
                                            'd/dx[f(g(x))] = f''(g(x)) · g''(x)',
                                            'ln|x| + C'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%python%' OR
                                         deck_record.deck_name ILIKE '%programa%' THEN
                                        (ARRAY ['lista = [] ou lista = list()',
                                            'Forma concisa de criar listas: [x*2 for x in range(10)]',
                                            'append() adiciona 1 elemento; extend() adiciona múltiplos',
                                            'lambda x: x * 2',
                                            'Funções que modificam outras funções (@decorator)'])[1 + floor(random() * 5)::INTEGER]

                                    WHEN deck_record.deck_name ILIKE '%penal%' OR
                                         deck_record.deck_name ILIKE '%direito%' THEN
                                        (ARRAY ['Agente assume o risco de produzir o resultado',
                                            'Furto: sem violência; Roubo: com violência ou grave ameaça',
                                            'Estado de necessidade, legítima defesa, estrito cumprimento do dever legal, exercício regular de direito',
                                            'Crime sem intenção, por negligência/imprudência/imperícia',
                                            'Regra: 1/2 da pena máxima em abstrato (art. 109 CP)'])[1 + floor(random() * 5)::INTEGER]

                                    ELSE
                                        'Resposta exemplo ' || i
                                    END,

                                   -- Hint (30% dos cards têm dica)
                                CASE
                                    WHEN random() < 0.3 THEN
                                        'Pense no conceito fundamental...'
                                    ELSE
                                        NULL
                                    END,

                                   -- Tags (aleatórias)
                                CASE
                                    WHEN random() < 0.2 THEN ARRAY ['importante', 'difícil']
                                    WHEN random() < 0.4 THEN ARRAY ['básico']
                                    WHEN random() < 0.6 THEN ARRAY ['revisão']
                                    WHEN random() < 0.8 THEN ARRAY ['prova']
                                    ELSE ARRAY []::TEXT[]
                                    END,

                                   -- Status (distribuição realista)
                                CASE
                                    WHEN random() < 0.3 THEN 'new' -- 30% nunca estudados
                                    WHEN random() < 0.7 THEN 'learning' -- 40% em aprendizado
                                    WHEN random() < 0.95 THEN 'reviewing' -- 25% em revisão
                                    ELSE 'suspended' -- 5% suspensos
                                    END,

                                   -- Ease factor (varia entre 1.3 e 2.8)
                                1.3 + (random() * 1.5),

                                   -- Interval days (baseado no status)
                                CASE
                                    WHEN random() < 0.3 THEN 0 -- new
                                    WHEN random() < 0.5 THEN 1 -- learning (1 dia)
                                    WHEN random() < 0.7 THEN 3 -- learning (3 dias)
                                    WHEN random() < 0.85 THEN 7 -- reviewing (1 semana)
                                    ELSE 15 + floor(random() * 60)::INTEGER -- reviewing (15-75 dias)
                                    END,

                                   -- Repetitions (0 a 10)
                                floor(random() * 11)::INTEGER,

                                   -- Sort order
                                i - 1,

                                   -- Created at (escalonado ao longo do tempo)
                                NOW() - (floor(random() * 30)::INTEGER || ' days')::INTERVAL);
                    END LOOP;

                RAISE NOTICE 'Criados % flashcards para deck: %', card_count, deck_record.deck_name;
            END LOOP;
    END
$$;

-- Atualizar next_review_at para cards em revisão
UPDATE content.flashcards
SET next_review_at = created_at + (interval_days || ' days')::INTERVAL
WHERE status IN ('learning', 'reviewing')
  AND deleted_at IS NULL
  AND next_review_at IS NULL;


-- ============================================================================
-- VALIDAÇÕES: Queries para verificar dados
-- ============================================================================

-- Total de decks por plano
SELECT sp.plan_code,
       COUNT(DISTINCT d.user_id)     as usuarios_com_decks,
       COUNT(d.id)                   as total_decks,
       ROUND(AVG(deck_count.cnt), 2) as media_decks_por_usuario
FROM content.decks d
         JOIN billing.user_subscriptions us ON us.user_id = d.user_id AND us.status = 'active'
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
         LEFT JOIN (SELECT user_id, COUNT(*) as cnt
                    FROM content.decks
                    WHERE deleted_at IS NULL
                    GROUP BY user_id) deck_count ON deck_count.user_id = d.user_id
WHERE d.deleted_at IS NULL
GROUP BY sp.plan_code, sp.price_cents
ORDER BY sp.price_cents;

-- Total de flashcards por plano
SELECT sp.plan_code,
       COUNT(f.id)                        as total_flashcards,
       ROUND(AVG(flashcard_count.cnt), 2) as media_flashcards_por_deck,
       MIN(flashcard_count.cnt)           as min_cards_deck,
       MAX(flashcard_count.cnt)           as max_cards_deck
FROM content.flashcards f
         JOIN content.decks d ON d.id = f.deck_id
         JOIN billing.user_subscriptions us ON us.user_id = f.user_id AND us.status = 'active'
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
         LEFT JOIN (SELECT deck_id, COUNT(*) as cnt
                    FROM content.flashcards
                    WHERE deleted_at IS NULL
                    GROUP BY deck_id) flashcard_count ON flashcard_count.deck_id = d.id
WHERE f.deleted_at IS NULL
GROUP BY sp.plan_code, sp.price_cents
ORDER BY sp.price_cents;

-- Distribuição por status
SELECT status,
       COUNT(*)                                           as total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM content.flashcards
WHERE deleted_at IS NULL
GROUP BY status
ORDER BY total DESC;

-- Resumo geral
SELECT (SELECT COUNT(*) FROM content.decks WHERE deleted_at IS NULL)                                         as total_decks,
       (SELECT COUNT(*) FROM content.flashcards WHERE deleted_at IS NULL)                                    as total_flashcards,
       (SELECT COUNT(DISTINCT user_id)
        FROM content.decks
        WHERE deleted_at IS NULL)                                                                            as usuarios_com_decks,
       (SELECT ROUND(AVG(cnt), 2)
        FROM (SELECT COUNT(*) as cnt
              FROM content.flashcards
              WHERE deleted_at IS NULL
              GROUP BY deck_id) sub)                                                                         as media_cards_por_deck;

-- Exemplo de alguns flashcards
SELECT u.email,
       w.name      as workspace,
       d.name      as deck,
       COUNT(f.id) as total_cards
FROM content.flashcards f
         JOIN content.decks d ON d.id = f.deck_id
         JOIN content.workspaces w ON w.id = d.workspace_id
         JOIN auth.users u ON u.id = f.user_id
WHERE f.deleted_at IS NULL
GROUP BY u.email, w.name, d.name
ORDER BY total_cards DESC
LIMIT 20;

-- Operações canônicas para e-mail gabriela.rocha@cardholder.dev
select * from auth.users limit 10;
select * from billing.user_subscriptions limit 10;
select * from billing.subscription_plans limit 10;
select * from content.workspaces limit 10;
select * from content.decks limit 10;
select * from content.flashcards limit 10;

-- Pegue um usuário
select * from auth.users where email = 'gabriela.rocha@cardholder.dev';
select * from content.workspaces where user_id='00000001-0000-0000-0000-000000000007';
select * from content.decks where user_id='00000001-0000-0000-0000-000000000007';

-- Qual o plano deste usuário?
select u.email, sp.plan_code, sp.description, sp.price_cents from auth.users u
join billing.user_subscriptions us on u.id = us.user_id
join billing.subscription_plans sp on sp.id = us.plan_id
where u.email = 'gabriela.rocha@cardholder.dev';

-- Qual o nome do workspace padrão dela?
select w.name from auth.users u
join content.workspaces w on w.user_id=u.id
where u.email = 'gabriela.rocha@cardholder.dev' and w.is_default = true;

-- Quais são os workspaces que ela tem?
select w.name, w.description from auth.users u
join content.workspaces w on w.user_id = u.id
where u.email = 'gabriela.rocha@cardholder.dev';

-- Quantos decks por workspaces?
select w.name, count(*) as workspace_total from auth.users u
join content.workspaces w on w.user_id = u.id
join content.decks d on d.workspace_id = w.id
where u.email = 'gabriela.rocha@cardholder.dev'
group by w.name;

-- Quais são os decks por workspaces?
select d.id, w.name, w.description, d.name, d.description from auth.users u
join content.workspaces w on w.user_id=u.id
join content.decks d on d.workspace_id=w.id
where u.email = 'gabriela.rocha@cardholder.dev';

-- Quais os flashcards para todos os decks de workspace padrão?
select f.front, f.back
from auth.users u
         join content.workspaces w on w.user_id = u.id
         join content.decks d on d.workspace_id = w.id
         join content.flashcards f on f.deck_id = d.id
where u.email = 'gabriela.rocha@cardholder.dev'
and w.name='Meu Workspace';
