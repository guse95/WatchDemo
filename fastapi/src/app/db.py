import os

from sqlalchemy import (Column, MetaData, String, Table,
                        create_engine, Boolean, Text, ForeignKey, CheckConstraint, Enum)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from databases import Database

DATABASE_URL = os.getenv("DATABASE_URL")

# SQLAlchemy
engine = create_engine(DATABASE_URL)
metadata = MetaData()

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "user"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    username: Mapped[str | None] = mapped_column(String(50))
    login: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    pass_level: Mapped[int] = mapped_column(default=0, nullable=False)

    operations: Mapped[list["OperationHistory"]] = relationship(
        back_populates="booker"
    )


class Room(Base):
    __tablename__ = "room"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    capacity: Mapped[int] = mapped_column(nullable=False)
    has_board: Mapped[Boolean] = mapped_column(nullable=False)
    has_projector: Mapped[Boolean] = mapped_column(nullable=False)
    description: Mapped[str | None] = mapped_column(Text)

    operations: Mapped[list["OperationHistory"]] = relationship(
        back_populates="room",
        foreign_keys="OperationHistory.room_id"
    )


class Laptop(Base):
    __tablename__ = "laptop"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    os: Mapped[str] = mapped_column(String(50), nullable=False)
    model: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)

    operations: Mapped[list["OperationHistory"]] = relationship(
        back_populates="laptop",
        foreign_keys="OperationHistory.laptop_id"
    )


class OperationHistory(Base):
    __tablename__ = "operation_history"

    __table_args__ = (
        CheckConstraint(
            "(room_id IS NOT NULL AND laptop_id IS NULL) OR "
            "(room_id IS NULL AND laptop_id IS NOT NULL)",
            name="exactly_one_object"
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    booker_id: Mapped[int] = mapped_column(ForeignKey("user.id"), nullable=False)
    room_id: Mapped[int | None] = mapped_column(ForeignKey("room.id"))
    laptop_id: Mapped[int | None] = mapped_column(ForeignKey("laptop.id"))
    operation_type: Mapped[str] = mapped_column(Enum("book", "cancel", name="operation_type_enum"), nullable=False)
    created_at: Mapped[DateTime] = mapped_column(default=func.now(), nullable=False)
    booked_from: Mapped[DateTime] = mapped_column(nullable=False)
    booked_to: Mapped[DateTime] = mapped_column(nullable=False)

    booker: Mapped["User"] = relationship(back_populates="operations")

    room: Mapped["Room | None"] = relationship(
        back_populates="operations",
        foreign_keys=[room_id]
    )

    laptop: Mapped["Laptop | None"] = relationship(
        back_populates="operations",
        foreign_keys=[laptop_id]
    )

    @property
    def object(self):
        return self.room or self.laptop



# databases query builder
database = Database(DATABASE_URL)