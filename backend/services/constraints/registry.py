from typing import Dict, Type
from .base import BaseConstraint

class ConstraintRegistry:
    _constraints: Dict[str, Type[BaseConstraint]] = {}

    @classmethod
    def register(cls, constraint_class: Type[BaseConstraint]):
        if not hasattr(constraint_class, 'CODE'):
            raise ValueError(f"Constraint {constraint_class.__name__} must have a CODE attribute")
        cls._constraints[constraint_class.CODE] = constraint_class
        return constraint_class

    @classmethod
    def get_constraint(cls, code: str) -> Type[BaseConstraint]:
        return cls._constraints.get(code)

    @classmethod
    def get_all_constraints(cls) -> Dict[str, Type[BaseConstraint]]:
        return cls._constraints
