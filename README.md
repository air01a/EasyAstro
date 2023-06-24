
# EasyAstro
Plan your observations, pilot your telescope, stack your images easily
This project will permit to plan observation and to pilot a telescope easily, through a responsive web page. 
Compatible with indi (linux) and astap (windows)
Use Astap of local Astrometry.net for platesolving.


# CurrentState
Planification is fully operationnal. Piloting telescope still have some issues, and still require a lot of developpement. But, if you are patient, it is possible to use it.
It supports INDI and ASCAM.

FRONT:
- Display visible messier object at current time
- Can select messier object to plan an observation night
- Can tap long on an object to make a telescope goto
- Can change observation time


# Todo
- Improve front ui 
- Improve stacking
- Image processing with front
- Installation process

# Screenshot

*Web interface* 

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/web.png?raw=true "Web interface")

*Display information about object (time of rise, set and culmination) with altazimutal chart :* 

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/web2.png?raw=true "Web interface")

*Mobile interface*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/android.png?raw=true "Plan your observation")

*Plan your observation (modify time and location, to see visible objects for your next session, select them and save your list for later)*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/selecthour.png?raw=true "Plan your observation")

*Select objects*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/list.png?raw=true "Plan your observation")

*Connect to the easyastro backend to pilot your telescope*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/server.png?raw=true "Pilot your telescope")

*Choose exposition, move your scope to one of your target (the backend will platesolve to automatically sync your mount and center the object)*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/telescop2.png?raw=true "Pilot your telescope")

*The backend will stack your pictures to get an enhanced result*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/m97_stacking.png?raw=true "Live Stacking")
