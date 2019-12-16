# GameUpdater
A simple Just Enough Administration to enable regular users to update (run exe-files) games as admin.


This script enables PSRemoting and adds 'Authenticated Users' with Read+Execute on the created configuration. This enables users without rights to run the executables added to the list of VisibleExternalCommands as admin.


To use run example.ps1 as admin, it will allow logged on users to run the BattleEye updater that comes with Fortnite.
