#Print-Installer
Make it easy for your faculty to add and remove printer resources...  

Just put the Printer-Installer.app into the Applicatons folder and write the preference file 


###what you'll need  
1) a web server that can host the printers.plist file.  
2) use the printers-example.plist as a reference as what keys to use...


here are the avaliable keys to use for the printers in the printerList array
  
(required)  

	host		<-- ip address or fqdn
	model		<-- model name, use lpinfo -m to get the approperiate value
	printer 	<-- the name for the printer.  if connecting to a remote server, 
					this should be the name of the queue on the server
					no spaces, no caps,no strange characters, must start with a letter
	protocol	<--	currently avalable options are ipp, lpd, http, https, socket

(optional)

	ppd			<-- full path the the PPD file, this overrides the model option
	location	<-- location of the printer
	description	<-- alternative descripton for the user


once you have create your printer.plist,  
just drop it on your webserver where ever you like,  

then do on the client  

 	$ defaults write /Library/Preferences/edu.loyno.smc.Printer-Installer server http://path.to.your.serve/pathto/printers 
	
_*  notice don't put the .plist at the end of "printers"_