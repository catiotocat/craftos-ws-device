local gateColor = colors.cyan
term.setTextColor(gateColor)
local xsize,ysize = term.getSize()
addrBK = {}
buttonPOS = {refresh=1}
monitorActive = false
monitorMode = "IDLE"
local ws, err = http.websocket("ws://catio-Q551LB:8001")
if not ws then 
    printError(err) 
    return
    -- ws = {send = function() end}
end
-- pastebin get bkdkje8x resoniteLink.lua
typeCode = "#@"
gateAddr = "INVALIDGATE"
targetAddr = ""
idcCode = ""
payloadAddr = ""
payloadData = ""
term.setPaletteColor(colors.green,0x00FF00)
term.setPaletteColor(colors.red,0xFF0000)
term.setPaletteColor(colors.yellow,0xFFFF00)
term.setPaletteColor(colors.white,0xFFFFFF)
term.setPaletteColor(colors.black,0x000000)

function writeADDR(addr,type,headless,open,iris,id)
    term.setCursorPos(xsize-10,id)
    if addr == gateAddr then
        term.setBackgroundColor(colors.yellow)
    elseif headless then
        term.setBackgroundColor(colors.green)
    else
        term.setBackgroundColor(colors.red)
    end
    write(" ")
    term.setBackgroundColor(colors.black)
    term.setTextColor(gateColor)
    write(addr)
    term.setTextColor(colors.green)
    term.setBackgroundColor(colors.black)
    write(type)
    if iris and open then
        term.setBackgroundColor(colors.red)
    elseif open then
        term.setBackgroundColor(colors.green)
    else
        term.setBackgroundColor(colors.black)
    end
    write(" ")
end
	
function parseAPI(json)
    term.setCursorPos(xsize-10,1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(gateColor)
	write("GATE LIST ")
    for i=2,ysize do
        term.setCursorPos(xsize-10,i)
        write(string.rep(" ",10))
    end   
	term.setBackgroundColor(gateColor)
	for i=1,ysize do
        term.setCursorPos(xsize,i)
        write(" ")
    end 
    addrBK = {}
    local x = textutils.unserializeJSON(json.readAll())
    if not x then return end
    for i=1,#x do
        local y = x[i]
        table.insert(addrBK,y.gate_address..y.gate_code)
        local isOpen = y.gate_status == "OPEN"
        writeADDR(y.gate_address,y.gate_code,y.is_headless,isOpen,y.iris_state,i+1)
    end
end

function parseWS(json)
    local x, err = textutils.unserializeJSON(json)
    if not x then return end
	if x.user == "websocket" then 
		typeCode = ""
		gateAddr = ""
		payloadAddr = ""
		payloadData = ""
		term.setBackgroundColor(colors.black)
		for i=1,ysize-3 do
			term.setCursorPos(1,i)
			write(string.rep(" ",xsize-11))
		end
		term.setTextColor(colors.red)
		term.setCursorPos(1,1)
		write("ERROR 1")
		term.setCursorPos(1,2)
		write("Headless is Offline!")
		buttonPOS = {refresh=1}
		term.setPaletteColor(gateColor,term.nativePaletteColor(gateColor))
	end
    if x.user ~= "catio headless" then return end
    term.setPaletteColor(gateColor,tonumber(x.gateCOL,16))
	if not x.addr then return end
	if x.addr == "" then
		typeCode = ""
		gateAddr = ""
		payloadAddr = ""
		payloadData = ""
		term.setBackgroundColor(colors.black)
		for i=1,ysize-3 do
			term.setCursorPos(1,i)
			write(string.rep(" ",xsize-11))
		end
		term.setTextColor(colors.red)
		term.setCursorPos(1,1)
		write("ERROR 2")
		term.setCursorPos(1,2)
		write("Stargate not Ready!")
		buttonPOS = {refresh=1}
		return
	end
	typeCode = x.group
	gateAddr = x.addr
	targetAddr = x.target
	idcCode = x.idcCODE
	payloadAddr = x.payloadAddr
	payloadData = x.payloadData
    term.setTextColor(gateColor)
    term.setBackgroundColor(colors.black)
    for i=1,ysize-3 do
        term.setCursorPos(1,i)
        write(string.rep(" ",xsize-11))
    end
    local currenty = 1
    if x.irisPresent then
        term.setCursorPos(1,currenty)
        term.setTextColor(colors.black)
        term.setBackgroundColor(gateColor)
        term.write("IRIS CONTROLS")
        term.setTextColor(gateColor)
        term.setBackgroundColor(colors.black)
        currenty = currenty+1
        
        term.setCursorPos(1,currenty)
        term.write("IDC ENABLE ")
        if x.idcEN then
            term.setBackgroundColor(colors.green)
        else
            term.setBackgroundColor(colors.red)
        end
        write(" ")
        term.setBackgroundColor(colors.black)
        buttonPOS.idcEN = currenty
        currenty = currenty+1
        
        term.setCursorPos(1,currenty)
        term.write("CODE: "..x.idcCODE)
        buttonPOS.idcCODE = currenty
        currenty = currenty+1
        
        term.setCursorPos(1,currenty)
        write("TOGGLE IRIS ")
        if x.irisClose then
            term.setBackgroundColor(colors.red)
        else
            term.setBackgroundColor(colors.green)
        end
        write(" ")
        term.setBackgroundColor(colors.black)
        buttonPOS.iris = currenty
        currenty = currenty+1
    else
        buttonPOS.iris = nil
        buttonPOS.idcCODE = nil
        buttonPOS.idcEN = nil
    end
    term.setCursorPos(1,currenty)
    
    term.setTextColor(colors.black)
    term.setBackgroundColor(gateColor)
    write("STARGATE CONTROLS")
    term.setTextColor(gateColor)
    term.setBackgroundColor(colors.black)
    currenty=currenty+1
    
    term.setCursorPos(1,currenty)
    write("TARGET ADDR: "..string.sub(x.target,1,6))
	term.setTextColor(colors.green)
	write(string.sub(x.target,7,-1))
	term.setTextColor(gateColor)
    buttonPOS.addr = currenty
    currenty = currenty+1
    
    if not x.active then
        term.setCursorPos(1,currenty)
        write("DIAL NORMALLY")
        buttonPOS.dialNORM = currenty
        currenty = currenty+1
        
        if x.group == "M@" then
            term.setCursorPos(1,currenty)
            write("DIAL QUICKLY")
            buttonPOS.dialFAST = currenty
            currenty = currenty+1
        else
            buttonPOS.dialFAST = nil
        end
        
        term.setCursorPos(1,currenty)
        write("DIAL INSTANTLY")
        buttonPOS.dialINST = currenty
        currenty = currenty+1
    else
        buttonPOS.dialNORM = nil
        buttonPOS.dialFAST = nil
        buttonPOS.dialINST = nil
    end
    if x.closeable then
        term.setCursorPos(1,currenty)
        write("CLOSE WORMHOLE")
        buttonPOS.closeWH = currenty
        currenty = currenty+1
    else
        buttonPOS.closeWH = nil
    end
    if x.cancelable then
        term.setCursorPos(1,currenty)
        write("CANCEL DIAL")
        buttonPOS.cancel = currenty
        currenty = currenty+1
    else
        buttonPOS.cancel = nil
    end
    if x.gdo then
        term.setCursorPos(1,currenty)
        write("SEND GDO CODE")
        buttonPOS.gdo = currenty
        currenty = currenty+1
    else
        buttonPOS.gdo = nil
    end
	
	term.setCursorPos(1,currenty)
    term.setTextColor(colors.black)
    term.setBackgroundColor(gateColor)
    write("IDC PAYLOAD UNIT")
    term.setTextColor(gateColor)
    term.setBackgroundColor(colors.black)
    currenty = currenty+1
	
	term.setCursorPos(1,currenty)
    write("TARGET ADDR: "..string.sub(x.payloadAddr,1,6))
    term.setTextColor(colors.green)
	write(string.sub(x.payloadAddr,7,8))
    term.setTextColor(gateColor)
	buttonPOS.payloadAddr = currenty
    currenty = currenty+1
	
	term.setCursorPos(1,currenty)
    write("PAYLOAD DAT: "..string.sub(x.payloadData,1,6))
    term.setTextColor(colors.green)
	write(string.sub(x.payloadData,7,8))
    term.setTextColor(gateColor)
	buttonPOS.payloadData = currenty
    currenty = currenty+1
	
	if not x.active then
		term.setCursorPos(1,currenty)
		write("SEND PAYLOAD")
		term.setTextColor(gateColor)
		buttonPOS.sendPayload = currenty
		currenty = currenty+1
	else
		buttonPOS.sendPayload = nil
	end
	
    term.setCursorPos(1,currenty)
    term.setTextColor(colors.black)
    term.setBackgroundColor(gateColor)
    write("GATE INFORMATION")
    term.setTextColor(gateColor)
    term.setBackgroundColor(colors.black)
    currenty = currenty+1
    term.setCursorPos(1,currenty)
    write("GATE ADDRESS: "..x.addr)
    term.setTextColor(colors.green)
	write(x.group)
    term.setTextColor(gateColor)
    currenty = currenty+1
	if x.dialedAddr ~= "" then
		term.setCursorPos(1,currenty)
		write("DIALED ADDR: "..string.sub(x.dialedAddr,1,6))
		term.setTextColor(colors.green)
		write(string.sub(x.dialedAddr,7,-1))
		term.setTextColor(gateColor)
		currenty = currenty+1
	end
end

function sendCMD(id,param)
    out = "-"
    if type(param)=="boolean" then
        if param then 
            out = "T"
        else
            out = "F"
        end
    elseif param then
        out = param
    end
    ws.send(id..out)
end

function parseButton(name,id)
    if buttonPOS[name] then
        if buttonPOS[name]==id then
            return true
        else
            return false
        end
    else
        return false
    end
end
monitorText = ""
monitor = window.create(term.current(),1,ysize-2,xsize-11,3)
function spawnMonitor(mode)
    monitorActive = true
    monitorMode = mode
    monitorText = ""
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(gateColor)
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor.setCursorBlink(true)
    if mode == "IDC" then
        monitor.write("ENTER NEW IDC CODE")
		monitorText = idcCode
    elseif mode == "ADDR" then
        monitor.write("ENTER NEW TARGET ADDRESS")
		monitorText = targetAddr
	elseif mode == "TARGET" then
		monitor.write("ENTER NEW PAYLOAD TARGET")
		monitorText = payloadAddr
	elseif mode == "PAYLOAD" then
		monitor.write("ENTER NEW PAYLOAD DATA")
		monitorText = payloadData
    elseif mode == "GDO" then
        monitor.write("ENTER GDO CODE TO SEND")
    end
    monitor.setCursorPos(1,3)
    monitor.write("ENTER - CONFIRM  ")
    monitor.write("DELETE - CANCEL")
    monitor.setCursorPos(1,2)
	if monitorMode ~= "ADDR" and monitorMode ~= "TARGET" and monitorMode ~= "PAYLOAD" then
		monitor.write(monitorText)
	else
		monitor.write(string.sub(monitorText,1,6))
		monitor.setTextColor(colors.green)
		monitor.write(string.sub(monitorText,7,-1))
		monitor.setTextColor(gateColor)
	end
end

function redrawMonitor()
    if not monitorActive then return end
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(gateColor)
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor = window.create(term.current(),1,ysize-2,xsize-11,3)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(gateColor)
    if monitorMode == "IDC" then
        monitor.write("ENTER NEW IDC CODE")
    elseif monitorMode == "ADDR" then
        monitor.write("ENTER NEW TARGET ADDRESS")
	elseif monitorMode == "TARGET" then
		monitor.write("ENTER NEW PAYLOAD TARGET")
	elseif monitorMode == "PAYLOAD" then
		monitor.write("ENTER NEW PAYLOAD DATA")
    elseif monitorMode == "GDO" then
        monitor.write("ENTER GDO CODE TO SEND")
    end
    monitor.setCursorPos(1,3)
    monitor.write("ENTER - CONFIRM  ")
    monitor.write("DELETE - CANCEL")
    monitor.setCursorPos(1,2) 
	if monitorMode ~= "ADDR" and monitorMode ~= "TARGET" and monitorMode ~= "PAYLOAD" then
		monitor.write(monitorText)
	else
		monitor.write(string.sub(monitorText,1,6))
		monitor.setTextColor(colors.green)
		monitor.write(string.sub(monitorText,7,-1))
		monitor.setTextColor(gateColor)
	end
end

function keyParse(key)
    if not monitorActive then return end
    -- monitor = peripheral.wrap("top")
    if key == keys.enter then
        if monitorMode == "IDC" then
            sendCMD("B",monitorText)
        elseif monitorMode == "ADDR" then
            sendCMD("A",monitorText)
		elseif monitorMode == "TARGET" then
			sendCMD("D",monitorText)
		elseif monitorMode == "PAYLOAD" then
			sendCMD("E",monitorText)
        elseif monitorMode == "GDO" then
            sendCMD("C",monitorText)
        end
        monitorActive = false
        -- periphemu.remove("top")
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    elseif key == keys.delete then
        monitorActive = false
		monitor.clear()
        monitor.setCursorBlink(false)
    elseif key == keys.backspace and #monitorText ~= 0 then
        monitorText = string.sub(monitorText,1,-2)
        if (monitorMode == "ADDR" or monitorMode == "TARGET" or monitorMode == "PAYLOAD") and #monitorText ~= 8 then
            monitor.setCursorBlink(true)
        end
        redrawMonitor()
    end
end

local validGlyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@*"
function charParse(key)
    if not monitorActive then return end
    -- monitor = peripheral.wrap("top")
    if monitorMode == "ADDR" or monitorMode == "TARGET" or monitorMode == "PAYLOAD" then
        raw = string.upper(key)
        if #monitorText >= 8 then return end
		if raw == "%" or raw == "." or raw == "[" or raw == "(" then return end
        if string.find(monitorText,raw) or not string.find(validGlyphs,raw) then return end
        monitorText = monitorText..raw
    else
        monitorText = monitorText..key
    end
    if monitorMode == "ADDR" and #monitorText == 8 then
        monitor.setCursorBlink(false)
    end
    redrawMonitor()
end

function mouseHandle(x,y)
    if monitorActive then return end
    if x < xsize-10 then
        if parseButton("idcEN",y) then
            sendCMD("7") -- toggle idc
        elseif parseButton("idcCODE",y) then
            spawnMonitor("IDC")
        elseif parseButton("iris",y) then
            sendCMD("4")
        elseif parseButton("addr",y) then
            spawnMonitor("ADDR")
        elseif parseButton("refresh",y) then
            sendCMD("0")
        elseif parseButton("dialNORM",y) then
            sendCMD("1")
        elseif parseButton("dialFAST",y) then
            sendCMD("2")
        elseif parseButton("dialINST",y) then
            sendCMD("3")
        elseif parseButton("closeWH",y) then
            sendCMD("5")
        elseif parseButton("cancel",y) then
            sendCMD("6")
        elseif parseButton("gdo",y) then
            spawnMonitor("GDO")
        elseif parseButton("payloadAddr",y) then
			spawnMonitor("TARGET")
		elseif parseButton("payloadData",y) then
			spawnMonitor("PAYLOAD")
		elseif parseButton("sendPayload",y) then
			sendCMD("8")
		end
    else
        if y < 2 then
            http.request("https://api.rxserver.net/stargates")
            return 
        end
        local addr = addrBK[y-1]
        if addr then
			if string.sub(addr,7,8) == typeCode then
				sendCMD("A",string.sub(addr,1,6))
			else
				sendCMD("A",string.sub(addr,1,7))
			end
        end
    end
end
running = true
-- sendCMD("0") -- query
http.request("https://api.rxserver.net/stargates")
os.startTimer(30)
while running do
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(gateColor)
    monitor.setCursorPos(#monitorText+1,2)
    monitor.setCursorBlink(monitorActive and not ((monitorMode == "ADDR" or monitorMode == "TARGET" or monitorMode == "PAYLOAD") and #monitorText == 8))
    dat = {os.pullEventRaw()}
    xsize2,ysize2 = term.getSize()
    if xsize ~= xsize2 or ysize ~= ysize2 then
		term.clear()
        xsize = xsize2
        ysize = ysize2
        sendCMD("0")
        http.request("https://api.rxserver.net/stargates")
    end
    redrawMonitor()
    if dat[1] == "websocket_message" then
        parseWS(dat[3])
    elseif dat[1]=="http_success" then
        parseAPI(dat[3])
    elseif dat[1]=="mouse_click" and not monitorActive then
        mouseHandle(dat[3],dat[4])
    elseif dat[1]=="timer" then
        http.request("https://api.rxserver.net/stargates")
        os.startTimer(30)
    elseif dat[1]=="key" and monitorActive then
        keyParse(dat[2])
    elseif dat[1]=="char" and monitorActive then
        charParse(dat[2])
    elseif dat[1]=="websocket_closed" or dat[1]=="terminate" then
        running = false
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        term.setPaletteColor(gateColor,term.nativePaletteColor(gateColor))
		term.setPaletteColor(colors.green,term.nativePaletteColor(colors.green))
		term.setPaletteColor(colors.red,term.nativePaletteColor(colors.red))
		term.setPaletteColor(colors.yellow,term.nativePaletteColor(colors.yellow))
		term.setPaletteColor(colors.white,term.nativePaletteColor(colors.white))
		term.setPaletteColor(colors.black,term.nativePaletteColor(colors.black))
		if dat[1]=="terminate" then
			ws.close()
			printError("Terminated")
		else
			printError("Connection Closed")
		end
	end
end

-- Commands will all be given unique 1 character ids
-- COMMAND 0 = query, no param, ex "0-"
-- COMMAND 1 = dialNORM, no param, ex "1-"
-- COMMAND 2 = dialFAST, no param, ex "2-"
-- COMMAND 3 = dialINST, no param, ex "3-"
-- COMMAND 4 = toggleIRIS, no param, ex "4-"
-- COMMAND 5 = closeWORMHOLE, no param, ex "5-"
-- COMMAND 6 = cancelDIAL, no param, ex "6-"
-- COMMAND 7 = toggleIDC, no param, ex "7-"
-- COMMAND A = setADDR, string, ex "ATI057SU"
-- COMMAND B = setIDC, string, ex "B3332341"
-- COMMAND C = sendGDO, string, ex "C1994"

-- Resonite websocket message data (formatted in json)
-- user = host username ("catio headless")
-- addr = gate address ("CATIOH")
-- group = type code ("M@")
-- dialedAddr = dialed address
-- idcCODE = idc code
-- target = dhd address field
-- gateCOL = hex rgb string defining the current gate color. Returns "FFFFFF" if gate is idle.

-- idcEN = idc enabled state
-- irisPresent = iris control 
-- active = stargate active (true if dial buttons are NOT visible)
-- irisClose = iris state
-- closeable = close wormhole button visible
-- cancelable = cancel dialing button visible
-- gdo = gdo enabled state

--[[

Whenever the address or idc feilds change, send a command containing the new value
gdo button sends the entered gdo code through the websocket

buttons on the dialer will also send ws messages

Additional data will be added:

incoming
locked

both straight from the stargate's variables


--]]
