##Static Printer List Server
If you don't have a server that can host Django webapps you can create static plist files to store on a server  

Use the printers-example.plist as a reference as what keys to use...

These are the available keys to use for the printers in the printerList array
  
(required)  

	url  		<-- ip address or fqdn for the printer
	model		<-- model name, use lpinfo -m to get the approperiate name string
	printer 	<-- the name for the printer.  if connecting to a remote server, 
					this should be the name of the queue on the server
					no spaces, no caps,no strange characters, must start with a letter
	protocol	<--	currently avalable options are ipp, lpd, http, https, socket

(optional)

	ppd			<-- a url where a PPD can be download from a web server.
	location	<-- location of the printer
	description	<-- alternative descripton for the user


once you have create your printer.plist, remove the .plist and drop it on your webserver where ever you like, 

###To configure the printer-installer.app 
```
$ defaults write /Library/Preferences/edu.loyno.smc.Printer-Installer server http://path.to.your.serve/pathto/printers
```
###If you want to manage the Printer-Installer app you can do so by setting the 'manage' key to yes 

	$ defaults write /Library/Preferences/edu.loyno.smc.Printer-Installer managed -bool True 
	
	
