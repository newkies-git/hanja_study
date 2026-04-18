import express from 'express';
import cors from 'cors';
import path from 'path';
import Database from 'better-sqlite3';

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

const DATA_DIR = path.resolve(process.cwd(), '../data');
const DB_PATH = path.join(DATA_DIR, 'chusa.db');
const db = new Database(DB_PATH);

// Helper to safely parse JSON strings from SQLite
const parseJSON = (str) => {
    try { return str ? JSON.parse(str) : null; }
    catch(e) { return null; }
};

// GET /api/hanja : List all hanjas (with pagination + optional filters)
app.get('/api/hanja', (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
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
            "trim(ifnull(ifnull(json_extract(extend_data, '$.grade'), json_extract(extend_data, '$.구분')), '')) = ?",
        );
        params.push(gubun);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const countRaw = db.prepare(`SELECT COUNT(*) as count FROM hanja ${whereClause}`).get(...params);

    const rows = db.prepare(`
        SELECT id, char_str as hanja, reading, meaning, stroke_count, difficulty, sync_status, change_number, extend_data
        FROM hanja
        ${whereClause}
        ORDER BY id ASC
        LIMIT ? OFFSET ?
    `).all(...params, limit, offset);

    res.json({
        data: rows.map(r => ({ ...r, char: r.hanja })),
        total: countRaw.count,
        page,
        limit
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

    const extendRaw = row.extend_data;
    const rowOut = { ...row };
    delete rowOut.extend_data;

    res.json({
        ...rowOut,
        readings: parseJSON(row.readings) || [],
        synonyms: parseJSON(row.synonyms) || [],
        antonyms: parseJSON(row.antonyms) || [],
        variants: parseJSON(row.variants) || [],
        extend: parseJSON(extendRaw) || {},
        font_outline: stroke ? parseJSON(stroke.font_outline) : [],
        stroke_outlines: stroke ? parseJSON(stroke.stroke_outlines) : []
    });
});

// GET /api/session : Get active session
app.get('/api/session', (req, res) => {
    const row = db.prepare("SELECT * FROM sync_sessions WHERE status = 'ACTIVE' ORDER BY id DESC LIMIT 1").get();
    res.json({ data: row || null });
});

// POST /api/session : Start a new active session
app.post('/api/session', (req, res) => {
    const { description } = req.body || {};
    // Optional: mark all as synced before starting new one
    db.prepare("UPDATE sync_sessions SET status = 'SYNCED', synced_at = CURRENT_TIMESTAMP WHERE status = 'ACTIVE'").run();
    const result = db.prepare("INSERT INTO sync_sessions (status, description) VALUES ('ACTIVE', ?)").run(description || null);
    const session = db.prepare("SELECT * FROM sync_sessions WHERE id = ?").get(result.lastInsertRowid);
    res.json({ data: session });
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
            grade_level = coalesce(?, grade_level),
            shape_explanation = coalesce(?, shape_explanation),
            origin_note = coalesce(?, origin_note),
            difficulty = coalesce(?, difficulty),
            readings = ?,
            synonyms = ?,
            antonyms = ?,
            variants = ?,
            extend_data = ?,
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
            body.grade_level,
            body.shape_explanation,
            body.origin_note,
            body.difficulty,
            readingsStr,
            synonymsStr,
            antonymsStr,
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
    const variantsStr = JSON.stringify(body.variants || []);
    const extendStr = JSON.stringify(body.extend ?? {});

    const stmt = db.prepare(`
        INSERT INTO hanja (
            id, char_str, reading, meaning, radical, radical_meaning,
            stroke_count, school_level, grade_level,
            shape_explanation, origin_note, difficulty, readings,
            synonyms, antonyms, variants, extend_data, sync_status, change_number
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ADDED', ?
        )
    `);

    try {
        stmt.run(
            body.id, body.char_str || body.id, body.reading, body.meaning, body.radical, body.radical_meaning,
            body.stroke_count, body.school_level, body.grade_level,
            body.shape_explanation, body.origin_note, body.difficulty, readingsStr,
            synonymsStr, antonymsStr, variantsStr, extendStr, body.change_number
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
    const variantsStr = JSON.stringify(body.variants || []);
    const extendStr = JSON.stringify(body.extend ?? {});

    try {
        db.prepare(`
            INSERT INTO hanja (
                id, char_str, reading, meaning, radical, radical_meaning,
                stroke_count, school_level, grade_level,
                shape_explanation, origin_note, difficulty, readings,
                synonyms, antonyms, variants, extend_data, sync_status, change_number
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
                grade_level = coalesce(excluded.grade_level, grade_level),
                shape_explanation = coalesce(excluded.shape_explanation, shape_explanation),
                origin_note = coalesce(excluded.origin_note, origin_note),
                difficulty = coalesce(excluded.difficulty, difficulty),
                readings = excluded.readings,
                synonyms = excluded.synonyms,
                antonyms = excluded.antonyms,
                variants = excluded.variants,
                extend_data = excluded.extend_data,
                sync_status = CASE WHEN sync_status = 'ADDED' THEN 'ADDED' ELSE 'MODIFIED' END,
                change_number = excluded.change_number
        `).run(
            body.id, body.char_str || body.id, body.reading, body.meaning, body.radical, body.radical_meaning,
            body.stroke_count, body.school_level, body.grade_level,
            body.shape_explanation, body.origin_note, body.difficulty, readingsStr,
            synonymsStr, antonymsStr, variantsStr, extendStr, body.change_number
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
        'SELECT id, char_str, radical, font_outline, stroke_outlines FROM hanja_stroke ORDER BY id LIMIT ? OFFSET ?',
    ).all(limit, offset);
    res.json({ data: rows, total: totalRow.c, page, limit });
});

app.put('/api/hanja_stroke/:id', (req, res) => {
    const { id } = req.params;
    const body = req.body || {};
    const fo = JSON.stringify(body.font_outline ?? []);
    const so = JSON.stringify(body.stroke_outlines ?? []);
    const char_str = body.char_str || id;
    const radical = body.radical === undefined || body.radical === null ? null : Number(body.radical);
    try {
        db.prepare(`
            INSERT INTO hanja_stroke (id, char_str, radical, font_outline, stroke_outlines)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                char_str = excluded.char_str,
                radical = excluded.radical,
                font_outline = excluded.font_outline,
                stroke_outlines = excluded.stroke_outlines
        `).run(id, char_str, radical, fo, so);
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
        'SELECT id, server_doc_id, word, reading, meaning, details FROM hanja_word ORDER BY id LIMIT ? OFFSET ?',
    ).all(limit, offset);
    res.json({ data: rows, total: totalRow.c, page, limit });
});

app.put('/api/hanja_word/upsert', (req, res) => {
    const body = req.body || {};
    const server_doc_id = body.server_doc_id;
    if (!server_doc_id || !body.word) {
        return res.status(400).json({ error: 'server_doc_id and word are required' });
    }
    const reading = body.reading ?? '';
    const meaning = body.meaning ?? '';
    const details = typeof body.details === 'string' ? body.details : JSON.stringify(body.details ?? null);
    try {
        db.prepare(`
            INSERT INTO hanja_word (word, reading, meaning, details, server_doc_id)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(server_doc_id) DO UPDATE SET
                word = excluded.word,
                reading = excluded.reading,
                meaning = excluded.meaning,
                details = excluded.details
        `).run(body.word, reading, meaning, details, server_doc_id);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message || 'Failed to upsert word' });
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
    console.log(`Local SQLite API running at http://localhost:${port}`);
});
