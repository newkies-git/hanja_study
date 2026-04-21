import express from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import Database from 'better-sqlite3';

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// `process.cwd()`에 의존하면 실행 위치에 따라 DB를 못 찾음 → server.js 기준 admin/data
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_DIR = process.env.CHUSA_DATA_DIR
    ? path.resolve(process.env.CHUSA_DATA_DIR)
    : path.resolve(__dirname, '../data');
const DB_PATH = path.join(DATA_DIR, 'chusa.db');

if (!fs.existsSync(DB_PATH)) {
    console.error(
        `[chusa-admin] SQLite 파일이 없습니다: ${DB_PATH}\n` +
            '  - 레포의 admin/data/chusa.db 가 있는지 확인하거나 CHUSA_DATA_DIR 로 디렉터리를 지정하세요.',
    );
    process.exit(1);
}

let db;
try {
    db = new Database(DB_PATH);
} catch (err) {
    console.error('[chusa-admin] SQLite 열기 실패:', err);
    process.exit(1);
}

/** 레거시 chusa.db — API가 기대하는 컬럼이 없으면 한 번씩 추가 */
function ensureHanjaColumnsForAdminApi() {
    const tableExists = db
        .prepare("SELECT 1 FROM sqlite_master WHERE type='table' AND name='hanja'")
        .get();
    if (!tableExists) return;

    const names = new Set(
        db.prepare('PRAGMA table_info(hanja)').all().map((c) => String(c.name).toLowerCase()),
    );
    const add = (col, ddlType) => {
        const key = String(col).toLowerCase();
        if (names.has(key)) return;
        db.prepare(`ALTER TABLE hanja ADD COLUMN ${col} ${ddlType}`).run();
        names.add(key);
        console.log(`[chusa-admin] 마이그레이션: hanja.${col} 컬럼 추가`);
    };
    add('origin_note', 'TEXT');
    add('etymology', 'TEXT');
    add('analogue', 'TEXT');
    add('sync_status', 'TEXT');
    add('change_number', 'INTEGER');
    add('readings', 'TEXT');
    add('synonyms', 'TEXT');
    add('antonyms', 'TEXT');
    add('variants', 'TEXT');
}

ensureHanjaColumnsForAdminApi();

/** 레거시 chusa.db — hanja_word.server_doc_id 및 UNIQUE(동기 upsert용) */
function ensureHanjaWordColumnsForAdminApi() {
    const tableExists = db
        .prepare("SELECT 1 FROM sqlite_master WHERE type='table' AND name='hanja_word'")
        .get();
    if (!tableExists) return;

    const names = new Set(
        db.prepare('PRAGMA table_info(hanja_word)').all().map((c) => String(c.name).toLowerCase()),
    );
    if (!names.has('server_doc_id')) {
        db.prepare('ALTER TABLE hanja_word ADD COLUMN server_doc_id TEXT').run();
        console.log('[chusa-admin] 마이그레이션: hanja_word.server_doc_id 컬럼 추가');
    }
    if (!names.has('related_hanja')) {
        db.prepare('ALTER TABLE hanja_word ADD COLUMN related_hanja TEXT').run();
        console.log('[chusa-admin] 마이그레이션: hanja_word.related_hanja 컬럼 추가');
    }
    if (!names.has('change_number')) {
        db.prepare('ALTER TABLE hanja_word ADD COLUMN change_number INTEGER').run();
        console.log('[chusa-admin] 마이그레이션: hanja_word.change_number 컬럼 추가');
    }
    const idx = db
        .prepare(
            "SELECT 1 FROM sqlite_master WHERE type='index' AND name='hanja_word_server_doc_id_uq'",
        )
        .get();
    if (!idx) {
        db.exec(
            'CREATE UNIQUE INDEX IF NOT EXISTS hanja_word_server_doc_id_uq ON hanja_word(server_doc_id)',
        );
        console.log('[chusa-admin] 마이그레이션: hanja_word.server_doc_id UNIQUE 인덱스');
    }
}

ensureHanjaWordColumnsForAdminApi();

function ensureHanjaStrokeColumnsForAdminApi() {
    const tableExists = db
        .prepare("SELECT 1 FROM sqlite_master WHERE type='table' AND name='hanja_stroke'")
        .get();
    if (!tableExists) return;

    const names = new Set(
        db.prepare('PRAGMA table_info(hanja_stroke)').all().map((c) => String(c.name).toLowerCase()),
    );
    if (!names.has('change_number')) {
        db.prepare('ALTER TABLE hanja_stroke ADD COLUMN change_number INTEGER').run();
        console.log('[chusa-admin] 마이그레이션: hanja_stroke.change_number 컬럼 추가');
    }
}

ensureHanjaStrokeColumnsForAdminApi();

function ensureSyncSessionsTable() {
    db.exec(`
        CREATE TABLE IF NOT EXISTS sync_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            status TEXT DEFAULT 'ACTIVE',
            description TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            synced_at DATETIME
        )
    `);
}

ensureSyncSessionsTable();

// Helper to safely parse JSON strings from SQLite
const parseJSON = (str) => {
    try { return str ? JSON.parse(str) : null; }
    catch(e) { console.warn('[parseJSON] 파싱 실패:', e.message, '| 입력:', String(str).slice(0, 80)); return null; }
};
const parseJsonArray = (str) => { const v = parseJSON(str); return Array.isArray(v) ? v : []; };
const parseJsonObject = (str) => { const v = parseJSON(str); return (v && typeof v === 'object' && !Array.isArray(v)) ? v : {}; };

// GET /api/hanja : List all hanjas (with pagination + optional filters)
app.get('/api/hanja', (req, res) => {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(Math.max(1, parseInt(req.query.limit) || 50), 500);
    const offset = (page - 1) * limit;

    const conditions = [];
    const params = [];

    const subNeedle = (q) => String(q || '').trim().toLowerCase();
    const qNeedle = subNeedle(req.query.q);

    if (qNeedle) {
        conditions.push(`(
            instr(lower(ifnull(char_str, '')), ?) > 0 OR
            instr(lower(ifnull(reading, '')), ?) > 0 OR
            instr(lower(ifnull(cast(stroke_count as text), '')), ?) > 0
        )`);
        params.push(qNeedle, qNeedle, qNeedle);
    } else {
        const han = subNeedle(req.query.han);
        const ja = subNeedle(req.query.ja);
        const reading = subNeedle(req.query.reading);
        const meaning = subNeedle(req.query.meaning);

        if (han) {
            conditions.push('instr(lower(char_str), ?) > 0');
            params.push(han);
        }
        if (reading) {
            conditions.push('instr(lower(ifnull(reading, "")), ?) > 0');
            params.push(reading);
        }
        if (meaning) {
            conditions.push('instr(lower(ifnull(meaning, "")), ?) > 0');
            params.push(meaning);
        }
    }

    const sync = String(req.query.sync || '').trim();
    const allowedSync = new Set(['ADDED', 'MODIFIED', 'DELETED']);
    if (sync && allowedSync.has(sync)) {
        conditions.push('sync_status = ?');
        params.push(sync);
    }

    const gubun = String(req.query.gubun || '').trim();
    if (gubun === '중' || gubun === '고') {
        conditions.push(
            "trim(ifnull(ifnull(json_extract(origin_note, '$.grade'), json_extract(origin_note, '$.구분')), '')) = ?",
        );
        params.push(gubun);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const countRaw = db.prepare(`SELECT COUNT(*) as count FROM hanja ${whereClause}`).get(...params);

    const rows = db.prepare(`
        SELECT id, char_str as hanja, reading, meaning, stroke_count, difficulty, sync_status, change_number,
               origin_note, readings, synonyms, antonyms, analogue, variants
        FROM hanja
        ${whereClause}
        ORDER BY id ASC
        LIMIT ? OFFSET ?
    `).all(...params, limit, offset);

    res.json({
        data: rows.map((r) => ({
            ...r,
            char: r.hanja,
            readings: parseJsonArray(r.readings),
            synonyms: parseJsonArray(r.synonyms),
            antonyms: parseJsonArray(r.antonyms),
            analogue: parseJsonArray(r.analogue ?? r.Analogue),
            variants: parseJsonArray(r.variants),
        })),
        total: countRaw.count,
        page,
        limit,
    });
});

// GET /api/hanja/:id : Retrieve details including strokes
app.get('/api/hanja/:id', (req, res) => {
    const { id } = req.params;
    
    const row = db.prepare('SELECT * FROM hanja WHERE id = ?').get(id);
    if (!row) {
        return res.status(404).json({ error: 'Not found' });
    }

    const stroke = db.prepare('SELECT * FROM hanja_stroke WHERE id = ?').get(id);

    const extendRaw = row.origin_note;
    const rowOut = { ...row };
    delete rowOut.origin_note;

    res.json({
        ...rowOut,
        readings: parseJsonArray(row.readings),
        synonyms: parseJsonArray(row.synonyms),
        antonyms: parseJsonArray(row.antonyms),
        analogue: parseJsonArray(row.analogue ?? row.Analogue),
        variants: parseJsonArray(row.variants),
        extend: parseJsonObject(extendRaw),
        font_outline: stroke ? parseJsonArray(stroke.font_outline) : [],
        stroke_outlines: stroke ? parseJsonArray(stroke.stroke_outlines) : []
    });
});

// GET /api/session : Get active session
app.get('/api/session', (req, res) => {
    const row = db.prepare("SELECT * FROM sync_sessions WHERE status = 'ACTIVE' ORDER BY id DESC LIMIT 1").get();
    res.json({ data: row || null });
});

// POST /api/session : Start a new active session
app.post('/api/session', (req, res) => {
    try {
        const { description } = req.body || {};
        db.prepare(
            "UPDATE sync_sessions SET status = 'SYNCED', synced_at = CURRENT_TIMESTAMP WHERE status = 'ACTIVE'",
        ).run();
        const result = db
            .prepare("INSERT INTO sync_sessions (status, description) VALUES ('ACTIVE', ?)")
            .run(description ?? null);
        const rowId = Number(result.lastInsertRowid);
        const session = db.prepare("SELECT * FROM sync_sessions WHERE id = ?").get(rowId);
        if (!session) {
            console.error("[chusa-admin] POST /api/session: INSERT 후 행 조회 실패 rowId=", rowId);
            return res.status(500).json({ error: "채번 행을 조회하지 못했습니다." });
        }
        res.json({ data: session });
    } catch (err) {
        console.error("[chusa-admin] POST /api/session:", err);
        res.status(500).json({ error: err.message || "채번 발급에 실패했습니다." });
    }
});

// PUT /api/session/:id : Update session description
app.put('/api/session/:id', (req, res) => {
    const { id } = req.params;
    const { description } = req.body || {};
    
    // Only allow updating if ACTIVE
    const existing = db.prepare("SELECT status FROM sync_sessions WHERE id = ?").get(id);
    if (!existing || existing.status !== 'ACTIVE') {
        return res.status(400).json({ error: 'Cannot update non-active sessions' });
    }
    
    db.prepare("UPDATE sync_sessions SET description = ? WHERE id = ?").run(description, id);
    const session = db.prepare("SELECT * FROM sync_sessions WHERE id = ?").get(id);
    res.json({ data: session });
});

// PUT /api/hanja/:id : Update detail data
app.put('/api/hanja/:id', (req, res) => {
    const { id } = req.params;
    const body = req.body;

    if (!body.change_number) {
        return res.status(400).json({ error: 'change_number is required' });
    }

    // Convert arrays back to JSON strings for SQLite
    const readingsStr = JSON.stringify(body.readings || []);
    const synonymsStr = JSON.stringify(body.synonyms || []);
    const antonymsStr = JSON.stringify(body.antonyms || []);
    const analogueStr = JSON.stringify(body.analogue || body.Analogue || []);
    const variantsStr = JSON.stringify(body.variants || []);
    const extendStr = JSON.stringify(body.extend ?? {});

    // Check existing sync_status so we don't overwrite 'ADDED' with 'MODIFIED'
    const existing = db.prepare('SELECT sync_status FROM hanja WHERE id = ?').get(id);
    let syncStatus = 'MODIFIED';
    if (existing && existing.sync_status === 'ADDED') {
        syncStatus = 'ADDED';
    }

    const stmt = db.prepare(`
        UPDATE hanja SET 
            char_str = coalesce(?, char_str),
            reading = coalesce(?, reading),
            meaning = coalesce(?, meaning),
            radical = coalesce(?, radical),
            radical_meaning = coalesce(?, radical_meaning),
            stroke_count = coalesce(?, stroke_count),
            school_level = coalesce(?, school_level),
            shape_explanation = coalesce(?, shape_explanation),
            etymology = coalesce(?, etymology),
            difficulty = coalesce(?, difficulty),
            readings = ?,
            synonyms = ?,
            antonyms = ?,
            analogue = ?,
            variants = ?,
            origin_note = ?,
            sync_status = ?,
            change_number = ?
        WHERE id = ?
    `);

    try {
        stmt.run(
            body.char_str,
            body.reading,
            body.meaning,
            body.radical,
            body.radical_meaning,
            body.stroke_count,
            body.school_level,
            body.shape_explanation,
            body.etymology ?? body.Etymology,
            body.difficulty,
            readingsStr,
            synonymsStr,
            antonymsStr,
            analogueStr,
            variantsStr,
            extendStr,
            syncStatus,
            body.change_number,
            id
        );
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update' });
    }
});

// POST /api/hanja : Create new hanja record
app.post('/api/hanja', (req, res) => {
    const body = req.body;

    if (!body.change_number || !body.id) {
        return res.status(400).json({ error: 'id and change_number are required' });
    }

    const readingsStr = JSON.stringify(body.readings || []);
    const synonymsStr = JSON.stringify(body.synonyms || []);
    const antonymsStr = JSON.stringify(body.antonyms || []);
    const analogueStr = JSON.stringify(body.analogue || body.Analogue || []);
    const variantsStr = JSON.stringify(body.variants || []);
    const extendStr = JSON.stringify(body.extend ?? {});

    const stmt = db.prepare(`
        INSERT INTO hanja (
            id, char_str, reading, meaning, radical, radical_meaning,
            stroke_count, school_level,
            shape_explanation, etymology, difficulty, readings,
            synonyms, antonyms, analogue, variants, origin_note, sync_status, change_number
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ADDED', ?
        )
    `);

    try {
        stmt.run(
            body.id, body.char_str || body.id, body.reading, body.meaning, body.radical, body.radical_meaning,
            body.stroke_count, body.school_level,
            body.shape_explanation, body.etymology ?? body.Etymology, body.difficulty, readingsStr,
            synonymsStr, antonymsStr, analogueStr, variantsStr, extendStr, body.change_number
        );
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to create' });
    }
});

// PUT /api/hanja/upsert : Create or update hanja (used by server-to-local sync)
app.put('/api/hanja/upsert', (req, res) => {
    const body = req.body;

    if (!body.id || !body.change_number) {
        return res.status(400).json({ error: 'id and change_number are required' });
    }

    const readingsStr = JSON.stringify(body.readings || []);
    const synonymsStr = JSON.stringify(body.synonyms || []);
    const antonymsStr = JSON.stringify(body.antonyms || []);
    const analogueStr = JSON.stringify(body.analogue || body.Analogue || []);
    const variantsStr = JSON.stringify(body.variants || []);
    const extendStr = JSON.stringify(body.extend ?? {});

    try {
        db.prepare(`
            INSERT INTO hanja (
                id, char_str, reading, meaning, radical, radical_meaning,
                stroke_count, school_level,
                shape_explanation, etymology, difficulty, readings,
                synonyms, antonyms, analogue, variants, origin_note, sync_status, change_number
            ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ADDED', ?
            )
            ON CONFLICT(id) DO UPDATE SET
                char_str = coalesce(excluded.char_str, char_str),
                reading = coalesce(excluded.reading, reading),
                meaning = coalesce(excluded.meaning, meaning),
                radical = coalesce(excluded.radical, radical),
                radical_meaning = coalesce(excluded.radical_meaning, radical_meaning),
                stroke_count = coalesce(excluded.stroke_count, stroke_count),
                school_level = coalesce(excluded.school_level, school_level),
                shape_explanation = coalesce(excluded.shape_explanation, shape_explanation),
                etymology = coalesce(excluded.etymology, etymology),
                difficulty = coalesce(excluded.difficulty, difficulty),
                readings = excluded.readings,
                synonyms = excluded.synonyms,
                antonyms = excluded.antonyms,
                analogue = excluded.analogue,
                variants = excluded.variants,
                origin_note = excluded.origin_note,
                sync_status = CASE WHEN sync_status = 'ADDED' THEN 'ADDED' ELSE 'MODIFIED' END,
                change_number = excluded.change_number
        `).run(
            body.id, body.char_str || body.id, body.reading, body.meaning, body.radical, body.radical_meaning,
            body.stroke_count, body.school_level,
            body.shape_explanation, body.etymology ?? body.Etymology, body.difficulty, readingsStr,
            synonymsStr, antonymsStr, analogueStr, variantsStr, extendStr, body.change_number
        );
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to upsert' });
    }
});

// DELETE /api/hanja/:id : Soft delete hanja
app.delete('/api/hanja/:id', (req, res) => {
    const { id } = req.params;
    const { change_number } = req.body; // usually DELETE body is tricky, but we can accept it or use query

    if (!change_number) {
        return res.status(400).json({ error: 'change_number is required' });
    }

    // Soft delete
    try {
        db.prepare("UPDATE hanja SET sync_status = 'DELETED', change_number = ? WHERE id = ?").run(change_number, id);
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete' });
    }
});

// ── 동기화 보조 API ─────────────────────────────────────────────────────────

app.get('/api/sync/stats', (req, res) => {
    const hanja = db.prepare(
        "SELECT COUNT(*) as c FROM hanja WHERE sync_status IS NULL OR sync_status != 'DELETED'",
    ).get();
    const stroke = db.prepare('SELECT COUNT(*) as c FROM hanja_stroke').get();
    const word = db.prepare('SELECT COUNT(*) as c FROM hanja_word').get();
    res.json({
        hanja: hanja.c,
        hanja_stroke: stroke.c,
        hanja_word: word.c,
    });
});

app.get('/api/hanja_stroke/list', (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 200, 500);
    const offset = (page - 1) * limit;
    const totalRow = db.prepare('SELECT COUNT(*) as c FROM hanja_stroke').get();
    const rows = db.prepare(
        'SELECT id, char_str, radical, font_outline, stroke_outlines, change_number FROM hanja_stroke ORDER BY id LIMIT ? OFFSET ?',
    ).all(limit, offset);
    res.json({ data: rows, total: totalRow.c, page, limit });
});

app.put('/api/hanja_stroke/:id', (req, res) => {
    const { id } = req.params;
    const body = req.body || {};
    if (!body.change_number) {
        return res.status(400).json({ error: 'change_number is required' });
    }
    const fo = JSON.stringify(body.font_outline ?? []);
    const so = JSON.stringify(body.stroke_outlines ?? []);
    const char_str = body.char_str || id;
    const radical = body.radical === undefined || body.radical === null ? null : Number(body.radical);
    const change_number = Number(body.change_number);
    try {
        db.prepare(`
            INSERT INTO hanja_stroke (id, char_str, radical, font_outline, stroke_outlines, change_number)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                char_str = excluded.char_str,
                radical = excluded.radical,
                font_outline = excluded.font_outline,
                stroke_outlines = excluded.stroke_outlines,
                change_number = excluded.change_number
        `).run(id, char_str, radical, fo, so, change_number);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to upsert stroke' });
    }
});

app.get('/api/hanja_word/list', (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 200, 500);
    const offset = (page - 1) * limit;
    const totalRow = db.prepare('SELECT COUNT(*) as c FROM hanja_word').get();
    const rows = db.prepare(
        'SELECT id, server_doc_id, word, reading, meaning, related_hanja, change_number FROM hanja_word ORDER BY id LIMIT ? OFFSET ?',
    ).all(limit, offset);
    res.json({ data: rows, total: totalRow.c, page, limit });
});

/** 단어 문자열에 지정 한 자(첫 그래프)가 포함된 hanja_word 행 — 상세 화면 연동용 */
app.get('/api/hanja_word/containing', (req, res) => {
    const raw = String(req.query.glyph || req.query.char || '').trim();
    if (!raw) {
        return res.status(400).json({ error: 'glyph 또는 char 쿼리가 필요합니다.' });
    }
    const needle = [...raw][0] || raw;
    const limit = Math.min(parseInt(req.query.limit) || 200, 500);
    try {
        const rows = db
            .prepare(
                `SELECT id, server_doc_id, word, reading, meaning, related_hanja, change_number
                 FROM hanja_word
                 WHERE instr(word, ?) > 0
                 ORDER BY length(word) ASC, word ASC
                 LIMIT ?`,
            )
            .all(needle, limit);
        res.json({ data: rows, glyph: needle });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || '단어 조회 실패' });
    }
});

app.put('/api/hanja_word/upsert', (req, res) => {
    const body = req.body || {};
    const server_doc_id = body.server_doc_id;
    if (!server_doc_id || !body.word || !body.change_number) {
        return res.status(400).json({ error: 'server_doc_id, word, change_number are required' });
    }
    const reading = body.reading ?? '';
    const meaning = body.meaning ?? '';
    const change_number = Number(body.change_number);
    let related_hanja = [];
    if (Array.isArray(body.related_hanja)) {
        related_hanja = body.related_hanja;
    }
    try {
        db.prepare(`
            INSERT INTO hanja_word (word, reading, meaning, related_hanja, server_doc_id, change_number)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT(server_doc_id) DO UPDATE SET
                word = excluded.word,
                reading = excluded.reading,
                meaning = excluded.meaning,
                related_hanja = excluded.related_hanja,
                change_number = excluded.change_number
        `).run(body.word, reading, meaning, JSON.stringify(related_hanja), server_doc_id, change_number);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to upsert word' });
    }
});

app.post('/api/hanja_word', (req, res) => {
    const body = req.body || {};
    if (!body.word || !body.change_number) {
        return res.status(400).json({ error: 'word, change_number are required' });
    }
    const reading = body.reading ?? '';
    const meaning = body.meaning ?? '';
    const change_number = Number(body.change_number);
    const related_hanja = Array.isArray(body.related_hanja) ? body.related_hanja : [];
    try {
        const result = db.prepare(`
            INSERT INTO hanja_word (word, reading, meaning, related_hanja, change_number)
            VALUES (?, ?, ?, ?, ?)
        `).run(body.word, reading, meaning, JSON.stringify(related_hanja), change_number);
        res.json({ success: true, id: result.lastInsertRowid });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to create word' });
    }
});

app.put('/api/hanja_word/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const body = req.body || {};
    if (!body.word || !body.change_number) {
        return res.status(400).json({ error: 'word, change_number are required' });
    }
    const reading = body.reading ?? '';
    const meaning = body.meaning ?? '';
    const change_number = Number(body.change_number);
    const related_hanja = Array.isArray(body.related_hanja) ? body.related_hanja : [];
    try {
        db.prepare(`
            UPDATE hanja_word SET word=?, reading=?, meaning=?, related_hanja=?, change_number=?
            WHERE id=?
        `).run(body.word, reading, meaning, JSON.stringify(related_hanja), change_number, id);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to update word' });
    }
});

app.delete('/api/hanja_word/:id', (req, res) => {
    const id = parseInt(req.params.id);
    try {
        db.prepare('DELETE FROM hanja_word WHERE id=?').run(id);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to delete word' });
    }
});

// GET /api/word/:reading : Find related words
app.get('/api/word', (req, res) => {
    const { query } = req.query; // Search token
    if (!query) {
        return res.json({ data: [] });
    }
    const rows = db.prepare(`
        SELECT * FROM hanja_word 
        WHERE word LIKE ? OR meaning LIKE ? OR reading LIKE ?
        LIMIT 50
    `).all(`%${query}%`, `%${query}%`, `%${query}%`);
    res.json({ data: rows });
});

app.listen(port, () => {
    console.log(`[chusa-admin] Local SQLite API http://localhost:${port}`);
    console.log(`[chusa-admin] DB ${DB_PATH}`);
});
