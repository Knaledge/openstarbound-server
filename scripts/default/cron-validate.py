#!/usr/bin/env python3
import sys
from cron_validator import CronValidator

def main():
    if len(sys.argv) != 2:
        print("Usage: cron-validate '<cron_expr>'", file=sys.stderr)
        sys.exit(2)
    expr = sys.argv[1]
    try:
        if CronValidator.parse(expr) is not None:
            sys.exit(0)
        else:
            print(f"Invalid cron expression: {expr}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Invalid cron expression: {expr}\n{e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
