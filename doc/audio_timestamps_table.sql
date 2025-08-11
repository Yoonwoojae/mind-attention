-- Audio Timestamps 테이블 생성
-- 레슨 오디오의 섹션별 타임스탬프 정보 저장

-- 오디오 메타데이터 테이블
CREATE TABLE IF NOT EXISTS mind_attention_play.lesson_audio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id VARCHAR(255) NOT NULL, -- 레슨 ID
    audio_url TEXT NOT NULL, -- 오디오 파일 URL (클라우드 스토리지)
    duration_seconds FLOAT NOT NULL, -- 전체 오디오 길이 (초)
    voice_id VARCHAR(100), -- 사용된 음성 ID (ElevenLabs 등)
    language VARCHAR(10) DEFAULT 'ko', -- 언어 코드
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(lesson_id, language) -- 레슨별, 언어별로 하나의 오디오만
);

-- 섹션별 타임스탬프 테이블
CREATE TABLE IF NOT EXISTS mind_attention_play.audio_timestamps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    audio_id UUID NOT NULL REFERENCES mind_attention_play.lesson_audio(id) ON DELETE CASCADE,
    section_index INT NOT NULL, -- 섹션 순서 (0부터 시작)
    section_type VARCHAR(50), -- heading, subheading, text, bullet_list 등
    start_time FLOAT NOT NULL, -- 시작 시간 (초)
    end_time FLOAT NOT NULL, -- 종료 시간 (초)
    text_content TEXT, -- 해당 섹션의 텍스트 내용
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(audio_id, section_index),
    CHECK (end_time > start_time)
);

-- 단어/문장 단위 상세 타임스탬프 (선택적)
CREATE TABLE IF NOT EXISTS mind_attention_play.audio_word_timestamps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp_id UUID NOT NULL REFERENCES mind_attention_play.audio_timestamps(id) ON DELETE CASCADE,
    word_index INT NOT NULL, -- 단어 순서
    word TEXT NOT NULL, -- 단어
    start_time FLOAT NOT NULL, -- 시작 시간 (초)
    end_time FLOAT NOT NULL, -- 종료 시간 (초)
    
    UNIQUE(timestamp_id, word_index),
    CHECK (end_time > start_time)
);

-- 사용자별 오디오 재생 기록 (선택적 - 분석용)
CREATE TABLE IF NOT EXISTS mind_attention_play.audio_playback_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES mind_attention_play.users(id) ON DELETE CASCADE,
    audio_id UUID NOT NULL REFERENCES mind_attention_play.lesson_audio(id),
    session_id VARCHAR(255), -- 세션/인스턴스 ID
    
    playback_speed FLOAT DEFAULT 1.0, -- 재생 속도
    total_played_seconds FLOAT DEFAULT 0, -- 총 재생 시간
    last_position FLOAT DEFAULT 0, -- 마지막 재생 위치
    completed BOOLEAN DEFAULT FALSE, -- 완료 여부
    
    started_at TIMESTAMPTZ DEFAULT NOW(),
    last_played_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_audio_timestamps_audio_id ON mind_attention_play.audio_timestamps(audio_id);
CREATE INDEX idx_audio_timestamps_time_range ON mind_attention_play.audio_timestamps(start_time, end_time);
CREATE INDEX idx_word_timestamps_timestamp_id ON mind_attention_play.audio_word_timestamps(timestamp_id);
CREATE INDEX idx_user_audio ON mind_attention_play.audio_playback_logs(user_id, audio_id);
CREATE INDEX idx_session ON mind_attention_play.audio_playback_logs(session_id);

-- 코멘트 추가
COMMENT ON TABLE mind_attention_play.lesson_audio IS '레슨 오디오 메타데이터';
COMMENT ON TABLE mind_attention_play.audio_timestamps IS '오디오 섹션별 타임스탬프';
COMMENT ON TABLE mind_attention_play.audio_word_timestamps IS '단어 단위 상세 타임스탬프 (선택적)';
COMMENT ON TABLE mind_attention_play.audio_playback_logs IS '사용자별 오디오 재생 기록';

-- 샘플 데이터 (테스트용)
/*
INSERT INTO mind_attention_play.lesson_audio (lesson_id, audio_url, duration_seconds, voice_id)
VALUES ('focus_training_1', 'https://storage.example.com/audio/focus_training_1_ko.mp3', 180.5, 'rachel_elevenlabs');

INSERT INTO mind_attention_play.audio_timestamps (audio_id, section_index, section_type, start_time, end_time, text_content)
VALUES 
    ((SELECT id FROM mind_attention_play.lesson_audio WHERE lesson_id = 'focus_training_1'), 0, 'heading', 0.0, 2.5, 'ADHD와 집중력 이해하기'),
    ((SELECT id FROM mind_attention_play.lesson_audio WHERE lesson_id = 'focus_training_1'), 1, 'text', 2.5, 15.3, 'ADHD는 뇌의 실행 기능에 영향을 미치는...'),
    ((SELECT id FROM mind_attention_play.lesson_audio WHERE lesson_id = 'focus_training_1'), 2, 'bullet_list', 15.3, 25.8, '주의력 유지 어려움, 충동성 증가...');
*/