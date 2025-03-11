#!/bin/bash

echo "Setting up Prefect environment..."

# echo "Creating a default work-pool with name 'process-work-pool' and type 'process'..."
# uv run prefect work-pool create process-work-pool --set-as-default --type process || true

# echo "Creating a default work-queue with name 'high' and type 'process'..."
# uv run prefect work-queue create high --pool process-work-pool --priority 1 --limit 3 || true

echo "Deploy flows"
uv run prefect deploy --all --prefect-file prefect-daemon.yaml

exit 0
