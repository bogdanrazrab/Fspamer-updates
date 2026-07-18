local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local ffi = require 'ffi'
local requests = require 'requests'

local current_version = 1.4
local url_version = "https://raw.githubusercontent.com/bogdanrazrab/Fspamer-updates/refs/heads/main/version.txt"
local url_script = "https://raw.githubusercontent.com/bogdanrazrab/Fspamer-updates/refs/heads/main/fspamer-new.lua"

local active = imgui.new.bool(false)
local spamText = imgui.new.char[256](u8"текст")
local delay = imgui.new.int(3) 
local WinState = imgui.new.bool(false)

local UpdateWinState = imgui.new.bool(false)
local server_version_str = ""

local function applyRedStyle()
    local style = imgui.GetStyle()
    local colors = style.Colors
    
    style.WindowRounding = 6.0
    style.FrameRounding = 4.0
    
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.13, 0.10, 0.10, 1.00)
    colors[imgui.Col.Header] = imgui.ImVec4(0.70, 0.15, 0.15, 0.80)
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.85, 0.20, 0.20, 0.90)
    colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.95, 0.25, 0.25, 1.00)
    
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.50, 0.10, 0.10, 1.00)
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.70, 0.12, 0.12, 1.00)
    
    colors[imgui.Col.Button] = imgui.ImVec4(0.65, 0.12, 0.12, 1.00)
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.80, 0.18, 0.18, 1.00)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.95, 0.25, 0.25, 1.00)
    
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.22, 0.15, 0.15, 1.00)
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.30, 0.18, 0.18, 1.00)
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.40, 0.22, 0.22, 1.00)
    
    colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.75, 0.15, 0.15, 1.00)
    colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.95, 0.25, 0.25, 1.00)
    
    colors[imgui.Col.CheckMark] = imgui.ImVec4(0.90, 0.15, 0.15, 1.00)
end

local styleInitialized = false

imgui.OnFrame(function() return WinState[0] or UpdateWinState[0] end, function(player)
    if not styleInitialized then
        applyRedStyle()
        styleInitialized = true
    end

    if WinState[0] then
        imgui.SetNextWindowSize(imgui.ImVec2(550, 280), imgui.Cond.FirstUseEver)
        
        if imgui.Begin("FSPAMER | Dev: Fier", WinState) then
            imgui.PushItemWidth(-1)
            imgui.Text(u8"Введите текст для спама:")
            if imgui.InputText("##SpamText", spamText, 256) then end
            
            imgui.Spacing()
            imgui.Text(u8"Задержка (в секундах):")
            if imgui.SliderInt("##DelaySeconds", delay, 1, 60) then end
            imgui.PopItemWidth()
            
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 20)
            
            local btnText = active[0] and u8"Остановить спам" or u8"Начать спам"
            if imgui.Button(btnText, imgui.ImVec2(-1, 50)) then
                active[0] = not active[0]
            end
            imgui.End()
        end
    end

    if UpdateWinState[0] then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 160), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        
        if imgui.Begin(u8"Доступно обновление!", UpdateWinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            imgui.Text(u8"Доступна новая версия скрипта: v" .. server_version_str)
            imgui.Text(u8"Вы хотите обновиться сейчас?")
            imgui.Separator()
            imgui.Spacing()
            
            if imgui.Button(u8"Да, обновить", imgui.ImVec2(160, 40)) then
                UpdateWinState[0] = false
                downloadUpdate()
            end
            imgui.SameLine(220)
            if imgui.Button(u8"Пропустить", imgui.ImVec2(160, 40)) then
                UpdateWinState[0] = false
                sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Обновление пропущено пользователем.", -1)
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
        sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Скачивание новой версии...", -1)
        local script_status, script_response = pcall(requests.get, url_script)
        if script_status and script_response.status_code == 200 then
            local file = io.open(thisScript().path, "wb")
            if file then
                file:write(script_response.text)
                file:close()
                sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Скрипт успешно обновлен! Перезагрузка...", -1)
                thisScript():reload()
            else
                sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Ошибка: не удалось открыть локальный файл для записи.", -1)
            end
        else
            sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Ошибка при скачивании файла обновления с сервера.", -1)
        end
    end)
end

function runSpammer()
    lua_thread.create(function()
        while true do
            wait(0)
            if active[0] then
                local text = u8:decode(ffi.string(spamText))
                if text ~= "" then
                    sampSendChat(text)
                end
                wait(delay[0] * 1000)
            end
        end
    end)
end

function main()
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Скрипт загружен. Автор: {FF3333}Fizer", -1)
    sampAddChatMessage("{FF3333}[FiFlooder]{FFFFFF} Активация меню: {FF3333}/fpanel", -1)
    
    checkUpdates()
    runSpammer()
    
    sampRegisterChatCommand("fpanel", function() 
        WinState[0] = not WinState[0] 
    end)
    
    while true do
        wait(0)
        imgui.ShowCursor = WinState[0] or UpdateWinState[0]
    end
end
