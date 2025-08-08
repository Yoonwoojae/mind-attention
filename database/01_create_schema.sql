-- ADHD 앱 전용 스키마 생성
CREATE SCHEMA IF NOT EXISTS adhd_app;

-- 스키마 권한 설정
GRANT USAGE ON SCHEMA adhd_app TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA adhd_app TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA adhd_app TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA adhd_app TO anon, authenticated, service_role;

-- 기본 스키마 권한 설정 (향후 생성될 테이블에도 자동 적용)
ALTER DEFAULT PRIVILEGES IN SCHEMA adhd_app 
GRANT ALL ON TABLES TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA adhd_app 
GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA adhd_app 
GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;

-- 스키마를 검색 경로에 추가 (선택사항)
-- SET search_path TO adhd_app, public;