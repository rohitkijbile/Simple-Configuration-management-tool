# Simple configuration management tool

### Things to know before running tool (Prerequisites)
- Tool runs on debian based machines
- It is required to keep both "main.sh" and "config" file in the same folder.
- Need to create "/tmp/srv" folder on the machine where tool needs to be run and keep all the files there which needs to be copied , like configuration files etc.
- The tool follows idempotency, so it is safe to apply again and again.
```
mkdir -p /tmp/srv
```


### How to use
- Tool has two files, the main script with name "main.sh" and configuration file "config" where we define the actions to be performed.
- The configuration file has below format

```
file:
  name: /var/www/html/index.php
  user: root
  group: root
  perm: 644

package:
  name: apache2,php
  state: present

service:
  name: apache2
  status: start

copy:
  name: index.php
  dest: /var/www/html

Mods to use:
  package
  service
  copy
  file
```
Where "file","package","service","copy" are the names of the modules and they have the specific usage which is expalined in "Modules" section below. The second part of config file is "Mods to use" section where you can define the modules which needs to be executed in sequential order. e.g the above configuration will do first copy the file(knowing the fact that file to be copied present under "/tmp/srv" folder) to the destination and then changes its owner,group and permissions as set in the configuration above.

- once everything is in palce just run the main.sh script
```
chmod u+x main.sh
sh main.sh
```


### Modules

##### file
- The file module is used to make sure to have specified metadata of file in palce.
- file module has various parameters.
  - **name** this is *mandatory* filed which should have actual path of the file, you can provide multiple files to be checked using comma separation.
  - **user** this is the owner of file to be set.
  - **group** this is the group of the file to be set.
  - **perms** this is permissions of the file to be set.

##### Package
- The package module is used to install/uninstall softwares.
- package module has various parameters
  - **name** this is *mandatory* filed and can have multiple packages to be installed or uninstalled separated by comma.
  - **state** this is field can be either "present" in case we need to install the software or "absent" in case we need to uninstall software. If field kept blank the software will be uninstalled.

  ##### service
- The service module is used to manage services where in we can start,stop,restart the service.
- service module has various parameters
  - **name** this is *mandatory* filed and can have multiple services define with comma separation.
  - **status** this filed can be "start","stop" or "restart".

  ##### copy
  - The copy module used to copy the files from "/tmp/srv/" folder to the defined destinition.
  - copy module has various parameters
    - **name** this is *mandatory* field, it should have name of file and the file should be present under "/tmp/srv" which needs to be copied.
    - **dest** this is the location where we need to push the file.


##### Limitations.
- The file module can take multiple files but the metadata can be set same for all the files
- The service module takes multiple services but all services can have simillar action like "start" or "stop" at givin time.
- copy module supports single file copy.

##### Future scope
- The limitations which are mentioned above can be corrected.
- The whole tool currently works on the separate server(localhost) , but can be integrated with some dedicated server which can run this tool remotely on all the peer hosts where configuration needs to be maintained.


