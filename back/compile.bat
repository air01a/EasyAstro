call scripts\activate 
call pip install pyinstaller 
pyinstaller --noconfirm --onedir --console --icon "icons/app_icon.ico" --add-data "app/static;static/" --add-data "easyastro.conf;."  easyastro.py