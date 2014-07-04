#Print-Installer
Make it easy for your users to add and remove printers.  
Just drop the app into applications folder.

![pi-menu]

![pi-config]

###What you'll need 

The easiest way to serve and manage the printer lists is by using the [Printer-Installer Server](https://github.com/eahrold/printerinstaller-server "Printer-Installer-Server") django webapp.  If you have a machine running OS X Server 10.7 or greater it the server component can be installed by copy and pasting this command into a terminal window.
```
curl -L https://raw.github.com/eahrold/printerinstaller-server/master/OSX/osx_auto_install.command > /tmp/run.sh; chmod u+x /tmp/run.sh ; /tmp/run.sh

```

However, even if you don't have the ability to install webapps onto a server you can also just place static plist files in any hosted folder following [this walk through][static-plist].  

	

[pi-menu]:./docs/images/pi-menu.png
[pi-config]:./docs/images/pi-config.png
[static-plist]:./docs/static-plist.md
