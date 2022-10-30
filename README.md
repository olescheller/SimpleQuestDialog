# SimpleQuestDialog
Source code of the WoW interface addon SimpleQuestDialog.

## Description
Minimalstic addon that makes quest dialogs easier to navigate.

## Development
The `src` directory contains all required addon code (lua, toc, optional textures, etc). All addon code is kept there to ease the process of publishing the addon and not interfering with other files in the repository. The script `scripts\build.ps1` is used to create the shippable zip file. For live development, launch the script `.\develop.ps1` to deploy the addon to the base folder of this repository for convenience (requires [nodemon](https://www.npmjs.com/package/nodemon)).
