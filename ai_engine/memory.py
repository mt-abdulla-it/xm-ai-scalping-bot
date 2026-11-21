"""
Long-Term AI Memory Engine.
Extracts user preferences, trading rules, and facts from conversations,
stores them in SQLite, and formats them as system memory context.
"""
import re
from typing import List, Dict, Any, Optional
from datetime import datetime
from ai_engine.database import get_connection

def add_memory(key: str, value: str, category: str = "preference", user_id: str = "default_user") -> int:
    conn = get_connection()
    cur = conn.cursor()
    now = datetime.now().isoformat()
    
    # Check if key already exists for this category
    cur.execute("SELECT id FROM memory_records WHERE user_id = ? AND category = ? AND key = ?",
                (user_id, category, key))
    existing = cur.fetchone()
    
    if existing:
        cur.execute("""
        UPDATE memory_records SET value = ?, updated_at = ? WHERE id = ?
        """, (value, now, existing[0]))
        mem_id = existing[0]
    else:
        cur.execute("""
        INSERT INTO memory_records (user_id, category, key, value, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (user_id, category, key, value, now, now))
        mem_id = cur.lastrowid
        
    conn.commit()
    conn.close()
    return mem_id

def get_memories(user_id: str = "default_user", category: Optional[str] = None) -> List[Dict[str, Any]]:
    conn = get_connection()
    cur = conn.cursor()
    if category:
        cur.execute("SELECT * FROM memory_records WHERE user_id = ? AND category = ? ORDER BY id DESC",
                    (user_id, category))
    else:
        cur.execute("SELECT * FROM memory_records WHERE user_id = ? ORDER BY id DESC", (user_id,))
    rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

def delete_memory(memory_id: int, user_id: str = "default_user") -> bool:
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM memory_records WHERE id = ? AND user_id = ?", (memory_id, user_id))
    affected = cur.rowcount > 0
    conn.commit()
    conn.close()
    return affected

def format_memories_for_prompt(user_id: str = "default_user") -> str:
    memories = get_memories(user_id)
    if not memories:
        return ""
    
    lines = ["\n[LONG-TERM MEMORY CONTEXT]"]
    for m in memories:
        lines.append(f"- ({m['category'].upper()}) {m['key']}: {m['value']}")
    return "\n".join(lines) + "\n"

def auto_extract_and_save_preferences(user_text: str, user_id: str = "default_user"):
    """Heuristic extraction of user preferences or rules from text."""
    # Check for trading preferences
    if re.search(r'\b(my risk|risk per trade|lot size)\b', user_text, re.I):
        m = re.search(r'(\$?\d+(\.\d+)?%?|\b0\.\d+\b)', user_text)
        if m:
            add_memory("risk_preference", m.group(1), category="trading_rule", user_id=user_id)
            
    # Check for preferred language
    if re.search(r'\b(tamil|tanglish|tamil-english|english)\b', user_text, re.I):
        lang = "Tamil / Tanglish" if "tamil" in user_text.lower() else "English"
        add_memory("preferred_language", lang, category="preference", user_id=user_id)
