# Project Ozone 3 A New Way Forward Server

Container with the purpose to run PO3(version PO3-3.4.11F) on UnRaid. 

[CurseForge - Project Ozone 3 A New Way Forward](https://www.curseforge.com/minecraft/modpacks/project-ozone-3-a-new-way-forward)  
[CurseForge - This server file version: PO3-3.4.11Fserver](https://www.curseforge.com/minecraft/modpacks/project-ozone-3-a-new-way-forward/files/4345112)  


## Usage in Unraid

When setting up your container in Unraid, you must configure a few key settings:

- **Environment Variables:**  
  Configure the following environment variables:
  - **EULA**: Set to `true` to accept the Minecraft EULA.
  - **LEVEL_TYPE**: (Optional) Set to `SKYLANDS`(default), `botania-skyblock` or `lostcities`.
  - **MOTD**: (Optional) Server message of the day.
  - **ENABLE_WHITELIST**: (Optional) Set to `true` or `false` to enable/disable whitelist support.
  - **ALLOW_FLIGHT**: (Optional) Set to `true` or `false` to allow flight.
  - **MAX_PLAYERS**: (Optional) Maximum number of players allowed.
  - **ONLINE_MODE**: (Optional) Set to `true` or `false` to enforce online mode.
  - **WHITELIST_USERS**: (Optional) Comma-separated list of usernames to whitelist.
  - **OP_USERS**: (Optional) Comma-separated list of usernames to add as operators.
  - **JVM_OPTS**: (Optional) Additional Java options (e.g., `-Xms2048m -Xmx6144m`).

- **Data Volume Mapping:**  
  The Dockerfile sets the working directory (and volume) to `/data`.  
  **Map `/data` to a persistent directory on Unraid**, for example:  
  `/mnt/user/appdata/minecraft-po3/`  
  This ensures your server data is persisted across container restarts.

- **Port Mapping:**  
  The container exposes port `25565` (the default Minecraft server port).  
  **Map port `25565` (or port of your choice) on your Unraid host to port `25565` in the container** so that you can connect to the server.


