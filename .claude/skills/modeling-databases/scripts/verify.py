#!/usr/bin/env python3
"""Verify modeling-databases skill has required references."""
import os
import sys

def main():
    skill_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    migrations_ref = os.path.join(skill_dir, "references", "migrations.md")

    if os.path.isfile(migrations_ref):
        print("✓ modeling-databases skill ready")
        sys.exit(0)
    else:
        print("✗ Missing references/migrations.md")
        sys.exit(1)

if __name__ == "__main__":
    main()
