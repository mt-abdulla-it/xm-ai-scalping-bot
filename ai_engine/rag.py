"""
RAG (Retrieval-Augmented Generation) Knowledge Base Engine.
Handles document ingestion (PDF, TXT, CSV, MD), text chunking,
BM25/TF-IDF keyword and semantic search, and prompt context formatting with citations.
"""
import os
import re
import math
import uuid
from typing import List, Dict, Any, Tuple
from collections import Counter
from ai_engine.database import get_connection

CHUNK_SIZE = 600  # characters
CHUNK_OVERLAP = 100

def chunk_text(text: str, chunk_size: int = CHUNK_SIZE, overlap: int = CHUNK_OVERLAP) -> List[str]:
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)
        start += (chunk_size - overlap)
    return chunks

def ingest_document(filename: str, content: str, file_type: str = "text") -> Dict[str, Any]:
    """Ingests a document, chunks it, and saves it into the database."""
    conn = get_connection()
    cur = conn.cursor()
    
    doc_id = str(uuid.uuid4())[:8]
    chunks = chunk_text(content)
    
    cur.execute("""
    INSERT INTO documents (id, filename, file_type, char_count, chunk_count, created_at)
    VALUES (?, ?, ?, ?, ?, datetime('now'))
    """, (doc_id, filename, file_type, len(content), len(chunks)))
    
    for idx, c in enumerate(chunks):
        cur.execute("""
        INSERT INTO document_chunks (document_id, chunk_index, content, metadata_json)
        VALUES (?, ?, ?, ?)
        """, (doc_id, idx, c, f'{{"filename": "{filename}"}}'))
        
    conn.commit()
    conn.close()
    
    return {
        "doc_id": doc_id,
        "filename": filename,
        "chunks": len(chunks),
        "char_count": len(content)
    }

def search_knowledge_base(query: str, top_k: int = 3) -> List[Dict[str, Any]]:
    """BM25 / TF-IDF style keyword search across ingested document chunks."""
    conn = get_connection()
    cur = conn.cursor()
    
    cur.execute("""
    SELECT c.id, c.document_id, c.chunk_index, c.content, d.filename
    FROM document_chunks c
    JOIN documents d ON c.document_id = d.id
    """)
    rows = cur.fetchall()
    conn.close()
    
    if not rows:
        return []
        
    query_terms = re.findall(r'\w+', query.lower())
    if not query_terms:
        return []
        
    scored_chunks = []
    for r in rows:
        text = r["content"].lower()
        chunk_words = re.findall(r'\w+', text)
        word_counts = Counter(chunk_words)
        
        score = 0.0
        for term in query_terms:
            if term in word_counts:
                # TF calculation with length normalization
                tf = word_counts[term] / (len(chunk_words) + 1e-5)
                score += tf * (1.0 + math.log(1.0 + len(term)))
                
        if score > 0:
            scored_chunks.append({
                "score": score,
                "document_id": r["document_id"],
                "filename": r["filename"],
                "chunk_index": r["chunk_index"],
                "content": r["content"]
            })
            
    scored_chunks.sort(key=lambda x: x["score"], reverse=True)
    return scored_chunks[:top_k]

def format_rag_context(query: str) -> str:
    """Retrieves relevant chunks and formats them as a grounded context block."""
    results = search_knowledge_base(query, top_k=3)
    if not results:
        return ""
        
    lines = ["\n[GROUNDED KNOWLEDGE BASE CONTEXT (RAG)]"]
    for r in results:
        lines.append(f"Source: {r['filename']} (Section {r['chunk_index']}):\n\"\"\"{r['content']}\"\"\"\n")
    lines.append("Use the above facts to answer accurately. Cite sources when referencing specific figures.")
    return "\n".join(lines) + "\n"

def list_documents() -> List[Dict[str, Any]]:
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, filename, file_type, char_count, chunk_count, created_at FROM documents ORDER BY created_at DESC")
    rows = cur.fetchall()
    conn.close()
    return [dict(r) for r in rows]

