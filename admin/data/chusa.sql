CREATE TABLE IF NOT EXISTS hanja (
    id TEXT PRIMARY KEY,
    char_str TEXT NOT NULL,
    reading TEXT,
    meaning TEXT,
    radical TEXT,
    radical_meaning TEXT,
    stroke_count INTEGER,
    school_level TEXT,
    grade_level TEXT,
    shape_explanation TEXT,
    origin_note TEXT,
    difficulty INTEGER,
    stroke_data_id TEXT,
    readings TEXT,
    synonyms TEXT,
    antonyms TEXT,
    variants TEXT,
    -- Firestore hanja_extend/{동일 id} 문서를 통째로 담는 JSON (로컬 편집·동기용). basis 확장 필드와 짝.
    extend_data TEXT,
    sync_status TEXT,          -- 'ADDED', 'MODIFIED', 'DELETED', or NULL
    change_number INTEGER      -- References sync_sessions.id
  );

  CREATE TABLE IF NOT EXISTS sync_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    status TEXT DEFAULT 'ACTIVE',  -- 'ACTIVE', 'SYNCED'
    description TEXT,              -- 작업 로그/설명
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    synced_at DATETIME
  );

  CREATE TABLE IF NOT EXISTS hanja_stroke (
    id TEXT PRIMARY KEY,
    char_str TEXT NOT NULL,
    radical INTEGER,
    font_outline TEXT,
    stroke_outlines TEXT
  );

  CREATE TABLE IF NOT EXISTS hanja_word (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    server_doc_id TEXT UNIQUE,
    word TEXT NOT NULL,
    reading TEXT,
    meaning TEXT,
    details TEXT
  );

-- 기본 활성 채번(Change Number) = 1. 생성·수정·삭제 API에 필요.
INSERT OR IGNORE INTO sync_sessions (id, status, description)
VALUES (1, 'ACTIVE', '초기 마이그레이션');

-- 이미 생성된 chusa.db 에만 칼럼 추가할 때(한 번 실행):
-- ALTER TABLE hanja ADD COLUMN extend_data TEXT;
-- ALTER TABLE hanja_word ADD COLUMN server_doc_id TEXT;