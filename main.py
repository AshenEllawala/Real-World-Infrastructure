from fastapi import FastAPI, Response
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from prometheus_client import Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://appuser:apppass@db:5432/postgres")
engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ============================================================================
# Prometheus Metrics
# ============================================================================
REQUEST_COUNT = Counter(
    'requests_total',
    'Total number of requests',
    ['method', 'endpoint']
)

FAILED_REQUEST_COUNT = Counter(
    'requests_failed_total',
    'Total number of failed requests'
)

DB_LATENCY = Gauge(
    'database_latency_ms',
    'Database latency in milliseconds'
)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String)
    email = Column(String)

app = FastAPI(title="Production App", version="1.0.0")

@app.on_event("startup")
async def startup():
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully")
    except Exception as e:
        print(f"⚠️ Database not ready yet: {e}")

@app.get("/")
async def root():
    REQUEST_COUNT.labels(method="GET", endpoint="/").inc()
    return {"message": "Production Application", "version": "1.0.1", "status": "running"}

@app.get("/health")
async def health():
    REQUEST_COUNT.labels(method="GET", endpoint="/health").inc()
    return {"status": "healthy", "version": "1.0.1"}

@app.get("/ready")
async def ready():
    REQUEST_COUNT.labels(method="GET", endpoint="/ready").inc()
    return {"status": "ready"}

@app.get("/metrics")
async def metrics():
    DB_LATENCY.set(15)
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
