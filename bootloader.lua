settings.define("resoniteLink.altMode",{description="When true, disables auto-updates, disables local websocket connections, and redirects api requests through the websocket server.", default = false, type="boolean"})
settings.save()
local args = {...}
arg = args[1]
repeat
term.setTextColor(colors.cyan)
term.setBackgroundColor(colors.black)
if not settings.get("resoniteLink.altMode") then
	print("Checking for Updates...")
	local resoniteLink, err1 = http.get("https://raw.githubusercontent.com/catiotocat/craftos-ws-device/refs/heads/main/resoniteLink.lua")
	sleep(1)
	local bootloader, err2 = http.get("https://raw.githubusercontent.com/catiotocat/craftos-ws-device/refs/heads/main/bootloader.lua")
	-- pastebin run tUPXJMrn
	if resoniteLink then
		local rslnk = fs.open("resoniteLink.lua","r")
		if not rslnk then
			dat = ""
		else
			dat = rslnk.readAll()
			rslnk.close()
		end
		local rslnk = fs.open("resoniteLink.lua","w")
		new = resoniteLink.readAll()
		rslnk.write(new)
		rslnk.close()
		if dat ~= new then
			print("Program Updated!")
		end
	else
		printError("Program Update Error: "..err1)
	end



	if bootloader then
		local original = fs.open("bootloader.lua","r")
		local y = bootloader.readAll()
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
			shell.run("bootloader",arg)
			break
		end
	else
		printError("Bootloader Update Error: "..err2)
	end
else
	printError("Auto-Updates are disabled in alt mode")
end

	print("Running Program")
	sleep(1)
    shell.run("resoniteLink",arg)
    sleep(2)
until false
