---
name: modeling-databases
description: |
  Design and implement database schemas using SQLModel with sync and async patterns.
  Use when creating database models for FastAPI, setting up PostgreSQL/Neon connections,
  defining relationships (one-to-many, many-to-many), or implementing async database operations.
  NOT when using raw SQLAlchemy without Pydantic validation needs.
---

# SQLModel Database

Design and implement database schemas using SQLModel - combining SQLAlchemy's power with Pydantic's validation.

## Quick Start

```bash
# Async support (recommended for FastAPI)
uv add sqlmodel sqlalchemy[asyncio] asyncpg  # PostgreSQL
# or
uv add sqlmodel sqlalchemy[asyncio] aiosqlite  # SQLite
```

---

## Core Patterns

### 1. Model Hierarchy (Base → Table → API)

```python
from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional, Literal

# Base model - shared fields, validation, NO table
class TaskBase(SQLModel):
    title: str = Field(max_length=200, index=True)
    description: Optional[str] = None
    status: Literal["pending", "in_progress", "completed"] = "pending"
    priority: Literal["low", "medium", "high"] = "medium"

# Table model - has table=True, adds id and timestamps
class Task(TaskBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

# Create model - for POST requests
class TaskCreate(TaskBase):
    pass

# Update model - all fields optional for PATCH
class TaskUpdate(SQLModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None

# Read model - for responses
class TaskRead(TaskBase):
    id: int
    created_at: datetime
```

### 2. Async Database Connection

```python
from sqlmodel import SQLModel
from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine
import os

# postgresql+asyncpg://user:pass@host/db
DATABASE_URL = os.getenv("DATABASE_URL")

async_engine = create_async_engine(DATABASE_URL, echo=True)

async def create_db_and_tables():
    async with async_engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)

async def get_session() -> AsyncSession:
    async with AsyncSession(async_engine) as session:
        yield session
```

### 3. FastAPI CRUD Integration

```python
from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import select

app = FastAPI()

@app.on_event("startup")
async def on_startup():
    await create_db_and_tables()

@app.post("/tasks", response_model=TaskRead, status_code=201)
async def create_task(task: TaskCreate, session: AsyncSession = Depends(get_session)):
    db_task = Task.model_validate(task)
    session.add(db_task)
    await session.commit()
    await session.refresh(db_task)
    return db_task

@app.get("/tasks/{task_id}", response_model=TaskRead)
async def get_task(task_id: int, session: AsyncSession = Depends(get_session)):
    task = await session.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@app.patch("/tasks/{task_id}", response_model=TaskRead)
async def update_task(task_id: int, task_update: TaskUpdate, session: AsyncSession = Depends(get_session)):
    task = await session.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    # Key pattern: only update provided fields
    update_data = task_update.model_dump(exclude_unset=True)
    task.sqlmodel_update(update_data)
    session.add(task)
    await session.commit()
    await session.refresh(task)
    return task
```

### 4. Relationships

#### One-to-Many

```python
from sqlmodel import Relationship

class Project(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    tasks: List["Task"] = Relationship(back_populates="project")

class Task(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    project_id: Optional[int] = Field(default=None, foreign_key="project.id")
    project: Optional[Project] = Relationship(back_populates="tasks")
```

#### Many-to-Many

```python
class TaskWorkerLink(SQLModel, table=True):
    task_id: Optional[int] = Field(default=None, foreign_key="task.id", primary_key=True)
    worker_id: Optional[str] = Field(default=None, foreign_key="worker.id", primary_key=True)

class Worker(SQLModel, table=True):
    id: str = Field(primary_key=True)
    name: str
    tasks: List["Task"] = Relationship(back_populates="workers", link_model=TaskWorkerLink)

class Task(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    workers: List[Worker] = Relationship(back_populates="tasks", link_model=TaskWorkerLink)
```

### 5. Query Patterns

```python
from sqlmodel import select, or_

# Basic queries
statement = select(Task).where(Task.status == "pending")
results = await session.exec(statement)
tasks = results.all()

# Multiple conditions
statement = select(Task).where(Task.status == "pending", Task.priority == "high")

# OR conditions
statement = select(Task).where(or_(Task.status == "pending", Task.status == "in_progress"))

# Ordering and pagination
statement = select(Task).order_by(Task.created_at.desc()).offset(20).limit(10)

# Get by ID
task = await session.get(Task, task_id)

# Eager loading relationships
from sqlalchemy.orm import selectinload
statement = select(Task).options(selectinload(Task.project))
```

### 6. Neon PostgreSQL Connection

```python
DATABASE_URL = os.getenv("DATABASE_URL")

# Convert sync URL to async
if DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace(
        "postgresql://", "postgresql+asyncpg://", 1
    ).replace("sslmode=", "ssl=")

async_engine = create_async_engine(DATABASE_URL, pool_size=5, max_overflow=10)
```

### 7. Testing Pattern

```python
import pytest
from sqlmodel import create_engine, Session
from sqlmodel.pool import StaticPool

@pytest.fixture
def session():
    """In-memory SQLite for fast tests."""
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session
```

---

## Critical: Async Session Patterns

**Always use `await session.exec()` not `session.execute()`** for SQLModel select statements.

```python
# Correct
results = await session.exec(select(Task))

# Also correct for getting by ID
task = await session.get(Task, task_id)
```

---

## Verification

Run: `python3 scripts/verify.py`

Expected: `✓ modeling-databases skill ready`

## If Verification Fails

1. Check: references/migrations.md exists
2. **Stop and report** if still failing

## References

- [references/migrations.md](references/migrations.md) - Database migration patterns with Alembic
