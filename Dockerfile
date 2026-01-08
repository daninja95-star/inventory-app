# ---- Base Stage ----
# Use a specific Python version that matches your development environment (3.11)
# for reproducibility. The -slim variant is used for a smaller base image.
FROM python:3.11-slim-bullseye as base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT 8080

# Set the working directory
WORKDIR /app

# ---- Builder Stage ----
# This stage is for installing dependencies.
FROM base as builder

# Install curl for the healthcheck and build dependencies if any Python
# packages need compilation (e.g., gcc).
RUN apt-get update && apt-get install -y --no-install-recommends curl gcc && rm -rf /var/lib/apt/lists/*

# Copy only the requirements file to leverage Docker cache.
COPY requirements.txt .

# Install dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# ---- Final Stage ----
# This is the final, lean image for production.
FROM base
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY app.py .

# Expose the port the app runs on.
EXPOSE 8080

# Command to run the application using Gunicorn, referencing the PORT variable.
CMD ["gunicorn", "--bind", "0.0.0.0:$PORT", "app:app"]

# Healthcheck to ensure the application is running correctly.
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl --fail http://localhost:8080/products/SKU001 || exit 1