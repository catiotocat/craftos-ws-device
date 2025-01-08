settings.define("resoniteLink.accessKey",{description="Access Key for the public server", default = "", type="string"})
settings.define("resoniteLink.websocketMode",{description="Defines which websocket server to connect to. (0): Tries local url first, then tries public. (1): Only connect to the local url. This does not affect the bootloader. (2): Only connect to the public url. This mode requires a valid access key to be set in resoniteLink.accessKey.",default = 0, type="number"})
settings.define("resoniteLink.altMode",{description="When true, redirects api requests through the websocket server. Only works if resoniteLink.websocketMode is set to 0 or 2. This also causes mode 0 to behave like mode 2.", default = false, type="boolean"})
settings.define("resoniteLink.allowUpdates",{description="Set to false to disable automatic updates when running bootloader.lua", default = true, type="boolean"})
settings.save()
local args = {...}
arg = args[1]
repeat
term.setTextColor(colors.cyan)
term.setBackgroundColor(colors.black)
if settings.get("resoniteLink.allowUpdates") then
	print("Checking for Updates...")
	print("Connecting to wss://catio.merith.xyz/ws/")
	local ws,err = http.websocket("wss://catio.merith.xyz/ws/")
	if not ws then 
		printError(err)
		print("Update Aborted")
	else
		sleep(.1)
		ws.send("bootloader.lua")
		rawDat = ws.receive()
		ws.close()
		local success,msg = pcall(textutils.unserializeJSON,rawDat)
		if not (success and msg)  then
			printError("Unusable Response from Server")
			print("Update Aborted")
		else
			local rslnk = fs.open("resoniteLink.lua","r")
			if not rslnk then
				dat = ""
			else
				dat = rslnk.readAll()
				rslnk.close()
			end
			local rslnk = fs.open("resoniteLink.lua","w")
			new = msg.resoniteLink
			rslnk.write(new)
			rslnk.close()
			if dat ~= new then
				print("Program Updated!")
			end

			local original = fs.open("bootloader.lua","r")
			local y = msg.bootloader
			local x = ""
			if original then
				x = original.readAll()
				original.close()
			end
			local btld = fs.open("bootloader.lua","w")
			btld.write(y)
			btld.close()
			if x ~= y then
				print("Bootloader Updated!")
				sleep(1)
				print("Executing New Bootloader...")
				sleep(1)
				shell.run("bootloader",arg)
				break
			end
		end
	end
else
	printError("Auto-Updates are disabled.")
end

	print("Running Program")
	sleep(1)
    shell.run("resoniteLink",arg)
    sleep(2)
until false
