"""
Load car specifications from CSV files.
"""

import pandas as pd
from pathlib import Path
from typing import Optional
from ml.models import CarSpec


def load_car_spec(modification_id: str, csv_dir: Optional[str] = None) -> CarSpec:
    """
    Load car specification from CSV by modification ID.
    
    Args:
        modification_id: ID of car modification (from modifications.csv)
        csv_dir: Path to CSV directory. If None, uses default path.
        
    Returns:
        CarSpec object with car specifications
    """
    if csv_dir is None:
        csv_dir = Path(__file__).parent.parent / "cars" / "csv"
    else:
        csv_dir = Path(csv_dir)
    
    # Load specifications
    specs_df = pd.read_csv(csv_dir / "specifications.csv")
    
    # Find row with matching ID
    row = specs_df[specs_df['id'] == modification_id]
    
    if row.empty:
        raise ValueError(f"Specification not found for modification ID: {modification_id}")
    
    row = row.iloc[0]
    
    # Extract values, handling NaN/None
    engine_type = str(row['engine_type']) if pd.notna(row['engine_type']) else 'unknown'
    displacement = float(row['displacement']) if pd.notna(row['displacement']) else None
    transmission = str(row['transmission']) if pd.notna(row['transmission']) else 'unknown'
    weight = float(row['weight']) if pd.notna(row['weight']) else 0.0
    
    return CarSpec(
        engine_type=engine_type,
        displacement=displacement,
        transmission=transmission,
        weight=weight
    )


def list_modifications(csv_dir: Optional[str] = None) -> pd.DataFrame:
    """
    List all available modifications from CSV.
    
    Args:
        csv_dir: Path to CSV directory. If None, uses default path.
        
    Returns:
        DataFrame with modifications info
    """
    if csv_dir is None:
        csv_dir = Path(__file__).parent.parent / "cars" / "csv"
    else:
        csv_dir = Path(csv_dir)
    
    mods_df = pd.read_csv(csv_dir / "modifications.csv")
    return mods_df[['id', 'mark_id', 'name', 'group_name']]
