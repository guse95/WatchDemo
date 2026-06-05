from enum import Enum


class OperationStatus(Enum):
    ACTIVE = "ACTIVE"
    CANCELED = "CANCELED"
    FINISHED = "FINISHED"