#!/usr/bin/env python3
"""
Script de Chequeo de Salud del Repositorio Raíz Datamaq (~/.aider/datamaq_healthcheck.py)
Ejecuta de forma determinista ($0 tokens) el estado de Git y GitHub Actions.
Si todo está limpio, devuelve un estado OK. Si hay cambios/fallos, genera una instrucción para el LLM.
"""

import subprocess
import sys
from pathlib import Path

REPOS = ["app-datamaq", "datamaq-hub", "datamaq-telemetry", "www-datamaq"]


def run_cmd(cmd, cwd):
    try:
        res = subprocess.run(
            cmd, cwd=cwd, shell=True, capture_output=True, text=True, timeout=10
        )
        return res.stdout.strip(), res.stderr.strip(), res.returncode
    except Exception as e:
        return "", str(e), 1


def check_health():
    root_dir = Path.cwd()
    has_issues = False
    status_report = []

    for repo in REPOS:
        repo_path = root_dir / repo
        if not repo_path.exists() or not (repo_path / ".git").exists():
            continue

        repo_issues = []

        # 1. Chequeo determinista de Git Status
        git_out, _, _ = run_cmd("git status -s", repo_path)
        if git_out:
            repo_issues.append(f"Archivos modificados/pendientes en Git:\n{git_out}")

        # 2. Chequeo determinista de GitHub Actions (gh run list)
        gh_out, _, code = run_cmd(
            "gh run list -L 1 --json conclusion,workflowName,databaseId", repo_path
        )
        if code == 0 and gh_out:
            try:
                import json

                runs = json.loads(gh_out)
                if runs and runs[0].get("conclusion") == "failure":
                    repo_issues.append(
                        f"Última corrida de CI falló ({runs[0].get('workflowName')})"
                    )
            except Exception:
                pass

        if repo_issues:
            has_issues = True
            status_report.append(f"=== MÓDULO: {repo} ===")
            status_report.extend(repo_issues)

    if not has_issues:
        print(
            "✅ [Datamaq Healthcheck]: Todos los subrepositorios están limpios y en estado VERDE (Git Ok, CI Ok)."
        )
        sys.exit(0)
    else:
        print(
            "🚨 [Datamaq Healthcheck]: Se detectaron los siguientes temas pendientes de atención:"
        )
        print("\n".join(status_report))
        print(
            "\n🤖 Por favor analiza estos problemas de salud y ofrece soluciones o parches."
        )
        sys.exit(1)


if __name__ == "__main__":
    check_health()
