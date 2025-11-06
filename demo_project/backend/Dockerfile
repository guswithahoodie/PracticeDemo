FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# system deps
RUN apt-get update && apt-get install -y gcc libpq-dev build-essential && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# collect static if used (optional)
# RUN python manage.py collectstatic --no-input

# run migrations then start gunicorn on port 80
CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn task_api.wsgi:application --bind 0.0.0.0:80 --workers 3"]
