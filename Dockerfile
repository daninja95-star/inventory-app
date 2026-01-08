### Dockerfile for Python Flask application
### Use a lightweight base image
FROM python:3.9-slim-buster AS base

### Set environment variables
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py
ENV PORT=8080

### Create app directory
WORKDIR /app

### Install dependencies
COPY requirements.txt .
# Use a build argument for the GitHub token to install from private repos
ARG GITHUB_TOKEN
# Install git, configure it with the token, install dependencies, then clean up.
# Update sources, install git, install python packages, then remove git and clean up apt cache.
RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ buster/updates main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends git && \
    if [ -n "$GITHUB_TOKEN" ] ; then git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" ; fi && \
    pip install --no-cache-dir -r requirements.txt gunicorn && \
    apt-get purge -y --auto-remove git && rm -rf /var/lib/apt/lists/*

### Copy application code
COPY . .

### Command to run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"] # 'app:app' assumes Flask app instance is named 'app' in 'app.py'

### Healthcheck (optional but good practice)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD [ "curl", "-f", "http://localhost:8080/products/SKU001" ]
