#Print-Installer
Make it easy for your faculty to add and remove printer resources...  
Just drop the Printer-Installer.app into the Applicatons


###what you'll need 

Either install [printer-installer-server](https://github.com/eahrold/printerinstaller-server "Printer-Installer-Server")  

or you can create plist files to store on a server
1) a web server that can host the printers xml file.  
2) use the printers-example.plist as a reference as what keys to use...


here are the avaliable keys to use for the printers in the printerList array
  
(required)  

	url  		<-- ip address or fqdn for the printer
	model		<-- model name, use lpinfo -m to get the approperiate value
	printer 	<-- the name for the printer.  if connecting to a remote server, 
					this should be the name of the queue on the server
					no spaces, no caps,no strange characters, must start with a letter
	protocol	<--	currently avalable options are ipp, lpd, http, https, socket

(optional)

	ppd			<-- a url where a PPD can be download from a web server.
	location	<-- location of the printer
	description	<-- alternative descripton for the user


once you have create your printer.plist, remove the .plist and drop it on your webserver where ever you like, 

###If you want to manage the Printer-Installer app you can do so by setting the 'manage' key to yes 

	$ defaults write /Library/Preferences/edu.loyno.smc.Printer-Installer managed -bool True 
	
	$ defaults write /Library/Preferences/edu.loyno.smc.Printer-Installer server http://path.to.your.serve/pathto/printers
	
