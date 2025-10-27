#!/usr/bin/env python3
"""
CI/CD Status Checker
Quick visual check of your CI/CD setup status
"""

import os
import subprocess
import sys
from pathlib import Path

# ANSI color codes
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
BOLD = "\033[1m"
RESET = "\033[0m"


def check_mark(status):
    return f"{GREEN}✓{RESET}" if status else f"{RED}✗{RESET}"


def warning_mark():
    return f"{YELLOW}⚠{RESET}"


def print_header(text):
    print(f"\n{BOLD}{BLUE}{'='*60}{RESET}")
    print(f"{BOLD}{BLUE}{text:^60}{RESET}")
    print(f"{BOLD}{BLUE}{'='*60}{RESET}\n")


def check_git_remote():
    """Check if git remote is configured"""
    try:
        result = subprocess.run(
            ["git", "remote", "-v"], capture_output=True, text=True, check=True
        )
        if "origin" in result.stdout:
            remote_url = subprocess.run(
                ["git", "remote", "get-url", "origin"],
                capture_output=True,
                text=True,
                check=True,
            )
            return True, remote_url.stdout.strip()
        return False, None
    except:
        return False, None


def check_workflow_files():
    """Check if all workflow files exist"""
    workflows = ["ci-cd.yml", "deploy.yml", "pr-checks.yml", "docker-publish.yml"]
    results = {}
    for workflow in workflows:
        path = Path(".github/workflows") / workflow
        results[workflow] = path.exists()
    return results


def check_docker():
    """Check if Docker is available"""
    try:
        subprocess.run(["docker", "--version"], capture_output=True, check=True)
        return True
    except:
        return False


def check_docker_compose():
    """Check if Docker Compose is available"""
    try:
        subprocess.run(
            ["docker", "compose", "version"], capture_output=True, check=True
        )
        return True
    except:
        return False


def check_python_tools():
    """Check if Python linting tools are installed"""
    tools = ["black", "isort", "flake8"]
    results = {}
    for tool in tools:
        try:
            subprocess.run([tool, "--version"], capture_output=True, check=True)
            results[tool] = True
        except:
            results[tool] = False
    return results


def check_dockerfiles():
    """Check if all service Dockerfiles exist"""
    services = [
        "user-management-service",
        "academic-service",
        "attendance-service",
        "notification-service",
        "leave-management-service",
        "feedback-service",
        "assessment-service",
        "financial-service",
        "api-gateway",
        "frontend-service",
    ]
    results = {}
    for service in services:
        path = Path("microservices") / service / "Dockerfile"
        results[service] = path.exists()
    return results


def main():
    print_header("CI/CD STATUS CHECKER")

    # Overall status
    issues = []
    warnings = []

    # Check 1: Git Remote
    print(f"{BOLD}1. Git Configuration{RESET}")
    has_remote, remote_url = check_git_remote()
    print(f"   Git Remote: {check_mark(has_remote)}")
    if has_remote:
        print(f"   URL: {remote_url}")
    else:
        print(f"   {RED}Issue: No GitHub remote configured{RESET}")
        issues.append("No GitHub remote - CI/CD won't trigger")

    # Check 2: Workflow Files
    print(f"\n{BOLD}2. GitHub Actions Workflows{RESET}")
    workflows = check_workflow_files()
    all_workflows = all(workflows.values())
    for name, exists in workflows.items():
        print(f"   {name}: {check_mark(exists)}")
    if not all_workflows:
        issues.append("Missing workflow files")

    # Check 3: Docker
    print(f"\n{BOLD}3. Docker Environment{RESET}")
    has_docker = check_docker()
    has_compose = check_docker_compose()
    print(f"   Docker: {check_mark(has_docker)}")
    print(f"   Docker Compose: {check_mark(has_compose)}")
    if not has_docker:
        issues.append("Docker not installed")
    if not has_compose:
        issues.append("Docker Compose not installed")

    # Check 4: Python Tools
    print(f"\n{BOLD}4. Python Linting Tools{RESET}")
    tools = check_python_tools()
    for tool, installed in tools.items():
        print(f"   {tool}: {check_mark(installed)}")
    if not all(tools.values()):
        warnings.append("Some Python tools missing (optional for CI/CD)")

    # Check 5: Dockerfiles
    print(f"\n{BOLD}5. Service Dockerfiles{RESET}")
    dockerfiles = check_dockerfiles()
    all_dockerfiles = all(dockerfiles.values())
    missing = [s for s, exists in dockerfiles.items() if not exists]
    if all_dockerfiles:
        print(f"   All Dockerfiles: {check_mark(True)} (10/10)")
    else:
        print(f"   Dockerfiles: {check_mark(False)} ({sum(dockerfiles.values())}/10)")
        for service in missing:
            print(f"   {RED}Missing: {service}{RESET}")
        issues.append(f"Missing {len(missing)} Dockerfile(s)")

    # Check 6: Docker Compose
    print(f"\n{BOLD}6. Docker Compose Configuration{RESET}")
    compose_file = Path("microservices/docker-compose.yml")
    has_compose_file = compose_file.exists()
    print(f"   docker-compose.yml: {check_mark(has_compose_file)}")
    if not has_compose_file:
        issues.append("docker-compose.yml not found")

    # Summary
    print_header("SUMMARY")

    if not issues and not warnings:
        print(f"{GREEN}{BOLD}✓ CI/CD Setup Status: EXCELLENT{RESET}")
        print(f"\nYour CI/CD configuration is complete!")
        if not has_remote:
            print(f"\n{YELLOW}Next Step:{RESET}")
            print(f"  1. Create GitHub repository")
            print(
                f"  2. git remote add origin https://github.com/Sneha-Martin18/LEARNOVA.git"
            )
            print(f"  3. git push -u origin main")
            print(f"  4. Check Actions tab on GitHub")
    else:
        print(f"{YELLOW}{BOLD}⚠ CI/CD Setup Status: NEEDS ATTENTION{RESET}\n")

        if issues:
            print(f"{RED}{BOLD}Critical Issues:{RESET}")
            for i, issue in enumerate(issues, 1):
                print(f"  {i}. {issue}")

        if warnings:
            print(f"\n{YELLOW}{BOLD}Warnings:{RESET}")
            for i, warning in enumerate(warnings, 1):
                print(f"  {i}. {warning}")

    # Recommendations
    print(f"\n{BOLD}Recommendations:{RESET}")
    if not has_remote:
        print(f"  {YELLOW}1.{RESET} Connect to GitHub to activate CI/CD")
        print(
            f"     git remote add origin https://github.com/Sneha-Martin18/LEARNOVA.git"
        )
    if not all(tools.values()):
        print(f"  {YELLOW}2.{RESET} Install Python tools for local testing")
        print(f"     pip install black isort flake8")
    if issues or warnings:
        print(f"  {YELLOW}3.{RESET} Review detailed report: CICD_STATUS_REPORT.md")
        print(f"  {YELLOW}4.{RESET} Run test script: ./test_cicd.sh")

    print(f"\n{BOLD}Documentation:{RESET}")
    print(f"  • CI_CD_VERIFICATION_GUIDE.md - Detailed verification steps")
    print(f"  • CICD_STATUS_REPORT.md - Complete status report")
    print(f"  • .github/CICD_DOCUMENTATION.md - CI/CD pipeline docs")

    print()

    # Exit code
    sys.exit(1 if issues else 0)


if __name__ == "__main__":
    main()
