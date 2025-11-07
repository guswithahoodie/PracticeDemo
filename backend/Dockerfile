FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y gcc libpq-dev build-essential && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Collect static files (optional)
# RUN python manage.py collectstatic --no-input

# Expose port 80 (Gunicorn)
EXPOSE 80

# Run migrations, then launch Gunicorn
CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn task_api.wsgi:application --bind 0.0.0.0:80 --workers 3"]
