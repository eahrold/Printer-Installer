#Print-Installer
#####_Make it easy for your users to add and remove printers._

---
---

__There__ are a number of common issues when a large number of users need undetermined access to a large number printers. First of all, adding printers to unmanaged computers, such as student's personal machines, can be a pain.  Normally it requires either an elaborate walk through that talks about server IP addresses and protocols, or some sort of script which adds all the avalible printers for the instution, making much clutter in the users printer dialog.  
 
__Printer-Insaller__ trys to address these.  It lives quietly in the menu bar and provides a simple list of printers users may want to add/remove.  The administer configures the list on a web server, and the users automatically see which printers are avaliable to them.

__In__ addition if you need to change the IP or protocol of any printer a user has previously added, just update the information on the server and Printer-Insatller checks for those changes and updates the installed printer's uri on the client accordingly.

![pi-menu]

![pi-config]

###All you need is a web server...

The easiest way to serve and manage the printer lists is by using the [Printer-Installer Server](https://github.com/eahrold/printerinstaller-server "Printer-Installer-Server") django webapp.  If you have a machine running OS X Server 10.7 or greater it the server component can be installed by copy and pasting this command into a terminal window.

```
curl -L https://raw.github.com/eahrold/printerinstaller-server/master/OSX/osx_auto_install.command > /tmp/run.sh; chmod u+x /tmp/run.sh ; /tmp/run.sh
```

However, even if you don't have the ability to install webapps onto a server you can also just place static plist files in any hosted folder following [this walk through][static-plist].   

---
---

[pi-menu]:./docs/images/pi-menu.png
[pi-config]:./docs/images/pi-config.png
[static-plist]:./docs/static-plist.md
