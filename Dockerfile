########################################
# Atlas Platform App — Multi-stage Build
# Vendor approach: pre-downloaded wheels
########################################

FROM python:3.12-slim AS builder

WORKDIR /build
COPY requirements.txt .
COPY vendor/ /tmp/vendor/

# Install from pre-downloaded wheels (no internet needed)
RUN pip install --no-cache-dir --no-index --find-links=/tmp/vendor/ -r requirements.txt

COPY . ./app/

# --- Production stage ---
FROM python:3.12-slim

WORKDIR /app

# Non-root user (Kyverno policy requires runAsNonRoot)
RUN groupadd -r appuser && useradd -r -g appuser -s /sbin/nologin appuser

# Copy installed packages and app code
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn
COPY --from=builder /build/app .

USER appuser
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]