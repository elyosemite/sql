-- ============================================================================
-- SEED: Usuários de teste (apenas para DEV local)
-- ============================================================================

-- Inserir usuários de teste na auth.users
INSERT INTO auth.users (id, email, email_confirmed_at, created_at)
VALUES
    -- Free users (25 usuários - 50%)
    ('00000001-0000-0000-0000-000000000001', 'ana.silva@cardholder.dev', NOW(), NOW() - INTERVAL '30 days'),
    ('00000001-0000-0000-0000-000000000002', 'bruno.santos@cardholder.dev', NOW(), NOW() - INTERVAL '29 days'),
    ('00000001-0000-0000-0000-000000000003', 'carla.oliveira@cardholder.dev', NOW(), NOW() - INTERVAL '28 days'),
    ('00000001-0000-0000-0000-000000000004', 'diego.costa@cardholder.dev', NOW(), NOW() - INTERVAL '27 days'),
    ('00000001-0000-0000-0000-000000000005', 'eduarda.lima@cardholder.dev', NOW(), NOW() - INTERVAL '26 days'),
    ('00000001-0000-0000-0000-000000000006', 'felipe.alves@cardholder.dev', NOW(), NOW() - INTERVAL '25 days'),
    ('00000001-0000-0000-0000-000000000007', 'gabriela.rocha@cardholder.dev', NOW(), NOW() - INTERVAL '24 days'),
    ('00000001-0000-0000-0000-000000000008', 'henrique.martins@cardholder.dev', NOW(), NOW() - INTERVAL '23 days'),
    ('00000001-0000-0000-0000-000000000009', 'isabela.fernandes@cardholder.dev', NOW(), NOW() - INTERVAL '22 days'),
    ('00000001-0000-0000-0000-000000000010', 'joao.pereira@cardholder.dev', NOW(), NOW() - INTERVAL '21 days'),
    ('00000001-0000-0000-0000-000000000011', 'kelly.ribeiro@cardholder.dev', NOW(), NOW() - INTERVAL '20 days'),
    ('00000001-0000-0000-0000-000000000012', 'lucas.barbosa@cardholder.dev', NOW(), NOW() - INTERVAL '19 days'),
    ('00000001-0000-0000-0000-000000000013', 'marina.sousa@cardholder.dev', NOW(), NOW() - INTERVAL '18 days'),
    ('00000001-0000-0000-0000-000000000014', 'nicolas.araujo@cardholder.dev', NOW(), NOW() - INTERVAL '17 days'),
    ('00000001-0000-0000-0000-000000000015', 'olivia.cardoso@cardholder.dev', NOW(), NOW() - INTERVAL '16 days'),
    ('00000001-0000-0000-0000-000000000016', 'paulo.dias@cardholder.dev', NOW(), NOW() - INTERVAL '15 days'),
    ('00000001-0000-0000-0000-000000000017', 'quezia.melo@cardholder.dev', NOW(), NOW() - INTERVAL '14 days'),
    ('00000001-0000-0000-0000-000000000018', 'rafael.castro@cardholder.dev', NOW(), NOW() - INTERVAL '13 days'),
    ('00000001-0000-0000-0000-000000000019', 'sabrina.gomes@cardholder.dev', NOW(), NOW() - INTERVAL '12 days'),
    ('00000001-0000-0000-0000-000000000020', 'thiago.freitas@cardholder.dev', NOW(), NOW() - INTERVAL '11 days'),
    ('00000001-0000-0000-0000-000000000021', 'ursula.nunes@cardholder.dev', NOW(), NOW() - INTERVAL '10 days'),
    ('00000001-0000-0000-0000-000000000022', 'vitor.moreira@cardholder.dev', NOW(), NOW() - INTERVAL '9 days'),
    ('00000001-0000-0000-0000-000000000023', 'wanda.pinto@cardholder.dev', NOW(), NOW() - INTERVAL '8 days'),
    ('00000001-0000-0000-0000-000000000024', 'xavier.cunha@cardholder.dev', NOW(), NOW() - INTERVAL '7 days'),
    ('00000001-0000-0000-0000-000000000025', 'yasmin.azevedo@cardholder.dev', NOW(), NOW() - INTERVAL '6 days'),

    -- Premium users (20 usuários - 40%)
    ('00000002-0000-0000-0000-000000000001', 'amanda.correia@cardholder.dev', NOW(), NOW() - INTERVAL '60 days'),
    ('00000002-0000-0000-0000-000000000002', 'bernardo.teixeira@cardholder.dev', NOW(), NOW() - INTERVAL '58 days'),
    ('00000002-0000-0000-0000-000000000003', 'camila.rodrigues@cardholder.dev', NOW(), NOW() - INTERVAL '56 days'),
    ('00000002-0000-0000-0000-000000000004', 'daniel.cavalcanti@cardholder.dev', NOW(), NOW() - INTERVAL '54 days'),
    ('00000002-0000-0000-0000-000000000005', 'elisa.mendes@cardholder.dev', NOW(), NOW() - INTERVAL '52 days'),
    ('00000002-0000-0000-0000-000000000006', 'fabricio.vieira@cardholder.dev', NOW(), NOW() - INTERVAL '50 days'),
    ('00000002-0000-0000-0000-000000000007', 'giovanna.barros@cardholder.dev', NOW(), NOW() - INTERVAL '48 days'),
    ('00000002-0000-0000-0000-000000000008', 'hugo.monteiro@cardholder.dev', NOW(), NOW() - INTERVAL '46 days'),
    ('00000002-0000-0000-0000-000000000009', 'ines.rezende@cardholder.dev', NOW(), NOW() - INTERVAL '44 days'),
    ('00000002-0000-0000-0000-000000000010', 'julio.carvalho@cardholder.dev', NOW(), NOW() - INTERVAL '42 days'),
    ('00000002-0000-0000-0000-000000000011', 'larissa.nascimento@cardholder.dev', NOW(), NOW() - INTERVAL '40 days'),
    ('00000002-0000-0000-0000-000000000012', 'marcelo.campos@cardholder.dev', NOW(), NOW() - INTERVAL '38 days'),
    ('00000002-0000-0000-0000-000000000013', 'natalia.xavier@cardholder.dev', NOW(), NOW() - INTERVAL '36 days'),
    ('00000002-0000-0000-0000-000000000014', 'otavio.lopes@cardholder.dev', NOW(), NOW() - INTERVAL '34 days'),
    ('00000002-0000-0000-0000-000000000015', 'patricia.ferreira@cardholder.dev', NOW(), NOW() - INTERVAL '32 days'),
    ('00000002-0000-0000-0000-000000000016', 'quentin.ramos@cardholder.dev', NOW(), NOW() - INTERVAL '30 days'),
    ('00000002-0000-0000-0000-000000000017', 'renata.duarte@cardholder.dev', NOW(), NOW() - INTERVAL '28 days'),
    ('00000002-0000-0000-0000-000000000018', 'sergio.pires@cardholder.dev', NOW(), NOW() - INTERVAL '26 days'),
    ('00000002-0000-0000-0000-000000000019', 'tatiana.moura@cardholder.dev', NOW(), NOW() - INTERVAL '24 days'),
    ('00000002-0000-0000-0000-000000000020', 'ulisses.macedo@cardholder.dev', NOW(), NOW() - INTERVAL '22 days'),

    -- Pro users (5 usuários - 10%)
    ('00000003-0000-0000-0000-000000000001', 'veronica.nogueira@cardholder.dev', NOW(), NOW() - INTERVAL '120 days'),
    ('00000003-0000-0000-0000-000000000002', 'william.fonseca@cardholder.dev', NOW(), NOW() - INTERVAL '110 days'),
    ('00000003-0000-0000-0000-000000000003', 'ximena.braga@cardholder.dev', NOW(), NOW() - INTERVAL '100 days'),
    ('00000003-0000-0000-0000-000000000004', 'yuri.pacheco@cardholder.dev', NOW(), NOW() - INTERVAL '90 days'),
    ('00000003-0000-0000-0000-000000000005', 'zilda.silva@cardholder.dev', NOW(), NOW() - INTERVAL '80 days')
ON CONFLICT (id) DO NOTHING;

-- Inserir planos de assinatura (se ainda não existem)
INSERT INTO billing.subscription_plans (plan_code,
                                        display_name,
                                        description,
                                        price_cents,
                                        currency,
                                        max_workspaces,
                                        max_decks_per_workspaces,
                                        max_flashcards_per_decks)
VALUES ('free',
        'Free',
        'Plano gratuito com limites básicos',
        0,
        'BRL',
        3,
        5,
        2500),
       ('premium',
        'Premium',
        'Plano intermediário para estudantes dedicados',
        1990, -- R$ 19,90
        'BRL',
        10,
        20,
        5000),
       ('pro',
        'Pro',
        'Plano ilimitado para profissionais',
        4990, -- R$ 49,90
        'BRL',
        NULL, -- ilimitado
        NULL, -- ilimitado
        NULL -- ilimitado
       )
ON CONFLICT (plan_code) DO NOTHING;

-- Free users (25)
INSERT INTO billing.user_subscriptions (user_id, plan_id, status, started_at)
SELECT u.id,        -- Pegamos o Id de auth.user
       sp.id,       -- Pegamos o Id de subscription_plan
       'active',    -- Status sempre 'active'
       u.created_at -- Pegamos a data em que foi criado o auth.user
FROM auth.users u
         CROSS JOIN billing.subscription_plans sp
WHERE sp.plan_code = 'free'
  AND u.id::text LIKE '00000001-%' -- Padrão para free users
  AND NOT EXISTS (SELECT 1
                  FROM billing.user_subscriptions
                  WHERE user_id = u.id
                    AND status = 'active');

-- Premium users (20)
INSERT INTO billing.user_subscriptions (user_id, plan_id, status, started_at, expires_at)
SELECT u.id,
       sp.id,
       'active',
       u.created_at,
       u.created_at + INTERVAL '1 year'
FROM auth.users u
         CROSS JOIN billing.subscription_plans sp
WHERE sp.plan_code = 'premium'
  AND u.id::text LIKE '00000002-%' -- Padrão para premium users
  AND NOT EXISTS (SELECT 1
                  FROM billing.user_subscriptions
                  WHERE user_id = u.id
                    AND status = 'active');

-- Pro users (5)
INSERT INTO billing.user_subscriptions (user_id, plan_id, status, started_at)
SELECT u.id,
       sp.id,
       'active',
       u.created_at
FROM auth.users u
         CROSS JOIN billing.subscription_plans sp
WHERE sp.plan_code = 'pro'
  AND u.id::text LIKE '00000003-%' -- Padrão para pro users
  AND NOT EXISTS (SELECT 1
                  FROM billing.user_subscriptions
                  WHERE user_id = u.id
                    AND status = 'active');

-- Criar workspace default para cada usuário
INSERT INTO content.workspaces (user_id, name, description, is_default, sort_order, created_at)
SELECT u.id,
       'Meu Workspace',
       'Workspace padrão',
       true,
       0,
       u.created_at
FROM auth.users u
WHERE NOT EXISTS (SELECT 1
                  FROM content.workspaces
                  WHERE user_id = u.id
                    AND is_default = true);

-- Free users: 1-2 workspaces adicionais (além do default)
INSERT INTO content.workspaces (user_id, name, description, color, icon, is_default, sort_order, created_at)
SELECT u.id,
       workspace_name,
       workspace_desc,
       workspace_color,
       workspace_icon,
       false,
       workspace_order,
       u.created_at + (workspace_order || ' days')::INTERVAL
FROM auth.users u
         CROSS JOIN (VALUES (1, 'Medicina', 'Estudos médicos', '#FF6B6B', '🏥'),
                            (2, 'Inglês', 'Vocabulário e gramática', '#4ECDC4', '🇬🇧')) AS workspaces(workspace_order,
                                                                                                     workspace_name,
                                                                                                     workspace_desc,
                                                                                                     workspace_color,
                                                                                                     workspace_icon)
WHERE u.id::text LIKE '00000001-%'
  AND u.id::text <= '00000001-0000-0000-0000-000000000015' -- Só metade dos free
  AND NOT EXISTS (SELECT 1
                  FROM content.workspaces
                  WHERE user_id = u.id
                    AND name = workspace_name);

-- Premium users: 3-5 workspaces adicionais
INSERT INTO content.workspaces (user_id, name, description, color, icon, is_default, sort_order, created_at)
SELECT u.id,
       workspace_name,
       workspace_desc,
       workspace_color,
       workspace_icon,
       false,
       workspace_order,
       u.created_at + (workspace_order || ' days')::INTERVAL
FROM auth.users u
         CROSS JOIN (VALUES (1, 'Engenharia Civil', 'Disciplinas do curso', '#95E1D3', '🏗️'),
                            (2, 'Cálculo I', 'Limites, derivadas e integrais', '#F38181', '📐'),
                            (3, 'Física I', 'Mecânica clássica', '#AA96DA', '⚛️'),
                            (4, 'Química Geral', 'Tabela periódica e reações', '#FCBAD3', '🧪'),
                            (5, 'Programação', 'Python, JavaScript e SQL', '#FFFFD2',
                             '💻')) AS workspaces(workspace_order, workspace_name, workspace_desc, workspace_color,
                                                 workspace_icon)
WHERE u.id::text LIKE '00000002-%'
  AND NOT EXISTS (SELECT 1
                  FROM content.workspaces
                  WHERE user_id = u.id
                    AND name = workspace_name);

-- Pro users: 5-10 workspaces adicionais
INSERT INTO content.workspaces (user_id, name, description, color, icon, is_default, sort_order, created_at)
SELECT u.id,
       workspace_name,
       workspace_desc,
       workspace_color,
       workspace_icon,
       false,
       workspace_order,
       u.created_at + (workspace_order || ' days')::INTERVAL
FROM auth.users u
         CROSS JOIN (VALUES (1, 'Direito Penal', 'Código penal e jurisprudência', '#FF6B6B', '⚖️'),
                            (2, 'Direito Civil', 'Código civil e doutrina', '#4ECDC4', '📚'),
                            (3, 'Processo Civil', 'CPC e procedimentos', '#95E1D3', '📋'),
                            (4, 'Direito Constitucional', 'CF/88 e STF', '#F38181', '🏛️'),
                            (5, 'Direito Administrativo', 'Atos e processos', '#AA96DA', '🏢'),
                            (6, 'Direito Tributário', 'CTN e impostos', '#FCBAD3', '💰'),
                            (7, 'Direito Empresarial', 'Sociedades e falência', '#FFFFD2', '🏪'),
                            (8, 'Direito do Trabalho', 'CLT e dissídios', '#A8E6CF', '👷'),
                            (9, 'Direito Ambiental', 'Legislação ambiental', '#FFD3B6', '🌳'),
                            (10, 'Medicina Legal', 'Perícias e laudos', '#FFAAA5', '🔬')) AS workspaces(workspace_order,
                                                                                                       workspace_name,
                                                                                                       workspace_desc,
                                                                                                       workspace_color,
                                                                                                       workspace_icon)
WHERE u.id::text LIKE '00000003-%'
  AND NOT EXISTS (SELECT 1
                  FROM content.workspaces
                  WHERE user_id = u.id
                    AND name = workspace_name);

-- ============================================================================
-- VALIDAÇÃO: Queries para verificar se seed funcionou
-- ============================================================================

-- Ver usuários criados
SELECT id, email, email_confirmed_at
FROM auth.users
ORDER BY email;

-- Ver planos disponíveis
SELECT plan_code, display_name, price_cents, max_workspaces
FROM billing.subscription_plans
ORDER BY price_cents;

-- Ver assinaturas ativas
SELECT u.email,
       sp.plan_code,
       us.status,
       us.started_at
FROM billing.user_subscriptions us
         JOIN auth.users u ON u.id = us.user_id
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
WHERE us.status = 'active'
ORDER BY u.email;

-- Ver workspaces por usuário
SELECT u.email,
       COUNT(*)          as total_workspaces,
       sp.max_workspaces as limite
FROM content.workspaces w
         JOIN auth.users u ON u.id = w.user_id
         JOIN billing.user_subscriptions us ON us.user_id = u.id AND us.status = 'active'
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
WHERE w.deleted_at IS NULL
GROUP BY u.email, sp.max_workspaces
ORDER BY u.email;

select *
from auth.users;
select *
from billing.subscription_plans;
select *
from billing.user_subscriptions;
select *
from content.workspaces;

SELECT u.email, sp.display_name
FROM auth.users u
         inner join billing.user_subscriptions us on us.user_id = u.id
         inner join billing.subscription_plans sp on us.plan_id = sp.id
where u.email = 'isabela.fernandes@cardholder.dev'
   or u.email = 'clovisdebarrosfilho@cardholder.dev';

-- ============================================================================
-- VALIDAÇÕES: Queries para verificar dados
-- ============================================================================

-- Total de usuários por plano
SELECT sp.plan_code,
       COUNT(*) as total_usuarios
FROM billing.user_subscriptions us
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
WHERE us.status = 'active'
GROUP BY sp.plan_code
ORDER BY sp.plan_code;

-- Distribuição de workspaces por plano
SELECT sp.plan_code,
       COUNT(DISTINCT w.user_id)          as usuarios_com_workspaces,
       COUNT(w.id)                        as total_workspaces,
       ROUND(AVG(workspace_count.cnt), 2) as media_workspaces_por_usuario
FROM billing.user_subscriptions us
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
         LEFT JOIN content.workspaces w ON w.user_id = us.user_id AND w.deleted_at IS NULL
         LEFT JOIN (SELECT user_id, COUNT(*) as cnt
                    FROM content.workspaces
                    WHERE deleted_at IS NULL
                    GROUP BY user_id) workspace_count ON workspace_count.user_id = us.user_id
WHERE us.status = 'active'
GROUP BY sp.plan_code, sp.price_cents
ORDER BY sp.price_cents;

-- Listar alguns usuários de exemplo
SELECT u.email,
       sp.plan_code,
       COUNT(w.id)       as total_workspaces,
       sp.max_workspaces as limite
FROM auth.users u
         JOIN billing.user_subscriptions us ON us.user_id = u.id AND us.status = 'active'
         JOIN billing.subscription_plans sp ON sp.id = us.plan_id
         LEFT JOIN content.workspaces w ON w.user_id = u.id AND w.deleted_at IS NULL
GROUP BY u.email, sp.plan_code, sp.max_workspaces, sp.price_cents
ORDER BY sp.price_cents, u.email
LIMIT 20;

-- Resumo geral
SELECT (SELECT COUNT(*) FROM auth.users)                                         as total_usuarios,
       (SELECT COUNT(*) FROM billing.user_subscriptions WHERE status = 'active') as total_assinaturas_ativas,
       (SELECT COUNT(*) FROM content.workspaces WHERE deleted_at IS NULL)        as total_workspaces;

-- ============================================================================
-- COMENTÁRIOS
-- ============================================================================

COMMENT ON TABLE auth.users IS 'Tabela mockada de usuários (apenas para DEV local)';

-- Todos os workspaces com email: ana.silva@cardholder.dev
select u.email, count(*) as Worksaces
from auth.users u
         join content.workspaces w on w.user_id = u.id
where u.email = 'ana.silva@cardholder.dev'
group by u.email;

-- Todos os worksaces atravez do user_id
select *
from content.workspaces
where user_id = '00000001-0000-0000-0000-000000000001'
