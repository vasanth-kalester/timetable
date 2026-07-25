from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import json
import os

from .core.config import settings
from .routers import auth, users, academic, infrastructure, audit, faculty, validation, session

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events."""
    logger.info(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} starting up...")
    logger.info(f"📦 Database: {os.path.abspath('../web_client/prisma/dev.db')}")
    yield
    logger.info("👋 EduFlow API shutting down...")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
## EduFlow API — Phase 2: Institution & Academic Structure

A secure, role-based academic management API for engineering colleges.

### Roles
- **Principal** — Full institutional access
- **HOD** — Department-level access  
- **Faculty** — Teaching and attendance access
- **Student** — View-only access

### Auth
All protected endpoints require a `Bearer <token>` header.
Get a token from `POST /api/v1/auth/login`.
    """,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS — allow Flutter app and Next.js web client
cors_origins = json.loads(settings.CORS_ORIGINS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API routers
API_PREFIX = "/api/v1"
app.include_router(auth.router, prefix=API_PREFIX)
app.include_router(users.router, prefix=API_PREFIX)
app.include_router(academic.router, prefix=API_PREFIX)
app.include_router(infrastructure.router, prefix=API_PREFIX)
app.include_router(audit.router, prefix=API_PREFIX)
app.include_router(faculty.router, prefix=API_PREFIX)
app.include_router(validation.router, prefix=API_PREFIX)
app.include_router(session.router, prefix=API_PREFIX)


@app.get("/", tags=["Health"])
def root():
    """Health check / root endpoint."""
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs",
    }


@app.get("/health", tags=["Health"])
def health_check():
    """Detailed health check for monitoring."""
    return {
        "status": "healthy",
        "api": "online",
        "database": "connected",
    }
