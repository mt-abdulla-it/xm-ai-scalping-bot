"""
SQLite Persistent Storage Layer for Conversations, Long-Term Memory,
RAG Document Chunks, OSINT Intel, and Security Audit Logs.
"""
import sqlite3
import json
from datetime import datetime
from typing import List, Dict, Any, Optional
from ai_engine.config import DB_PATH

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_connection()
    cur = conn.cursor()
    
    # 1. Conversations
    cur.execute("""
    CREATE TABLE IF NOT EXISTS conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
    )""")
    
    # 2. Messages
    cur.execute("""
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        model TEXT,
        tokens_in INTEGER DEFAULT 0,
        tokens_out INTEGER DEFAULT 0,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
    )""")
    
    # 3. Long-Term AI Memory Records
    cur.execute("""
    CREATE TABLE IF NOT EXISTS memory_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT DEFAULT 'default_user',
        category TEXT NOT NULL, -- 'preference', 'fact', 'trading_rule', 'custom_instruction'
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        confidence REAL DEFAULT 1.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
    )""")
    
    # 4. RAG Ingested Documents
    cur.execute("""
    CREATE TABLE IF NOT EXISTS documents (
        id TEXT PRIMARY KEY,
        filename TEXT NOT NULL,
        file_type TEXT NOT NULL,
        char_count INTEGER NOT NULL,
        chunk_count INTEGER NOT NULL,
        created_at TEXT NOT NULL
    )""")
    
    # 5. RAG Document Chunks
    cur.execute("""
    CREATE TABLE IF NOT EXISTS document_chunks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id TEXT NOT NULL,
        chunk_index INTEGER NOT NULL,
        content TEXT NOT NULL,
        metadata_json TEXT,
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
    )""")
    
    # 6. OSINT & CTI Cache Records
    cur.execute("""
    CREATE TABLE IF NOT EXISTS osint_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        target TEXT NOT NULL,
        query_type TEXT NOT NULL, -- 'dns', 'whois', 'ip_rep', 'cve', 'ioc'
        result_json TEXT NOT NULL,
        timestamp TEXT NOT NULL
    )""")
    
    # 7. Security Audit Log
    cur.execute("""
    CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_type TEXT NOT NULL,
        actor TEXT NOT NULL,
        details_json TEXT NOT NULL,
        timestamp TEXT NOT NULL
    )""")
    
    conn.commit()
    conn.close()

# Initialize tables immediately on module load
init_db()

# ==============================================================================
# 💬 Conversation & Message Helpers
# ==============================================================================
def save_message(conversation_id: str, role: str, content: str, model: str = None, tokens_in: int = 0, tokens_out: int = 0):
    conn = get_connection()
    cur = conn.cursor()
    now = datetime.now().isoformat()
    
    # Ensure conversation exists
    cur.execute("SELECT id FROM conversations WHERE id = ?", (conversation_id,))
    if not cur.fetchone():
        title = content[:40] + "..." if len(content) > 40 else content
        cur.execute("INSERT INTO conversations (id, title, created_at, updated_at) VALUES (?, ?, ?, ?)",
                    (conversation_id, title, now, now))
    else:
        cur.execute("UPDATE conversations SET updated_at = ? WHERE id = ?", (now, conversation_id))
        
    cur.execute("""
    INSERT INTO messages (conversation_id, role, content, model, tokens_in, tokens_out, timestamp)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (conversation_id, role, content, model, tokens_in, tokens_out, now))
    
    conn.commit()
    conn.close()

def get_conversation_history(conversation_id: str, limit: int = 20) -> List[Dict[str, Any]]:
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
    SELECT role, content, model, timestamp FROM messages 
    WHERE conversation_id = ? 
    ORDER BY id ASC LIMIT ?
    """, (conversation_id, limit))
    rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

def list_conversations(limit: int = 30) -> List[Dict[str, Any]]:
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, title, updated_at FROM conversations ORDER BY updated_at DESC LIMIT ?", (limit,))
    rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

# ==============================================================================
# 🛡️ Audit Logger
# ==============================================================================
def log_audit(event_type: str, actor: str, details: Dict[str, Any]):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
    INSERT INTO audit_logs (event_type, actor, details_json, timestamp)
    VALUES (?, ?, ?, ?)
    """, (event_type, actor, json.dumps(details), datetime.now().isoformat()))
    conn.commit()
    conn.close()

def get_recent_audit_logs(limit: int = 50) -> List[Dict[str, Any]]:
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM audit_logs ORDER BY id DESC LIMIT ?", (limit,))
    rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

