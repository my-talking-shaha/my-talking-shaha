"""
Maintenance prediction function.
"""

from datetime import datetime
from typing import Dict, List
from ml.models import CarSpec, Usage, MaintenanceNeed


def predict(spec: CarSpec, usage: Usage) -> Dict[str, any]:
    OIL_CHANGE_KM = 3000
    OIL_CHANGE_MONTHS = 6
    
    components = {
        'Engine Oil': (3000, 6),
        'Oil Filter': (3000, 6),
        'Air Filter': (15000, 12),
        'Cabin Air Filter': (15000, 12),
        'Brake Fluid': (40000, 24),
        'Brake Pads': (50000, 24),
        'Transmission Fluid': (40000, 24),
        'Coolant': (40000, 24),
        'Spark Plugs': (30000, 12),
        'Battery': (10000, 12),
        'Tire Rotation': (10000, 6),
        'Suspension': (20000, 12),
    }
    
    days_since_maintenance = (datetime.now() - usage.last_maintenance_date).days
    
    needs = {}
    urgent = []
    
    for component, (km_interval, month_interval) in components.items():
        days_interval = month_interval * 30
        
        needed = (usage.total_distance_km >= km_interval) or (days_since_maintenance >= days_interval)
        
        if needed:
            km_remaining = None
            days_remaining = None
            reason = f"Distance: {usage.total_distance_km:.0f} km or Time: {days_since_maintenance} days exceeded"
            urgent.append(component)
        else:
            km_remaining = int(km_interval - usage.total_distance_km)
            days_remaining = int(days_interval - days_since_maintenance)
            reason = f"{km_remaining} km or {days_remaining} days remaining"
        
        needs[component] = MaintenanceNeed(
            name=component,
            needed=needed,
            reason=reason,
            km_remaining=km_remaining,
            days_remaining=days_remaining
        )
    
    return {
        'components': needs,
        'urgent_count': len(urgent),
        'urgent_services': urgent,
        'total_components': len(components),
        'analysis_date': datetime.now().isoformat()
    }
