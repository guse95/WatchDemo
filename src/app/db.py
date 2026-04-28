import datetime
import os
from sqlalchemy import (MetaData, String, create_engine,
                        Text, ForeignKey, CheckConstraint, Enum, DateTime, JSON)
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_async_engine(DATABASE_URL)
async_session = async_sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)
metadata = MetaData()

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "user"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    username: Mapped[str | None] = mapped_column(String(50))
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    pass_level: Mapped[int] = mapped_column(default=0, nullable=False)

    operations: Mapped[list["OperationHistory"]] = relationship(
        back_populates="booker"
    )

    sessions: Mapped[list["Sessions"]] = relationship(
        back_populates="user"
    )


class Resource(Base):
    __tablename__ = "resource"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)

    extra_attributes: Mapped[dict | None] = mapped_column(type_=JSON)

    operations: Mapped[list["OperationHistory"]] = relationship(
        back_populates="resource",
        foreign_keys="OperationHistory.resource_id"
    )


class OperationHistory(Base):
    __tablename__ = "operation_history"


    id: Mapped[int] = mapped_column(primary_key=True)
    booker_id: Mapped[int] = mapped_column(ForeignKey("user.id"), nullable=False)
    resource_id: Mapped[int] = mapped_column(ForeignKey("resource.id"), nullable=False)
    operation_type: Mapped[str] = mapped_column(Enum("book", "cancel", name="operation_type_enum"), nullable=False)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, default=func.now(), nullable=False)
    booked_from: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    booked_to: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)

    booker: Mapped["User"] = relationship(back_populates="operations")

    resource: Mapped["Resource"] = relationship(
        back_populates="operations",
        foreign_keys=[resource_id]
    )

class Sessions(Base):
    __tablename__ = "sessions"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id"), nullable=False)
    refresh_token_hash: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    expires_at: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)
    revoked_at: Mapped[datetime.datetime | None] = mapped_column(DateTime, nullable=True)
    user_agent: Mapped[str] = mapped_column(Text, nullable=True)

    user: Mapped["User"] = relationship(
        back_populates="sessions"
    )

async def get_db():
    async with async_session() as session:
        yield session