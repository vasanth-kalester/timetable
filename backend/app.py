"""
EduFlow FastAPI Backend — standalone entry point.
Run from the `backend/` directory:

    python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload

This file re-exports the FastAPI app using absolute imports,
so uvicorn can be run directly from the backend folder.
"""

import sys
import os

# Ensure the backend/ directory is in sys.path so absolute imports work
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import json

# ── Absolute imports (avoids relative import issues when running standalone) ──
from core.config import settings
from routers import auth, users, academic, infrastructure, audit

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(application: FastAPI):
    logger.info(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} starting up...")
    yield
    logger.info("👋 EduFlow API shutting down...")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
## EduFlow API — Phase 2: Institution & Academic Structure

A secure, role-based academic management API for engineering colleges.

### Auth
All protected endpoints require a `Bearer <token>` header.
Get a token via `POST /api/v1/auth/login`.
    """,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

API_PREFIX = "/api/v1"
app.include_router(auth.router, prefix=API_PREFIX)
app.include_router(users.router, prefix=API_PREFIX)
app.include_router(academic.router, prefix=API_PREFIX)
app.include_router(infrastructure.router, prefix=API_PREFIX)
app.include_router(audit.router, prefix=API_PREFIX)


@app.get("/", tags=["Health"])
def root():
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs",
    }


@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "database": "connected"}
