#!/bin/bash
# Run analysis after evaluation has been run
# NB: only uv run works, running the script directly does not for some reason

uv run analysis/eval_performance.py
