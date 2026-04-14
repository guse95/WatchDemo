import os

from sqlalchemy import (Column, DateTime, Integer, MetaData, String, Table,
                        create_engine, Boolean, Text, ForeignKey)
from sqlalchemy.sql import func
from databases import Database

DATABASE_URL = os.getenv("DATABASE_URL")

# SQLAlchemy
engine = create_engine(DATABASE_URL)
metadata = MetaData()
Users = Table(
    "users",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("email", String(100), nullable=False, unique=True),
    Column("username", String(50)),
    Column("login", String(50), unique=True),
    Column("password", String(100), nullable=False),
    Column("pass_level", Integer, default=0, nullable=False),
)

Rooms = Table(
    "rooms",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("name", String(50), unique=True, nullable=False),
    Column("capacity", Integer, nullable=False),
    Column("has_board", Boolean, nullable=False),
    Column("has_projector", Boolean, nullable=False),
    Column("description", Text),
)

Laptops = Table(
    "laptops",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("name", String(50), unique=True, nullable=False),
    Column("os", String(50), nullable=False),
    Column("model", String(50), nullable=False),
    Column("description", Text),
)

OperationHistory = Table(
    "operation_history",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("object_type", String(50), nullable=False),
    Column("object_id", Integer, ForeignKey("rooms.id"), ForeignKey("laptops.id"), nullable=False),
    Column("operation_type", String(50), nullable=False),
    Column("booker_id", Integer, ForeignKey("users.id"), nullable=False),
    Column("created_date", DateTime, default=func.now(), nullable=False),
    Column("booked_from", DateTime, nullable=False),
    Column("booked_to", DateTime, nullable=False),
)


# databases query builder
database = Database(DATABASE_URL)