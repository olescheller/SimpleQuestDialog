# SimpleQuestDialog
A World of Warcraft addon that makes quest dialogs easier to navigate.

## Development
The directory `src` contains all required addon code files (lua, toc, optional textures, etc). The script `scripts\build.ps1` is used to create the shippable zip file. The script `scripts\dev-deploy.ps1` is used to deploy the addon to the base folder of this repository for convenience. That way we can clone this repository to `Interface\AddOns` and live test changes to the addon with a running WoW client. Launch the script `.\develop.ps1` to start live developing.
