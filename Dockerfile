### Dockerfile for Python Flask application
### Use a lightweight base image
FROM python:3.9-slim-buster as base

### Set environment variables
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP app.py
ENV PORT 8080

### Create app directory
WORKDIR /app

### Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

### Copy application code
COPY . .

### Command to run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"] # 'app:app' assumes Flask app instance is named 'app' in 'app.py'

### Healthcheck (optional but good practice)
HEALTHCHECK CMD curl --fail http://localhost:8080/products/SKU001 || exit 1
