# Use the official Python image version 3.11.10-slim-bookworm
FROM python:3.11.10-slim-bookworm

LABEL org.opencontainers.image.source https://github.com/lelouvincx/wwi-data-platform
LABEL org.opencontainers.image.descripiton "Docker image for all-purpose prefect"

# Set this to avoid buffering stdout and stderr
ENV PYTHONUNBUFFERED=1
ENV UV_SYSTEM_PYTHON=1

# Install curl and ca-certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl=7.88.1-10+deb12u8 \
  ca-certificates=20230311 \
  git-core && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

# Set the working directory
WORKDIR /app

# Install uv and dependencies
COPY --from=ghcr.io/astral-sh/uv:0.5.26 /uv /uvx /bin/
RUN --mount=type=cache,target=/root/.cache/uv \
  --mount=type=bind,source=uv.lock,target=uv.lock \
  --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
  uv sync --no-dev --frozen --no-install-project --verbose

# Copy the rest of the application code
COPY pipelines/ /app/pipelines/
COPY pyproject.toml uv.lock /app/
COPY prefect.yaml /app/

# Sync the project with local packages
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --frozen

# Expose the port on which the application will run
ENV PYTHONPATH=/app

# Copy setup.sh and make it executable
COPY setup.sh /app/setup.sh
RUN chmod +x /app/setup.sh

# Tail to /dev/null to keep the container running, specify command in docker compose to override
CMD ["tail", "-f", "/dev/null"]
