local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local ffi = require 'ffi'
local requests = require 'requests'

local current_version = 1.5
local url_version = "https://raw.githubusercontent.com/bogdanrazrab/Fspamer-updates/refs/heads/main/version.txt"
local url_script = "https://raw.githubusercontent.com/bogdanrazrab/Fspamer-updates/refs/heads/main/fspamer-new.lua"

local active = imgui.new.bool(false)
local spamText = imgui.new.char[256](u8"текст")
local delay = imgui.new.int(3) 
local WinState = imgui.new.bool(false)

local UpdateWinState = imgui.new.bool(false)
local server_version_str = ""

local color_items = {u8"Красный", u8"Розовый", u8"Синий", u8"Голубой", u8"Черный", u8"Серый"}
local currentColor = imgui.new.int(0)

local function applyCustomStyle(themeIndex)
    local style = imgui.GetStyle()
    local colors = style.Colors
    
    style.WindowRounding = 6.0
    style.FrameRounding = 4.0
    
    local bg = imgui.ImVec4(0.13, 0.10, 0.10, 1.00)
    local frame = imgui.ImVec4(0.22, 0.15, 0.15, 1.00)
    local frameHov = imgui.ImVec4(0.30, 0.18, 0.18, 1.00)
    local frameAct = imgui.ImVec4(0.40, 0.22, 0.22, 1.00)
    
    local main = imgui.ImVec4(0.70, 0.15, 0.15, 0.80)
    local hover = imgui.ImVec4(0.85, 0.20, 0.20, 0.90)
    local activeColor = imgui.ImVec4(0.95, 0.25, 0.25, 1.00)
    
    if themeIndex[0] == 0 then
        bg = imgui.ImVec4(0.13, 0.10, 0.10, 1.00)
        main = imgui.ImVec4(0.70, 0.15, 0.15, 0.80)
        hover = imgui.ImVec4(0.85, 0.20, 0.20, 0.90)
        activeColor = imgui.ImVec4(0.95, 0.25, 0.25, 1.00)
        frame = imgui.ImVec4(0.22, 0.15, 0.15, 1.00)
        frameHov = imgui.ImVec4(0.30, 0.18, 0.18, 1.00)
        frameAct = imgui.ImVec4(0.40, 0.22, 0.22, 1.00)
    elseif themeIndex[0] == 1 then
        bg = imgui.ImVec4(0.14, 0.09, 0.12, 1.00)
        main = imgui.ImVec4(0.75, 0.20, 0.50, 0.80)
        hover = imgui.ImVec4(0.90, 0.25, 0.60, 0.90)
        activeColor = imgui.ImVec4(1.00, 0.30, 0.70, 1.00)
        frame = imgui.ImVec4(0.25, 0.14, 0.20, 1.00)
        frameHov = imgui.ImVec4(0.35, 0.18, 0.28, 1.00)
        frameAct = imgui.ImVec4(0.45, 0.22, 0.35, 1.00)
    elseif themeIndex[0] == 2 then
        bg = imgui.ImVec4(0.08, 0.10, 0.14, 1.00)
        main = imgui.ImVec4(0.15, 0.35, 0.70, 0.80)
        hover = imgui.ImVec4(0.20, 0.45, 0.85, 0.90)
        activeColor = imgui.ImVec4(0.25, 0.55, 0.95, 1.00)
        frame = imgui.ImVec4(0.14, 0.18, 0.25, 1.00)
        frameHov = imgui.ImVec4(0.18, 0.24, 0.35, 1.00)
        frameAct = imgui.ImVec4(0.22, 0.30, 0.45, 1.00)
    elseif themeIndex[0] == 3 then
        bg = imgui.ImVec4(0.08, 0.13, 0.14, 1.00)
        main = imgui.ImVec4(0.15, 0.60, 0.70, 0.80)
        hover = imgui.ImVec4(0.20, 0.75, 0.85, 0.90)
        activeColor = imgui.ImVec4(0.25, 0.85, 0.95, 1.00)
        frame = imgui.ImVec4(0.14, 0.23, 0.25, 1.00)
        frameHov = imgui.ImVec4(0.18, 0.30, 0.35, 1.00)
        frameAct = imgui.ImVec4(0.22, 0.38, 0.45, 1.00)
    elseif themeIndex[0] == 4 then
        bg = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
        main = imgui.ImVec4(0.20, 0.20, 0.20, 0.80)
        hover = imgui.ImVec4(0.30, 0.30, 0.30, 0.90)
        activeColor = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
        frame = imgui.ImVec4(0.13, 0.13, 0.13, 1.00)
        frameHov = imgui.ImVec4(0.18, 0.18, 0.18, 1.00)
        frameAct = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
    elseif themeIndex[0] == 5 then
        bg = imgui.ImVec4(0.18, 0.18, 0.18, 1.00)
        main = imgui.ImVec4(0.40, 0.40, 0.40, 0.80)
        hover = imgui.ImVec4(0.50, 0.50, 0.50, 0.90)
        activeColor = imgui.ImVec4(0.60, 0.60, 0.60, 1.00)
        frame = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
        frameHov = imgui.ImVec4(0.34, 0.34, 0.34, 1.00)
        frameAct = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
    end

    colors[imgui.Col.WindowBg] = bg
    colors[imgui.Col.Header] = main
    colors[imgui.Col.HeaderHovered] = hover
    colors[imgui.Col.HeaderActive] = activeColor
    
    colors[imgui.Col.TitleBg] = imgui.ImVec4(main.x * 0.7, main.y * 0.7, main.z * 0.7, 1.00)
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(main.x, main.y, main.z, 1.00)
    
    colors[imgui.Col.Button] = main
    colors[imgui.Col.ButtonHovered] = hover
    colors[imgui.Col.ButtonActive] = activeColor
    
    colors[imgui.Col.FrameBg] = frame
    colors[imgui.Col.FrameBgHovered] = frameHov
    colors[imgui.Col.FrameBgActive] = frameAct
    
    colors[imgui.Col.SliderGrab] = hover
    colors[imgui.Col.SliderGrabActive] = activeColor
    
    colors[imgui.Col.CheckMark] = activeColor
end

local styleInitialized = false

imgui.OnFrame(function() return WinState[0] or UpdateWinState[0] end, function(player)
    if not styleInitialized then
        applyCustomStyle(currentColor)
        styleInitialized = true
    end

    if WinState[0] then
        imgui.SetNextWindowSize(imgui.ImVec2(550, 340), imgui.Cond.FirstUseEver)
        
        if imgui.Begin("FiFlooder | Dev: Fizer", WinState) then
            imgui.PushItemWidth(-1)
            imgui.Text(u8"Введите текст для флуда:")
            if imgui.InputText("##SpamText", spamText, 256) then end
            
            imgui.Spacing()
            imgui.Text(u8"Задержка (в секундах):")
            if imgui.SliderInt("##DelaySeconds", delay, 1, 60) then end
            imgui.PopItemWidth()
            
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            
            imgui.Text(u8"Настройки цвета меню:")
            imgui.PushItemWidth(-1)
            if imgui.Combo("##MenuColorCombo", currentColor, color_items, #color_items) then
                applyCustomStyle(currentColor)
            end
            imgui.PopItemWidth()
            
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 15)
            
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
                local decoded_text = u8:decode(script_response.text)
                file:write(decoded_text)
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
