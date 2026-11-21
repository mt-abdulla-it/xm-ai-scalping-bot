"""
Unit & Integration Tests for Next-Gen AI Engine Subsystems:
Database, Memory, RAG Knowledge Base, OSINT/CTI, and Multi-Model Routing.
"""
import unittest
import os
import sys

# Ensure root workspace is on python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from ai_engine.database import save_message, get_conversation_history, log_audit, get_recent_audit_logs
from ai_engine.memory import add_memory, get_memories, delete_memory, format_memories_for_prompt
from ai_engine.rag import chunk_text, ingest_document, search_knowledge_base, format_rag_context
from ai_engine.osint_cti import extract_iocs, query_dns_intelligence, map_mitre_technique
from ai_engine.model_router import ModelRouter

class TestAIEngine(unittest.TestCase):

    def test_database_and_history(self):
        import uuid
        conv_id = f"test_conv_{uuid.uuid4().hex[:6]}"
        save_message(conv_id, "user", "What is the scalping win rate?", "test_model")
        save_message(conv_id, "assistant", "Win rate is 74.95%.", "gemini-2.0-flash")
        
        history = get_conversation_history(conv_id)
        self.assertEqual(len(history), 2)
        self.assertEqual(history[0]["role"], "user")
        self.assertEqual(history[1]["content"], "Win rate is 74.95%.")

    def test_memory_engine(self):
        mem_id = add_memory("test_risk", "1.5%", category="trading_rule")
        self.assertIsInstance(mem_id, int)
        
        memories = get_memories(category="trading_rule")
        self.assertTrue(any(m["key"] == "test_risk" for m in memories))
        
        context_str = format_memories_for_prompt()
        self.assertIn("1.5%", context_str)
        
        deleted = delete_memory(mem_id)
        self.assertTrue(deleted)

    def test_rag_knowledge_engine(self):
        doc_content = "XM AI Scalping Bot trades M5 timeframe with 9 quant features: RSI, Spread, MACD, ATR, Type, Hour, RSI_Dev, Spread_ATR_Ratio, DayOfWeek."
        doc_info = ingest_document("test_manual.txt", doc_content)
        self.assertIn("doc_id", doc_info)
        
        results = search_knowledge_base("M5 timeframe quant features")
        self.assertGreater(len(results), 0)
        self.assertIn("M5 timeframe", results[0]["content"])
        
        rag_context = format_rag_context("What are the 9 quant features?")
        self.assertIn("GROUNDED KNOWLEDGE BASE CONTEXT", rag_context)

    def test_osint_cti_capabilities(self):
        sample_log = "Attacker from 185.220.101.5 attempted exploit CVE-2024-3400 with hash a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2 on target.example.com"
        iocs = extract_iocs(sample_log)
        
        self.assertIn("185.220.101.5", iocs["ipv4"])
        self.assertIn("CVE-2024-3400", iocs["cve"])
        self.assertEqual(len(iocs["sha256"]), 1)
        
        dns_res = query_dns_intelligence("localhost")
        self.assertIn(dns_res["status"], ["resolved", "not_found", "resolution_failed"])
        
        mitre_res = map_mitre_technique("T1059")
        self.assertTrue(mitre_res["found"])
        self.assertEqual(mitre_res["name"], "Command and Scripting Interpreter")

    def test_model_router_offline_fallback(self):
        router = ModelRouter()
        classified = router.classify_task("Derive the Kelly Criterion formula for scalping")
        self.assertEqual(classified, "deepseek-r1")
        
        # Test offline rule fallback
        fallback = router._local_rule_fallback("Show me trading bot status and balance")
        self.assertIn("Trading Bot Status", fallback)

if __name__ == "__main__":
    unittest.main()
