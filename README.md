#Spigot docker image
this is a spigot docker image. it's far from finished but I'm working on it. 
It features automatic plugin install, spigot updating and cloud saving. 

# variables


```sh
# Set up the cloud folder for your data
USERNAME
PASSWORD

MCNAME # Minecraft username that gets op by default
MCPLUGINS # space seperated list of plugins to install
MCMOTD # Description displayed in server browser
MCMEMORY # amount of memory to be used spigot
# example: 1000m

DROPTOKEN # Set this to an auth token for your dropbox to sync with it

# Set this to email and auth for a mega.nz account to sync with it
MEGAMAIL
MEGAHASH
```
