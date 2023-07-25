
# EasyAstro
EasyAstro is designed to simplify access to astronomy. This application allows you to plan your astronomy sessions by indicating which objects (planets and deep sky) will be visible on a specific date and at a precise location.

Once your session is scheduled, if you have a telescope that can be controlled by INDI or ASCOM, the application will take care of piloting your telescope to go to the objects and then allow you to photograph them. A basic live stacking model will be displayed, enabling you to immediately enjoy a pleasing result from the captured images. If you wish to delve deeper, you will have access to the FITS files.

The front is written in dart with flutter framework, therefore, it is compatible with Windows, Linux, Web, Android and ios. As I don't have any macos device, I have not tested the ios compilation.

The back is written with python, and include drivers for indi and ascom software. You can use it on Linux or Windows. 

The EasyAstro application currently offers the following features:

-  Knowing which celestial objects are visible based on the time, location, and current conditions.
-  Selecting and saving objects for later use.
-  Controlling your telescope to point towards these objects (using plate solving for orientation and then navigating towards the target).
-  Capturing images of the objects while controlling the gain and exposure settings.
-  Adjust image processing settings.
-  Display live stacking of photos with the selected treatments.
-  Manage Dark libraries.

The application currently supports two languages: French (FR) and English (EN/US).

# CurrentState
Planification is fully operationnal. Piloting telescope still have some issues, and still require a lot of developpement. But, if you are patient, it is possible to use it.
It supports INDI and ASCAM.


Todo: 
- Improve front ui 
- Improve stacking
- Image processing with front
- Installation process

# Installation and configuration

Everything is explained in the wiki : 

[Wiki](https://github.com/air01a/EasyAstro/wiki)

# Screenshot

*Web interface* 

The application will show you what are the visible object at a date, and give you information about the visibility (green border, the object height will be more than 20°, orange, it will be below 20°, and red is not visible).

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/web.jpg?raw=true "Web interface")

*Display information about object (time of rise, set and culmination) with altazimutal chart :* 

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/web2.jpg?raw=true "Web interface")

*Mobile application*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/1.jpg?raw=true "Plan your observation")

*Plan your observation (modify time and location, to see visible objects for your next session, select them and save your list for later)*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/plan.jpg?raw=true "Plan your observation")


*Connect to the easyastro backend to pilot your telescope*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/server.png?raw=true "Pilot your telescope")

*Once connected, you can go back to your planned session and select objects to point the telescope to*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/goto.jpg?raw=true "Plan your observation")

*The software will plate solve the pictures and sync the telescope to be sure that the target is right in the center of the frame*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/gotoend.jpg?raw=true "Plan your observation")

*Choose exposition, move your scope to one of your target (the backend will platesolve to automatically sync your mount and center the object)*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/telescop2.png?raw=true "Pilot your telescope")

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/expogain.jpg?raw=true "Plan your observation")

*Change image processing*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/imageprocessing.jpg?raw=true "Process your image")


*The backend will stack your pictures to get an enhanced result*

![Alt text](https://github.com/air01a/EasyAstro/blob/main/doc/m97_stacking.png?raw=true "Live Stacking")
