#!/usr/bin/env python3
"""
CI/CD Workflow Status Dashboard
Provides a unified view of all workflow jobs and their status
"""

import json
import subprocess
import sys
from datetime import datetime
from typing import Any, Dict, List, Optional


class Colors:
    """ANSI color codes for terminal output"""

    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    CYAN = "\033[96m"
    MAGENTA = "\033[95m"
    WHITE = "\033[97m"
    BOLD = "\033[1m"
    RESET = "\033[0m"


def run_gh_command(args: List[str]) -> Any:
    """Run GitHub CLI command and return JSON output"""
    try:
        result = subprocess.run(
            ["gh"] + args, capture_output=True, text=True, check=True
        )
        return json.loads(result.stdout) if result.stdout else None
    except subprocess.CalledProcessError as e:
        print(f"{Colors.RED}Error running gh command: {e}{Colors.RESET}")
        return None
    except json.JSONDecodeError as e:
        print(f"{Colors.RED}Error parsing JSON: {e}{Colors.RESET}")
        return None


def get_status_icon(status: str, conclusion: Optional[str] = None) -> str:
    """Return emoji icon for job status"""
    if conclusion:
        return {
            "success": "✅",
            "failure": "❌",
            "cancelled": "🚫",
            "skipped": "⏭️",
            "neutral": "⚪",
        }.get(conclusion, "❓")

    return {"completed": "✅", "in_progress": "🔄", "queued": "⏳", "waiting": "⏸️"}.get(
        status, "❓"
    )


def format_duration(start: str, end: Optional[str] = None) -> str:
    """Calculate and format duration"""
    if not start:
        return "N/A"

    try:
        start_time = datetime.fromisoformat(start.replace("Z", "+00:00"))
        end_time = (
            datetime.fromisoformat(end.replace("Z", "+00:00"))
            if end
            else datetime.now()
        )
        duration = end_time - start_time

        minutes = int(duration.total_seconds() // 60)
        seconds = int(duration.total_seconds() % 60)

        if minutes > 0:
            return f"{minutes}m {seconds}s"
        return f"{seconds}s"
    except:
        return "N/A"


def print_header(text: str, char: str = "="):
    """Print formatted header"""
    print(f"\n{Colors.BOLD}{Colors.CYAN}{char * 60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}{text}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}{char * 60}{Colors.RESET}\n")


def display_workflow_summary(run_data: Dict):
    """Display workflow run summary"""
    print_header("📊 Workflow Run Summary")

    print(
        f"{Colors.BOLD}Run ID:{Colors.RESET}       #{run_data.get('databaseId', 'N/A')}"
    )
    print(
        f"{Colors.BOLD}Branch:{Colors.RESET}      {run_data.get('headBranch', 'N/A')}"
    )
    print(f"{Colors.BOLD}Event:{Colors.RESET}       {run_data.get('event', 'N/A')}")
    print(f"{Colors.BOLD}Status:{Colors.RESET}      {run_data.get('status', 'N/A')}")

    conclusion = run_data.get("conclusion", "N/A")
    if conclusion == "success":
        print(
            f"{Colors.BOLD}Result:{Colors.RESET}      {Colors.GREEN}{conclusion}{Colors.RESET}"
        )
    elif conclusion == "failure":
        print(
            f"{Colors.BOLD}Result:{Colors.RESET}      {Colors.RED}{conclusion}{Colors.RESET}"
        )
    else:
        print(f"{Colors.BOLD}Result:{Colors.RESET}      {conclusion}")

    print(f"{Colors.BOLD}Created:{Colors.RESET}     {run_data.get('createdAt', 'N/A')}")
    print(f"{Colors.BOLD}Updated:{Colors.RESET}     {run_data.get('updatedAt', 'N/A')}")


def display_jobs_overview(jobs: List[Dict]):
    """Display overview of all jobs"""
    print_header("🔧 Jobs Overview")

    for job in jobs:
        name = job.get("name", "Unknown")
        status = job.get("status", "unknown")
        conclusion = job.get("conclusion")
        started = job.get("startedAt", "")
        completed = job.get("completedAt", "")

        icon = get_status_icon(status, conclusion)
        duration = format_duration(started, completed)

        # Color code based on conclusion
        if conclusion == "success":
            color = Colors.GREEN
        elif conclusion == "failure":
            color = Colors.RED
        elif conclusion == "skipped":
            color = Colors.YELLOW
        else:
            color = Colors.WHITE

        print(f"{icon} {color}{name:<50}{Colors.RESET} [{duration}]")


def display_job_details(jobs: List[Dict]):
    """Display detailed breakdown of each job"""
    print_header("📋 Detailed Job Breakdown")

    for job in jobs:
        name = job.get("name", "Unknown")
        status = job.get("status", "unknown")
        conclusion = job.get("conclusion", "N/A")
        steps = job.get("steps", [])

        print(f"\n{Colors.BOLD}{Colors.MAGENTA}Job: {name}{Colors.RESET}")
        print(f"Status: {status} | Conclusion: {conclusion}")
        print(f"\nSteps ({len(steps)}):")

        for step in steps:
            step_name = step.get("name", "Unknown")
            step_conclusion = step.get("conclusion", "pending")
            step_icon = get_status_icon("", step_conclusion)

            if step_conclusion == "success":
                color = Colors.GREEN
            elif step_conclusion == "failure":
                color = Colors.RED
            else:
                color = Colors.WHITE

            print(f"  {step_icon} {color}{step_name}{Colors.RESET}")


def display_statistics(jobs: List[Dict]):
    """Display workflow statistics"""
    print_header("📈 Statistics")

    total = len(jobs)
    success = sum(1 for j in jobs if j.get("conclusion") == "success")
    failure = sum(1 for j in jobs if j.get("conclusion") == "failure")
    skipped = sum(1 for j in jobs if j.get("conclusion") == "skipped")
    in_progress = sum(1 for j in jobs if j.get("status") == "in_progress")

    print(f"{Colors.BOLD}Total Jobs:{Colors.RESET}      {total}")
    print(f"{Colors.GREEN}✅ Success:{Colors.RESET}      {success}")
    print(f"{Colors.RED}❌ Failed:{Colors.RESET}       {failure}")
    print(f"{Colors.YELLOW}⏭️  Skipped:{Colors.RESET}      {skipped}")
    print(f"{Colors.BLUE}🔄 In Progress:{Colors.RESET}  {in_progress}")

    if total > 0:
        success_rate = (success / total) * 100
        print(f"\n{Colors.BOLD}Success Rate:{Colors.RESET}    {success_rate:.1f}%")

        # Progress bar
        bar_length = 40
        filled = int(bar_length * success / total)
        bar = "█" * filled + "░" * (bar_length - filled)
        print(f"{Colors.GREEN}{bar}{Colors.RESET}")


def display_quick_actions(run_id: int):
    """Display quick action commands"""
    print_header("🔗 Quick Actions")

    print(f"{Colors.CYAN}View in browser:{Colors.RESET}  gh run view {run_id} --web")
    print(f"{Colors.CYAN}View logs:{Colors.RESET}        gh run view {run_id} --log")
    print(
        f"{Colors.CYAN}View failed logs:{Colors.RESET} gh run view {run_id} --log-failed"
    )
    print(f"{Colors.CYAN}Rerun workflow:{Colors.RESET}   gh run rerun {run_id}")
    print(f"{Colors.CYAN}Watch live:{Colors.RESET}       gh run watch {run_id}")


def main():
    """Run the workflow status dashboard"""
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'=' * 60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}CI/CD Unified Workflow Dashboard{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'=' * 60}{Colors.RESET}\n")

    # Check if gh is installed
    try:
        subprocess.run(["gh", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(f"{Colors.RED}❌ GitHub CLI (gh) is not installed{Colors.RESET}")
        print("Install it with: sudo apt install gh")
        sys.exit(1)

    # Get latest workflow run
    print("🔍 Fetching latest CI/CD workflow run...")

    runs = run_gh_command(
        [
            "run",
            "list",
            "--workflow=ci-cd.yml",
            "--limit",
            "1",
            "--json",
            "databaseId,status,conclusion,headBranch,event,createdAt,updatedAt",
        ]
    )

    if not runs or len(runs) == 0:
        print(f"{Colors.RED}❌ No workflow runs found{Colors.RESET}")
        sys.exit(1)

    run_data = runs[0]
    run_id = run_data.get("databaseId")

    # Get detailed job information
    detailed_run = run_gh_command(["run", "view", str(run_id), "--json", "jobs"])

    if not detailed_run:
        print(f"{Colors.RED}❌ Failed to fetch workflow details{Colors.RESET}")
        sys.exit(1)

    jobs = detailed_run.get("jobs", [])

    # Display all information
    display_workflow_summary(run_data)
    display_jobs_overview(jobs)
    display_statistics(jobs)
    display_job_details(jobs)
    display_quick_actions(run_id)

    print(f"\n{Colors.BOLD}{Colors.GREEN}✨ Dashboard Complete{Colors.RESET}\n")


if __name__ == "__main__":
    main()
