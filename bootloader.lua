repeat

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

local args = {...}

arg = args[1]

if bootloader then
	local original = fs.open("bootloader.lua","r")
	local y = bootloader.readAll()
	x = y
	if original then
		local x = original.readAll()
		original.close()
	end
	local btld = fs.open("bootloader.lua","w")
	btld.write(y)
	btld.close()
	if x ~= y or not original then
		print("Bootloader Updated!")
		sleep(1)
		shell.run("bootloader",arg)
		break
	end
else
	printError("Bootloader Update Error: "..err2)
end


	print("Running Program")
	sleep(1)
    shell.run("resoniteLink",arg)
    sleep(2)
until false
