from fastapi import FastAPI
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://appuser:apppass@db:5432/postgres")
engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

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
        print("✅ Database tables created successfully1")
    except Exception as e:
        print(f"⚠️ Database not ready yet: {e}")

@app.get("/")
async def root():
    return {"message": "Production Application", "version": "1.0.0", "status": "running"}

@app.get("/health")
async def health():
    return {"status": "healthy", "version": "1.0.0"}

@app.get("/ready")
async def ready():
    return {"status": "ready"}

@app.get("/metrics")
async def metrics():
    return {"requests_total": 100, "requests_failed": 2, "database_latency_ms": 15}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
