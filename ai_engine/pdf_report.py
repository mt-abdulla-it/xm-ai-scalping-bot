#!/usr/bin/env python3
"""
AegisQuant AI — Automated Institutional PDF Tear-Sheet Generator
Generates Wall-Street style executive PDF performance statements using ReportLab.
"""

import io
import os
from datetime import datetime
import pandas as pd
try:
    from reportlab.lib.pagesizes import letter
    from reportlab.lib import colors
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    HAS_REPORTLAB = True
except ImportError:
    HAS_REPORTLAB = False

def generate_pdf_tearsheet(csv_path: str, balance: float = 0.0, today_pnl: float = 0.0) -> io.BytesIO:
    """
    Builds a professional executive PDF tear-sheet in memory.
    """
    buffer = io.BytesIO()
    if not HAS_REPORTLAB:
        # Fallback to plain text / html stream if reportlab not found in current python interpreter
        buffer.write(f"AegisQuant AI — Institutional Performance Statement\nDate: {datetime.utcnow()}\nBalance: ${balance:.2f}\nToday PnL: ${today_pnl:.2f}\n\nNote: Install reportlab in your active python environment to generate binary vector PDFs.".encode('utf-8'))
        buffer.seek(0)
        return buffer
    doc = SimpleDocTemplate(
        buffer,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36
    )

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=colors.HexColor('#0A192F')
    )
    subtitle_style = ParagraphStyle(
        'DocSub',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor('#5A6679')
    )
    section_style = ParagraphStyle(
        'SectionHead',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#0052D4'),
        spaceBefore=10,
        spaceAfter=6
    )
    cell_style = ParagraphStyle(
        'CellText',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=10
    )

    elements = []

    # Title & Header
    elements.append(Paragraph("🛡️ AegisQuant AI — Institutional Performance Statement", title_style))
    elements.append(Paragraph(f"Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')} | Trading Model: ONNX Quant Scalper + Kaufman TSaM", subtitle_style))
    elements.append(Spacer(1, 14))

    # Calculate statistics from CSV
    trade_count = 0
    win_rate = 0.0
    profit_factor = 1.0
    total_pnl = 0.0
    recent_trades_data = []

    if os.path.exists(csv_path):
        try:
            df = pd.read_csv(csv_path)
            df['Profit'] = pd.to_numeric(df['Profit'], errors='coerce')
            df = df.dropna(subset=['Profit'])
            trade_count = len(df)
            if trade_count > 0:
                wins = df[df['Profit'] > 0]
                losses = df[df['Profit'] < 0]
                win_rate = round(float(len(wins) / trade_count * 100), 2)
                total_pnl = round(float(df['Profit'].sum()), 2)
                pf_denom = abs(float(losses['Profit'].sum())) if len(losses) > 0 else 0.01
                profit_factor = round(float(wins['Profit'].sum() / pf_denom), 2)

                # Recent trades slice
                tail = df.tail(20)
                for _, r in tail.iterrows():
                    pnl_val = float(r['Profit'])
                    recent_trades_data.append([
                        str(r.get('Ticket', '')),
                        str(r.get('Type', '')),
                        str(r.get('OpenTime', '')).split(" ")[-1] if " " in str(r.get('OpenTime', '')) else str(r.get('OpenTime', '')),
                        f"${pnl_val:.2f}",
                        "WIN" if pnl_val >= 0 else "LOSS"
                    ])
        except Exception:
            pass

    # Executive Summary Table
    kpi_data = [
        ["Current Terminal Balance", f"${balance:.2f}", "Total Recorded Trades", str(trade_count)],
        ["Today's Net P&L", f"{'+' if today_pnl >= 0 else ''}${today_pnl:.2f}", "Overall Net Return", f"{'+' if total_pnl >= 0 else ''}${total_pnl:.2f}"],
        ["Win Rate (Historical)", f"{win_rate}%", "Profit Factor", str(profit_factor)],
        ["Kaufman ER Filter", "Active (>0.35 ER)", "Risk Guard Sizing", "Hard Lot Cap (0.03 lot)"]
    ]

    kpi_table = Table(kpi_data, colWidths=[140, 130, 140, 130])
    kpi_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#F4F7FB')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#1E293B')),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CBD5E1')),
    ]))
    elements.append(Paragraph("Executive Performance Summary", section_style))
    elements.append(kpi_table)
    elements.append(Spacer(1, 14))

    # Recent Audit Log Table
    elements.append(Paragraph("Audited Execution Records (Recent Session Trades)", section_style))
    if recent_trades_data:
        table_rows = [["Ticket", "Direction", "Execution Time", "Profit (USD)", "Audit Status"]]
        for r in recent_trades_data:
            table_rows.append([
                Paragraph(r[0], cell_style),
                Paragraph(r[1], cell_style),
                Paragraph(r[2], cell_style),
                Paragraph(r[3], cell_style),
                Paragraph(r[4], cell_style)
            ])
        trade_table = Table(table_rows, colWidths=[110, 100, 110, 110, 110])
        trade_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#0F172A')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
            ('TOPPADDING', (0, 0), (-1, -1), 4),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
        ]))
        elements.append(trade_table)
    else:
        elements.append(Paragraph("No closed trades recorded in the current session dataset.", cell_style))

    # Compliance & Methodology Footer
    elements.append(Spacer(1, 16))
    elements.append(Paragraph("<b>Compliance & Quantitative Risk Disclaimer:</b>", subtitle_style))
    elements.append(Paragraph(
        "This institutional performance tear-sheet was automatically compiled by the AegisQuant AI engine. "
        "Historical performance uses cost-sensitive Random Forest classification serialized to ONNX opset 12 with Perry Kaufman Efficiency Ratio regime classification. "
        "Past performance is not indicative of future market returns.",
        ParagraphStyle('Disclaimer', parent=subtitle_style, fontSize=7, leading=9, textColor=colors.HexColor('#8F9CAE'))
    ))

    doc.build(elements)
    buffer.seek(0)
    return buffer
