local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local ffi = require 'ffi'
local requests = require 'requests'

local current_version = 1.2
local url_version = "https://raw.githubusercontent.com/bogdanrazrab/Fspamer-updates/refs/heads/main/version.txt"
local url_script = "https://raw.githubusercontent.com/bogdanrazrab/Fspamer-updates/refs/heads/main/fspamer-new.lua"

local active = imgui.new.bool(false)
local spamText = imgui.new.char[256](u8"текст")
local delay = imgui.new.int(3)
local WinState = imgui.new.bool(false)

local UpdateWinState = imgui.new.bool(false)
local server_version_str = ""

imgui.OnFrame(function() return WinState[0] or UpdateWinState[0] end, function(player)
    if WinState[0] then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
        
        if imgui.Begin("FSPAMER | Dev: Fier", WinState) then
            if imgui.InputText(u8"Текст", spamText, 256) then end
            if imgui.SliderInt(u8"Секунды", delay, 1, 60) then end
            if imgui.Button(active[0] and u8"Стоп" or u8"Начать", imgui.ImVec2(-1, 40)) then
                active[0] = not active[0]
            end
            imgui.End()
        end
    end

    if UpdateWinState[0] then
        imgui.SetNextWindowSize(imgui.ImVec2(350, 140), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        
        if imgui.Begin(u8"Доступно обновление!", UpdateWinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            imgui.Text(u8"Доступна новая версия скрипта: v" .. server_version_str)
            imgui.Text(u8"Вы хотите обновиться прямо сейчас?")
            imgui.Separator()
            imgui.Spacing()
            
            if imgui.Button(u8"Да, обновить", imgui.ImVec2(140, 35)) then
                UpdateWinState[0] = false
                downloadUpdate()
            end
            imgui.SameLine(180)
            if imgui.Button(u8"Пропустить", imgui.ImVec2(140, 35)) then
                UpdateWinState[0] = false
                sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Обновление пропущено пользователем.", -1)
            end
            imgui.End()
        end
    end
end)

function checkUpdates()
    lua_thread.create(function()
        wait(1000)
        local status, response = pcall(requests.get, url_version)
        if status and response.status_code == 200 then
            local server_version = tonumber(response.text:match("^%s*(.-)%s*$"))
            if server_version and server_version > current_version then
                server_version_str = tostring(server_version)
                UpdateWinState[0] = true
                WinState[0] = true
            end
        end
    end)
end

function downloadUpdate()
    lua_thread.create(function()
        sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Скачивание новой версии...", -1)
        local script_status, script_response = pcall(requests.get, url_script)
        if script_status and script_response.status_code == 200 then
            local file = io.open(thisScript().path, "wb")
            if file then
                file:write(script_response.text)
                file:close()
                sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Скрипт успешно обновлен! Перезагрузка...", -1)
                thisScript():reload()
            else
                sampAddChatMessage("{FF3333}[FSPAMER]{FFFFFF} Ошибка: не удалось открыть локальный файл для записи.", -1)
            end
        else
            sampAddChatMessage("{FF3333}[FSPAMER]{FFFFFF} Ошибка при скачивании файла обновления с сервера.", -1)
        end
    end)
end

function main()
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Скрипт загружен. Автор: {3399FF}Fier", -1)
    sampAddChatMessage("{3399FF}[FSPAMER]{FFFFFF} Активация меню: {3399FF}/fpanel", -1)
    
    checkUpdates()
    
    sampRegisterChatCommand("fpanel", function() 
        WinState[0] = not WinState[0] 
    end)
    
    while true do
        wait(0)
        imgui.ShowCursor = WinState[0] or UpdateWinState[0]
        
        if active[0] then
            local text = u8:decode(ffi.string(spamText))
            if text ~= "" then
                sampSendChat(text)
            end
            wait(delay[0] * 1000)
        end
    end
end
