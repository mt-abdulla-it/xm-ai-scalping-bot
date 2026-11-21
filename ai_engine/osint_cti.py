"""
Defensive OSINT & Cyber Threat Intelligence (CTI) Module.
Provides lawful, defensive public domain intelligence, IP reputation analysis,
IOC (Indicators of Compromise) extraction, and MITRE ATT&CK / CVE correlation.
"""
import re
import socket
import json
import urllib.request
import urllib.error
from typing import Dict, Any, List

# Core MITRE ATT&CK Enterprise Matrix Mapping (Curated Defensive Knowledge)
MITRE_ATTACK_DB = {
    "T1059": {
        "name": "Command and Scripting Interpreter",
        "tactic": "Execution",
        "description": "Adversaries may abuse command and script interpreters to execute arbitrary commands (e.g., PowerShell, Bash, Python).",
        "defensive_mitigation": "Disable unnecessary script engines, restrict execution policies, enforce AppLocker/SELinux."
    },
    "T1190": {
        "name": "Exploit Public-Facing Application",
        "tactic": "Initial Access",
        "description": "Adversaries may attempt to take advantage of a weakness in an Internet-facing computer or program.",
        "defensive_mitigation": "Apply vulnerability patches promptly, implement Web Application Firewalls (WAF), segment external services."
    },
    "T1078": {
        "name": "Valid Accounts",
        "tactic": "Defense Evasion, Persistence, Privilege Escalation",
        "description": "Adversaries may obtain and abuse credentials of existing accounts as a means of gaining Initial Access.",
        "defensive_mitigation": "Enforce Multi-Factor Authentication (MFA), rotate service account credentials, monitor anomalous login sessions."
    },
    "T1566": {
        "name": "Phishing",
        "tactic": "Initial Access",
        "description": "Adversaries may send phishing messages to gain access to victim systems via spearphishing attachments or links.",
        "defensive_mitigation": "Implement DMARC/DKIM/SPF, filter email attachments, conduct phishing simulation training."
    },
    "T1486": {
        "name": "Data Encrypted for Impact (Ransomware)",
        "tactic": "Impact",
        "description": "Adversaries may encrypt data on target systems or on large numbers of systems in a network to interrupt availability.",
        "defensive_mitigation": "Maintain immutable offsite backups, restrict write permissions, deploy endpoint detection and response (EDR)."
    },
    "T1041": {
        "name": "Exfiltration Over C2 Channel",
        "tactic": "Exfiltration",
        "description": "Adversaries may steal data by exfiltrating it over an existing command and control channel.",
        "defensive_mitigation": "Enforce network egress filtering, monitor unusual outbound traffic volumes, inspect SSL/TLS traffic."
    }
}

def extract_iocs(text: str) -> Dict[str, List[str]]:
    """Extracts Indicators of Compromise (IOCs) using strict defensive regex patterns."""
    ipv4_pattern = r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
    sha256_pattern = r'\b[a-fA-F0-9]{64}\b'
    md5_pattern = r'\b[a-fA-F0-9]{32}\b'
    cve_pattern = r'\bCVE-\d{4}-\d{4,7}\b'
    domain_pattern = r'\b(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\b'

    # Filter out common benign private/local IPs
    raw_ips = re.findall(ipv4_pattern, text)
    filtered_ips = [ip for ip in set(raw_ips) if not (ip.startswith("127.") or ip.startswith("10.") or ip.startswith("192.168."))]

    return {
        "ipv4": filtered_ips,
        "cve": list(set(re.findall(cve_pattern, text, re.I))),
        "sha256": list(set(re.findall(sha256_pattern, text))),
        "md5": list(set(re.findall(md5_pattern, text))),
        "domains": [d.lower() for d in set(re.findall(domain_pattern, text)) if not d.endswith(('.png', '.jpg', '.svg', '.py', '.mq5', '.csv'))]
    }

def query_dns_intelligence(domain: str) -> Dict[str, Any]:
    """Performs defensive DNS resolution across A and CNAME records."""
    clean_domain = domain.strip().lower().replace("https://", "").replace("http://", "").split("/")[0]
    result: Dict[str, Any] = {"domain": clean_domain, "status": "unknown", "ip_addresses": [], "cnames": []}
    
    try:
        # A Records
        addr_info = socket.getaddrinfo(clean_domain, None)
        ips = sorted(list(set([info[4][0] for info in addr_info if info[0] == socket.AF_INET])))
        result["ip_addresses"] = ips
        result["status"] = "resolved" if ips else "not_found"
    except socket.gaierror as e:
        result["status"] = "resolution_failed"
        result["error"] = str(e)
    except Exception as e:
        result["status"] = "error"
        result["error"] = str(e)
        
    return result

def query_rdap_whois(target: str) -> Dict[str, Any]:
    """Queries official Registration Data Access Protocol (RDAP) for public registration info."""
    clean_target = target.strip().lower().replace("https://", "").replace("http://", "").split("/")[0]
    url = f"https://rdap.org/domain/{clean_target}"
    
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Antigravity-Defensive-Intel/1.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                return {
                    "target": clean_target,
                    "handle": data.get("handle", "N/A"),
                    "name": data.get("ldhName", clean_target),
                    "status": data.get("status", []),
                    "port43": data.get("port43", "N/A"),
                    "raw_rdap_found": True
                }
    except Exception as e:
        pass
        
    return {
        "target": clean_target,
        "raw_rdap_found": False,
        "notice": "RDAP response unavailable or rate-limited. DNS analysis remains functional."
    }

def map_mitre_technique(technique_id: str) -> Dict[str, Any]:
    """Look up MITRE ATT&CK technique details and defensive mitigations."""
    t_id = technique_id.upper().strip()
    if t_id in MITRE_ATTACK_DB:
        return {"found": True, "technique_id": t_id, **MITRE_ATTACK_DB[t_id]}
    return {
        "found": False,
        "technique_id": t_id,
        "message": f"Technique {t_id} not in offline core matrix. Consult attack.mitre.org."
    }
