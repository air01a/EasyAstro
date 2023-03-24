from load_catalog import Load_Catalog
from coordinates import Coordinates
from datetime import datetime


catalog = Load_Catalog()
catalog.open('data/deepsky.lst')



test = Coordinates()
test.set_location_coord(50.669276,3.130782,32)
test.set_constraints()
test.set_time(test.time_local_to_utc(datetime.strptime('2023-03-23 22:32',"%Y-%m-%d %H:%M")))
print(test.get_catalog_visibility(catalog))
schedule = test.get_schedule(['M31','M91','M75','M41','M46','M59','M49','M8','M11','M54','M62','M64','M98','M102','M103','M21','M82','M88','M69','M57','M66','M44','M100','M72','M3','M7','M5','M39','M29','M107','M108'], catalog)
print(schedule)
print(test.to_json(schedule))


