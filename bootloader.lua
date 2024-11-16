print("Updating...")
local resoniteLink, err = http.get("https://raw.githubusercontent.com/catiotocat/craftos-ws-device/refs/heads/main/resoniteLink.lua")
sleep(1)
local bootloader, err = http.get("https://raw.githubusercontent.com/catiotocat/craftos-ws-device/refs/heads/main/bootloader.lua")
-- pastebin run tUPXJMrn
if resoniteLink then
	local rslnk = fs.open("resoniteLink.lua","w")
	rslnk.write(resoniteLink.readAll())
	rslnk.close()
end

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
		shell.run("bootloader")
		return end
	end
end



repeat
    shell.run("resoniteLink")
    sleep(10)
until false
