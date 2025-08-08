-- ============================================
-- ADHD 도우미 앱 DB 스키마 (개선 버전)
-- 스키마명: mind_attention_play
-- ============================================

-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS mind_attention_play;
SET search_path TO mind_attention_play;

-- ============================================
-- 1단계: 핵심 테이블 (우선 구현)
-- ============================================

-- 1.1 사용자 기본 정보 (암호화 필드 포함)
CREATE TABLE mind_attention_play.users (
    id TEXT PRIMARY KEY, -- Firebase UID
    username VARCHAR(50) UNIQUE NOT NULL,
    
    -- 암호화된 민감 정보
    encrypted_email TEXT NOT NULL,
    email_iv TEXT NOT NULL,
    encrypted_profile_name TEXT,
    profile_name_iv TEXT,
    encrypted_bio TEXT,
    bio_iv TEXT,
    
    -- 일반 정보
    location VARCHAR(100),
    avatar_url TEXT,
    is_profile_hidden BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.2 카테고리 (단순화)
CREATE TABLE mind_attention_play.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    color_code VARCHAR(7),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 1.3 모듈 (핵심 필드만)
CREATE TABLE mind_attention_play.modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    category_id UUID REFERENCES categories(id),
    estimated_duration_minutes INTEGER,
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.4 세션 (단순화)
CREATE TABLE mind_attention_play.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    session_number INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(module_id, session_number)
);

-- 1.5 세션 항목
CREATE TABLE mind_attention_play.session_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('assessment', 'lesson', 'journal', 'strategy', 'quiz')),
    item_order INTEGER NOT NULL,
    title VARCHAR(200),
    content TEXT, -- 범용 콘텐츠 필드
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(session_id, item_order)
);

-- 1.6 통합 진행상황 테이블 (module + session + item 통합)
CREATE TABLE mind_attention_play.user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    module_id UUID REFERENCES modules(id),
    session_id UUID REFERENCES sessions(id),
    session_item_id UUID REFERENCES session_items(id),
    progress_type VARCHAR(20) NOT NULL CHECK (progress_type IN ('module', 'session', 'item')),
    status VARCHAR(20) DEFAULT 'not_started',
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    time_spent_seconds INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 부분 유니크 인덱스로 조건부 유니크 제약 구현
CREATE UNIQUE INDEX idx_user_progress_module_unique 
    ON mind_attention_play.user_progress(user_id, module_id) 
    WHERE progress_type = 'module';
CREATE UNIQUE INDEX idx_user_progress_session_unique 
    ON mind_attention_play.user_progress(user_id, session_id) 
    WHERE progress_type = 'session';
CREATE UNIQUE INDEX idx_user_progress_item_unique 
    ON mind_attention_play.user_progress(user_id, session_item_id) 
    WHERE progress_type = 'item';

-- 1.7 사용자 응답 (암호화 포함)
CREATE TABLE mind_attention_play.user_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_item_id UUID NOT NULL REFERENCES session_items(id),
    response_type VARCHAR(20) NOT NULL, -- 'journal', 'assessment', 'quiz'
    
    -- 암호화된 응답 (민감한 저널 내용 등)
    encrypted_response TEXT,
    response_iv TEXT,
    
    -- 일반 응답 데이터
    response_data JSONB, -- 퀴즈 답안 등 구조화된 데이터
    is_correct BOOLEAN, -- 퀴즈용
    score INTEGER, -- 평가용
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.8 사용자 통계 (단순화)
CREATE TABLE mind_attention_play.user_statistics (
    user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_modules_completed INTEGER DEFAULT 0,
    total_sessions_completed INTEGER DEFAULT 0,
    total_items_completed INTEGER DEFAULT 0,
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    total_time_spent_minutes INTEGER DEFAULT 0,
    last_activity_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2단계: 목표 및 알림 (1단계와 함께 구현 - ADHD 필수)
-- ============================================

-- 2.1 일일 목표 (JSONB 제거, 정규화)
CREATE TABLE mind_attention_play.daily_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_date DATE NOT NULL,
    goal_type VARCHAR(50) NOT NULL, -- 'focus', 'learning', 'exercise'
    goal_text VARCHAR(200) NOT NULL,
    target_value INTEGER, -- 목표 수치 (분, 개수 등)
    achieved_value INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, goal_date, goal_type)
);

-- 2.2 사용자 기기 정보 (푸시 알림용) - ADHD 필수
CREATE TABLE mind_attention_play.user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    platform VARCHAR(20) CHECK (platform IN ('ios', 'android', 'web')),
    fcm_token TEXT, -- Firebase Cloud Messaging 토큰
    device_model VARCHAR(100),
    os_version VARCHAR(50),
    app_version VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, device_id)
);

-- 2.3 알림 설정 (ADHD 맞춤)
CREATE TABLE mind_attention_play.notification_settings (
    user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    -- 일일 알림
    daily_reminder_enabled BOOLEAN DEFAULT TRUE,
    daily_reminder_time TIME DEFAULT '09:00:00',
    
    -- 약물 복용 알림 (ADHD 중요!)
    medication_reminder_enabled BOOLEAN DEFAULT TRUE,
    medication_morning_time TIME,
    medication_afternoon_time TIME,
    medication_evening_time TIME,
    
    -- 집중 시간 알림
    focus_session_reminder BOOLEAN DEFAULT TRUE,
    focus_break_reminder BOOLEAN DEFAULT TRUE,
    
    -- 미완료 작업 알림
    incomplete_task_reminder BOOLEAN DEFAULT TRUE,
    incomplete_task_hours INTEGER DEFAULT 3, -- N시간 후 리마인드
    
    -- 취침 시간 알림 (ADHD 수면 관리)
    bedtime_reminder_enabled BOOLEAN DEFAULT FALSE,
    bedtime_reminder_time TIME,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.4 예약된 알림 큐 (실제 발송 관리)
CREATE TABLE mind_attention_play.notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- 'daily', 'medication', 'focus', 'incomplete', 'achievement'
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    data JSONB, -- 추가 데이터 (딥링크 등)
    scheduled_at TIMESTAMPTZ NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('high', 'normal', 'low')),
    
    -- 발송 상태
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'cancelled')),
    sent_at TIMESTAMPTZ,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- notification_queue 인덱스는 테이블 생성 후 별도로 생성
CREATE INDEX idx_notification_queue_status_time 
    ON mind_attention_play.notification_queue(status, scheduled_at);

-- 2.5 알림 발송 로그 (추적용)
CREATE TABLE mind_attention_play.notification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200),
    body TEXT,
    
    -- 발송 결과
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMPTZ,
    fcm_message_id TEXT, -- FCM 메시지 ID
    
    -- 사용자 반응
    is_opened BOOLEAN DEFAULT FALSE,
    opened_at TIMESTAMPTZ,
    action_taken VARCHAR(50), -- 'dismissed', 'clicked', 'action_button_1' 등
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.6 반복 알림 스케줄 (약물, 일일 루틴 등)
CREATE TABLE mind_attention_play.recurring_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    
    -- 반복 설정
    is_active BOOLEAN DEFAULT TRUE,
    frequency VARCHAR(20) NOT NULL CHECK (frequency IN ('daily', 'weekly', 'custom')),
    time_of_day TIME NOT NULL,
    days_of_week VARCHAR(7), -- '1234567' (1=월, 7=일)
    
    -- 다음 발송 예정
    next_scheduled_at TIMESTAMPTZ,
    last_sent_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, notification_type, time_of_day)
);

-- ============================================
-- 3단계: 추가 기능 (나중에 구현)
-- ============================================

-- 3.1 모듈 북마크
CREATE TABLE mind_attention_play.bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    module_id UUID REFERENCES modules(id),
    session_item_id UUID REFERENCES session_items(id),
    bookmark_type VARCHAR(20) NOT NULL, -- 'module', 'strategy'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 부분 유니크 인덱스로 조건부 유니크 제약 구현
CREATE UNIQUE INDEX idx_bookmarks_module_unique 
    ON mind_attention_play.bookmarks(user_id, module_id) 
    WHERE bookmark_type = 'module';
CREATE UNIQUE INDEX idx_bookmarks_strategy_unique 
    ON mind_attention_play.bookmarks(user_id, session_item_id) 
    WHERE bookmark_type = 'strategy';

-- 3.2 활동 로그 (분석용)
CREATE TABLE mind_attention_play.activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50), -- 'module', 'session', 'item'
    entity_id UUID,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 필수 인덱스만 생성 (최적화)
-- ============================================

-- 가장 자주 사용될 쿼리 패턴에 대한 인덱스만
CREATE INDEX idx_user_progress_user_module ON mind_attention_play.user_progress(user_id, module_id) 
    WHERE progress_type = 'module';
CREATE INDEX idx_user_progress_user_session ON mind_attention_play.user_progress(user_id, session_id) 
    WHERE progress_type = 'session';
CREATE INDEX idx_sessions_module ON mind_attention_play.sessions(module_id);
CREATE INDEX idx_session_items_session ON mind_attention_play.session_items(session_id);
CREATE INDEX idx_daily_goals_user_date ON mind_attention_play.daily_goals(user_id, goal_date);
CREATE INDEX idx_activity_logs_user_time ON mind_attention_play.activity_logs(user_id, created_at DESC);

-- 푸시 알림 관련 인덱스 (ADHD 필수)
CREATE INDEX idx_user_devices_active ON mind_attention_play.user_devices(user_id, is_active);
CREATE INDEX idx_notification_queue_pending ON mind_attention_play.notification_queue(status, scheduled_at) 
    WHERE status = 'pending';
CREATE INDEX idx_recurring_notifications_active ON mind_attention_play.recurring_notifications(is_active, next_scheduled_at) 
    WHERE is_active = true;

-- ============================================
-- RLS (Row Level Security) 정책
-- ============================================

-- RLS 활성화
ALTER TABLE mind_attention_play.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.user_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.user_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.daily_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.notification_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.notification_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.recurring_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE mind_attention_play.activity_logs ENABLE ROW LEVEL SECURITY;

-- 기본 RLS 정책
CREATE POLICY "Users can view own data" ON mind_attention_play.users
    FOR ALL USING (auth.uid()::text = id);

CREATE POLICY "Users can manage own progress" ON mind_attention_play.user_progress
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own responses" ON mind_attention_play.user_responses
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can view own statistics" ON mind_attention_play.user_statistics
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own goals" ON mind_attention_play.daily_goals
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own devices" ON mind_attention_play.user_devices
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own notifications" ON mind_attention_play.notification_settings
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own notification queue" ON mind_attention_play.notification_queue
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can view own notification logs" ON mind_attention_play.notification_logs
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own recurring notifications" ON mind_attention_play.recurring_notifications
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own bookmarks" ON mind_attention_play.bookmarks
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can view own activity" ON mind_attention_play.activity_logs
    FOR ALL USING (auth.uid()::text = user_id);

-- 공개 콘텐츠 정책
CREATE POLICY "Anyone can view active categories" ON mind_attention_play.categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can view active modules" ON mind_attention_play.modules
    FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can view sessions" ON mind_attention_play.sessions
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view session items" ON mind_attention_play.session_items
    FOR SELECT USING (true);

-- ============================================
-- 트리거 함수
-- ============================================

-- updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION mind_attention_play.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 적용
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON mind_attention_play.users
    FOR EACH ROW EXECUTE FUNCTION mind_attention_play.update_updated_at();

CREATE TRIGGER update_user_progress_updated_at 
    BEFORE UPDATE ON mind_attention_play.user_progress
    FOR EACH ROW EXECUTE FUNCTION mind_attention_play.update_updated_at();

CREATE TRIGGER update_user_responses_updated_at 
    BEFORE UPDATE ON mind_attention_play.user_responses
    FOR EACH ROW EXECUTE FUNCTION mind_attention_play.update_updated_at();

CREATE TRIGGER update_user_statistics_updated_at 
    BEFORE UPDATE ON mind_attention_play.user_statistics
    FOR EACH ROW EXECUTE FUNCTION mind_attention_play.update_updated_at();

-- 통계 자동 업데이트 함수
CREATE OR REPLACE FUNCTION mind_attention_play.update_user_statistics()
RETURNS TRIGGER AS $$
BEGIN
    -- 아이템 완료 시
    IF NEW.progress_type = 'item' AND NEW.status = 'completed' 
       AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE mind_attention_play.user_statistics
        SET total_items_completed = total_items_completed + 1,
            last_activity_date = CURRENT_DATE,
            total_time_spent_minutes = total_time_spent_minutes + COALESCE(NEW.time_spent_seconds / 60, 0)
        WHERE user_id = NEW.user_id;
    
    -- 세션 완료 시
    ELSIF NEW.progress_type = 'session' AND NEW.status = 'completed' 
          AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE mind_attention_play.user_statistics
        SET total_sessions_completed = total_sessions_completed + 1,
            last_activity_date = CURRENT_DATE
        WHERE user_id = NEW.user_id;
    
    -- 모듈 완료 시
    ELSIF NEW.progress_type = 'module' AND NEW.status = 'completed' 
          AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE mind_attention_play.user_statistics
        SET total_modules_completed = total_modules_completed + 1,
            last_activity_date = CURRENT_DATE
        WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_statistics_on_progress
    AFTER INSERT OR UPDATE ON mind_attention_play.user_progress
    FOR EACH ROW EXECUTE FUNCTION mind_attention_play.update_user_statistics();

-- ============================================
-- 초기 데이터 예시
-- ============================================

-- 카테고리 삽입
INSERT INTO mind_attention_play.categories (name, display_name, color_code, display_order) VALUES
('adhd_challenges', 'ADHD Challenges', '#FF6B6B', 1),
('focus_techniques', 'Focus Techniques', '#4ECDC4', 2),
('time_management', 'Time Management', '#45B7D1', 3),
('emotional_regulation', 'Emotional Regulation', '#96CEB4', 4);

-- ============================================
-- 주의사항
-- ============================================
-- 1. 모든 민감한 데이터는 애플리케이션 레벨에서 암호화 후 저장
-- 2. encryption_service.dart 사용하여 암호화/복호화
-- 3. JSONB 필드는 최소한으로 사용 (검색이 필요없는 메타데이터만)
-- 4. 인덱스는 실제 쿼리 패턴 분석 후 추가
-- 5. 단계적 구현: 1단계 → 2단계 → 3단계 순서로 진행