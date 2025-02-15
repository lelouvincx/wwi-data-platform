# Use the official Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

LABEL org.opencontainers.image.source https://github.com/lelouvincx/wwi-data-platform

# Set the working directory
WORKDIR /app

# Set environment variables
ENV UV_SYSTEM_PYTHON=1
ENV PATH="/root/.local/bin:$PATH"

# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
  uv pip install -r requirements.txt

# Copy the rest of the application code
COPY flows/ .

# Set the entrypoint
# ENTRYPOINT ["python", "flows/test.py"]

# Tail to /dev/null to keep the container running, specify command in docker compose to override
CMD ["tail", "-f", "/dev/null"]
