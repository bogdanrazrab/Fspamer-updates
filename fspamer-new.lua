local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local ffi = require 'ffi'

local active = imgui.new.bool(false)
local spamText = imgui.new.char[256](u8"текст")
local delay = imgui.new.int(3)
local WinState = imgui.new.bool(false)

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
    
    if imgui.Begin("FSPAMER | Dev: Fier", WinState) then
        if imgui.InputText(u8"Текст", spamText, 256) then end
        if imgui.SliderInt(u8"Секунды", delay, 1, 60) then end
        if imgui.Button(active[0] and u8"Стоп" or u8"Начать", imgui.ImVec2(-1, 40)) then
            active[0] = not active[0]
        end
        imgui.End()
    end
end)

function main()
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Скрипт загружен. Автор: {3399FF}Fier", -1)
    sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Активация меню: {3399FF}/fpanel", -1)
    
    sampRegisterChatCommand("fpanel", function() 
        WinState[0] = not WinState[0] 
    end)
    
    while true do
        wait(0)
        imgui.ShowCursor = WinState[0]
        
        if active[0] then
            local text = u8:decode(ffi.string(spamText))
            if text ~= "" then
                sampSendChat(text)
            end
            wait(delay[0] * 1000)
        end
    end
end
