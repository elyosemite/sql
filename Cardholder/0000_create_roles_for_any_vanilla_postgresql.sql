-- ============================================================================
-- MIGRATION #0: Criar roles do Supabase (apenas para DEV local)
-- ============================================================================
-- ⚠️ Esta migration NÃO deve rodar no Supabase (roles já existem lá)
-- Use apenas no PostgreSQL local via Docker para testes
-- ============================================================================

-- Criar role 'anon' (anonymous users)
DO
$$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles where rolname = 'anon') THEN
            CREATE ROLE anon NOLOGIN;
            RAISE NOTICE 'Role anon criada';
        ELSE
            RAISE NOTICE 'Role anon já existe';
        END IF;
    END
$$;

-- Criar role 'authenticated' (logged users)
DO
$$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles where rolname = 'authenticated') THEN
            CREATE ROLE authenticated NOLOGIN;
            RAISE NOTICE 'Role authenticated criada';
        ELSE
            raise notice 'Role authenticated já existe';
        END IF;
    END
$$;

-- Criar role 'service_role' (admin/backend)
DO
$$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
            CREATE ROLE service_role NOLOGIN BYPASSRLS;
            RAISE NOTICE 'Role service_role criada';
        ELSE
            RAISE NOTICE 'Role service_role já existe';
        END IF;
    END
$$;

-- Garantir que service_role bypassa RLS
ALTER ROLE service_role BYPASSRLS;

-- Dar permissões básicas nos schemas system
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON SCHEMA public TO service_role;

-- ============================================================================
-- IMPORTANTE: Criar schema 'auth' mockado (Supabase tem, Docker não)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS auth;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;

-- Criar tabela auth.users mockada (simplificada)
CREATE TABLE IF NOT EXISTS auth.users
(
    id                 UUID PRIMARY KEY     DEFAULT gen_random_uuid(),
    email              TEXT UNIQUE NOT NULL,
    encrypted_password TEXT,
    email_confirmed_at TIMESTAMPTZ,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Criar função auth.uid() mockada (retorna NULL no Docker, será substituída no Supabase)
CREATE OR REPLACE FUNCTION auth.uid()
    RETURNS UUID
    LANGUAGE sql
    STABLE
AS
$$
SELECT NULL::UUID; -- ← No Docker sempre retorna NULL (você não está "logado")
$$;

COMMENT ON FUNCTION auth.uid() IS 'Função mockada para testes locais. No Supabase retorna o user_id do JWT.';

select *
from auth.users;
