#!/usr/bin/env python3
"""Verify Domain and Data layer line coverage meets the project threshold."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import PurePosixPath


def layer_from_path(path: str) -> str | None:
    parts = PurePosixPath(path).parts
    for index, part in enumerate(parts):
        if part in {"Domain", "Data"} and index + 1 < len(parts):
            return part
    return None


def collect_layer_coverage(report: list | dict) -> tuple[int, int, dict[str, tuple[int, int]]]:
    targets = report if isinstance(report, list) else report.get("targets", [])

    layer_totals: dict[str, tuple[int, int]] = {"Domain": (0, 0), "Data": (0, 0)}

    for target in targets:
        for file_entry in target.get("files", []):
            path = file_entry.get("path", "")
            layer = layer_from_path(path)
            if layer is None:
                continue

            executable = int(file_entry.get("executableLines", 0))
            covered = int(file_entry.get("coveredLines", 0))
            if executable == 0:
                continue

            current_covered, current_executable = layer_totals[layer]
            layer_totals[layer] = (current_covered + covered, current_executable + executable)

    total_covered = sum(values[0] for values in layer_totals.values())
    total_executable = sum(values[1] for values in layer_totals.values())
    return total_covered, total_executable, layer_totals


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: check-domain-data-coverage.py <TestResults.xcresult> [threshold]", file=sys.stderr)
        return 2

    xcresult = sys.argv[1]
    threshold = float(sys.argv[2]) if len(sys.argv) > 2 else 0.90

    result = subprocess.run(
        ["xcrun", "xccov", "view", "--report", "--json", xcresult],
        capture_output=True,
        text=True,
        check=True,
    )
    report = json.loads(result.stdout)
    covered, executable, layer_totals = collect_layer_coverage(report)

    if executable == 0:
        print("No executable lines found for Domain/Data layers.", file=sys.stderr)
        return 1

    coverage = covered / executable
    print(f"Domain + Data line coverage: {coverage:.2%} ({covered}/{executable} lines)")

    for layer, (layer_covered, layer_executable) in layer_totals.items():
        if layer_executable == 0:
            print(f"  {layer}: no executable lines")
            continue
        layer_coverage = layer_covered / layer_executable
        print(f"  {layer}: {layer_coverage:.2%} ({layer_covered}/{layer_executable} lines)")

    if coverage < threshold:
        print(
            f"Coverage {coverage:.2%} is below required threshold {threshold:.0%}.",
            file=sys.stderr,
        )
        return 1

    print(f"Coverage meets the {threshold:.0%} threshold.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
