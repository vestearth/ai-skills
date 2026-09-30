#!/usr/bin/env python3
"""Focused tests for the opt-in Codex token telemetry summary."""
import contextlib
import importlib.util
import io
import json
import os
import tempfile
import unittest


SCRIPT = os.path.join(os.path.dirname(__file__), "skill-usage-report.py")
spec = importlib.util.spec_from_file_location("skill_usage_report", SCRIPT)
report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(report)


class CodexUsageTest(unittest.TestCase):
    def test_first_call_and_final_cumulative_usage(self):
        events = [
            {"type": "session_meta", "timestamp": "2026-09-29T22:00:00Z"},
            {"type": "event_msg", "payload": {"type": "token_count", "info": {
                "last_token_usage": {"input_tokens": 100, "cached_input_tokens": 20},
                "total_token_usage": {"input_tokens": 100, "cached_input_tokens": 20,
                                      "output_tokens": 5}}}},
            {"type": "event_msg", "payload": {"type": "token_count", "info": {
                "last_token_usage": {"input_tokens": 150, "cached_input_tokens": 90},
                "total_token_usage": {"input_tokens": 250, "cached_input_tokens": 110,
                                      "output_tokens": 12}}}},
        ]
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8") as trace:
            trace.write("not json\n")
            trace.write("null\n")
            for event in events:
                trace.write(json.dumps(event) + "\n")
            trace.flush()
            start, first, final = report.codex_usage_from_trace(trace.name)
        self.assertEqual(start, "2026-09-29T22:00:00Z")
        self.assertEqual(first["input_tokens"], 100)
        self.assertEqual(first["cached_input_tokens"], 20)
        self.assertEqual(final["input_tokens"], 250)
        self.assertEqual(final["cached_input_tokens"], 110)
        self.assertEqual(final["output_tokens"], 12)

    def test_invalid_or_missing_usage_is_not_treated_as_zero(self):
        events = [
            {"type": "session_meta", "timestamp": "2026-09-29T22:00:00Z"},
            {"type": "event_msg", "payload": {"type": "token_count", "info": {
                "last_token_usage": {"input_tokens": 100},
                "total_token_usage": {"input_tokens": 100, "output_tokens": 5}}}},
            {"type": "event_msg", "payload": {"type": "token_count", "info": {
                "last_token_usage": {"input_tokens": 10, "cached_input_tokens": 20},
                "total_token_usage": {"input_tokens": 10, "cached_input_tokens": 20,
                                      "output_tokens": 5}}}},
        ]
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8") as trace:
            for event in events:
                trace.write(json.dumps(event) + "\n")
            trace.flush()
            _, first, final = report.codex_usage_from_trace(trace.name)
        self.assertIsNone(first)
        self.assertIsNone(final)

    def test_summary_reports_telemetry_coverage(self):
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8") as trace:
            trace.write(json.dumps({"type": "session_meta", "timestamp": "2026-09-29T22:00:00Z"}) + "\n")
            trace.flush()
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                report.report_codex_usage([trace.name], "2026-09-29", "2026-09-29")
        self.assertIn("token telemetry: 0 of 1 session traces", output.getvalue())

    def test_summary_uses_recorded_totals_without_prompt_text(self):
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8") as trace:
            trace.write(json.dumps({"type": "session_meta", "timestamp": "2026-09-29T22:00:00Z"}) + "\n")
            trace.write(json.dumps({"type": "event_msg", "payload": {"type": "token_count", "info": {
                "last_token_usage": {"input_tokens": 100, "cached_input_tokens": 20},
                "total_token_usage": {"input_tokens": 100, "cached_input_tokens": 20,
                                      "output_tokens": 5}}}}) + "\n")
            trace.flush()
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                report.report_codex_usage([trace.name], "2026-09-29", "2026-09-29")
        self.assertIn("token telemetry: 1 of 1 session traces", output.getvalue())
        self.assertIn("first recorded call median: input 100, uncached 80, cached 20", output.getvalue())
        self.assertIn("aggregate cached-input share: 20.0%", output.getvalue())


if __name__ == "__main__":
    unittest.main()
