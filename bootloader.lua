print("Checking for Updates...")
local resoniteLink, err = http.get("https://raw.githubusercontent.com/catiotocat/craftos-ws-device/refs/heads/main/resoniteLink.lua")
sleep(1)
local bootloader, err = http.get("https://raw.githubusercontent.com/catiotocat/craftos-ws-device/refs/heads/main/bootloader.lua")
-- pastebin run tUPXJMrn
if resoniteLink then
	local rslnk = fs.open("resoniteLink.lua","r")
	dat = rslnk.readAll()
	rslnk.close()
	local rslnk = fs.open("resoniteLink.lua","w")
	new = resoniteLink.readAll()
	rslnk.write(new)
	rslnk.close()
	if dat ~= new then
		print("Program Updated!")
	end
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
	if x ~= y then
		print("Bootloader Updated!")
		shell.run("bootloader",arg)
		return
	end
end


repeat
	print("Running Program")
	sleep(1)
    shell.run("resoniteLink",arg)
    sleep(10)
until false
