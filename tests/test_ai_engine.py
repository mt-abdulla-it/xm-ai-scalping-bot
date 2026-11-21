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
from ai_engine.osint_cti import extract_iocs, query_dns_intelligence, map_mitre_technique, check_tor_exit_node, check_cisa_kev
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

        # Test Tor Exit Node Defensive Intelligence
        tor_res = check_tor_exit_node("127.0.0.1")
        self.assertIn("is_tor_exit_node", tor_res)
        self.assertFalse(tor_res["is_tor_exit_node"]) # Localhost is never Tor

        # Test CISA KEV Government Cyber Intelligence
        kev_res = check_cisa_kev("CVE-2023-34362") # MOVEit Transfer
        self.assertIn("cve", kev_res)

    def test_model_router_offline_fallback(self):
        router = ModelRouter()
        classified = router.classify_task("Derive the Kelly Criterion formula for scalping")
        self.assertEqual(classified, "deepseek-r1")
        
        # Test offline rule fallback
        fallback = router._local_rule_fallback("Show me trading bot status and balance")
        self.assertIn("Trading Bot Status", fallback)

    def test_telegram_gateway_unconfigured(self):
        from ai_engine.telegram_notifier import send_telegram_alert, get_credentials
        res = send_telegram_alert("Test message")
        self.assertIn("success", res)

    def test_strategy_backtest_engine(self):
        from ai_engine.backtest_engine import run_strategy_backtest
        csv_path = os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files/XMBot_ML_Data.csv")
        res = run_strategy_backtest(csv_path, er_threshold=0.35, sl_atr_mult=2.0)
        self.assertIn("success", res)
        if res.get("success"):
            self.assertIn("equity_curve", res)
            self.assertIn("win_rate", res)

    def test_pdf_tearsheet_generation(self):
        from ai_engine.pdf_report import generate_pdf_tearsheet
        csv_path = os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files/XMBot_ML_Data.csv")
        pdf_buf = generate_pdf_tearsheet(csv_path, balance=150.0, today_pnl=12.50)
        pdf_bytes = pdf_buf.getvalue()
        self.assertGreater(len(pdf_bytes), 50)
        self.assertTrue(pdf_bytes.startswith(b'%PDF') or b'AegisQuant' in pdf_bytes)

    def test_system_sentinel_health(self):
        from ai_engine.system_sentinel import get_full_system_health
        from ai_engine.database import DB_PATH
        health = get_full_system_health(DB_PATH)
        self.assertIn("status", health)
        self.assertIn("processes", health)
        self.assertIn("benchmarks_ms", health)

    def test_market_correlation_matrix(self):
        from ai_engine.market_correlation import calculate_correlation_matrix
        corr_res = calculate_correlation_matrix()
        self.assertIn("assets", corr_res)
        self.assertIn("matrix", corr_res)
        self.assertIn("risk_clusters", corr_res)
        self.assertEqual(corr_res["matrix"]["US100"]["US100"], 1.0)
        self.assertAlmostEqual(corr_res["matrix"]["EURUSD"]["GBPUSD"], 0.86)

    def test_ai_committee_debate(self):
        from ai_engine.ai_debate import run_ai_committee_debate
        debate = run_ai_committee_debate({"symbol": "US100", "rsi": 62.0, "macd": 0.0010, "er": 0.48})
        self.assertIn("symbol", debate)
        self.assertIn("consensus", debate)
        self.assertIn("members", debate)
        self.assertEqual(len(debate["members"]), 3)
        self.assertIn(debate["consensus"]["action"], ["BUY", "SELL", "WAIT", "WAIT / CONFLICT"])

    def test_hwm_and_trading_journal(self):
        from ai_engine.trading_journal import calculate_hwm_metrics, generate_journal_entries
        csv_path = os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files/XMBot_ML_Data.csv")
        hwm = calculate_hwm_metrics(csv_path, current_balance=100.0)
        self.assertIn("high_water_mark", hwm)
        self.assertIn("drawdown_from_hwm", hwm)
        self.assertIn("recovery_factor", hwm)
        
        entries = generate_journal_entries(csv_path, limit=5)
        self.assertIsInstance(entries, list)
        if len(entries) > 0:
            self.assertIn("grade", entries[0])
            self.assertIn("critique", entries[0])

    def test_monte_carlo_simulation(self):
        from ai_engine.monte_carlo import run_monte_carlo_simulation
        csv_path = os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files/XMBot_ML_Data.csv")
        mc = run_monte_carlo_simulation(csv_path, initial_capital=100.0, iterations=200, trades_per_sim=50)
        self.assertTrue(mc["success"])
        self.assertIn("ruin_probability_pct", mc)
        self.assertIn("median_final_equity", mc)
        self.assertIn("value_at_risk_99", mc)
        self.assertIn("expected_shortfall_cvar_95", mc)
        self.assertEqual(len(mc["sample_trajectories"]), 8)

    def test_ea_config_manager(self):
        from ai_engine.config_manager import get_ea_config, update_ea_config
        cfg = get_ea_config()
        self.assertIn("kaufman_er_threshold", cfg)
        self.assertIn("hard_loss_shield_usd", cfg)
        
        updated = update_ea_config({"kaufman_er_threshold": 0.38})
        self.assertTrue(updated["success"])
        self.assertEqual(updated["config"]["kaufman_er_threshold"], 0.38)

    def test_news_sentinel_radar(self):
        from ai_engine.news_sentinel import get_macro_radar_status
        radar = get_macro_radar_status()
        self.assertIn("is_blackout_active", radar)
        self.assertIn("action_recommendation", radar)
        self.assertIn("next_event", radar)
        self.assertGreater(len(radar["upcoming_events"]), 0)

if __name__ == "__main__":
    unittest.main()
