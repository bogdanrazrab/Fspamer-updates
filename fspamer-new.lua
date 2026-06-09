local vkeys = require 'vkeys'
local active = false
local spamText = "Сменить текст"
local delay = 3000

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("fpanel", function()
        local menuText = string.format(
            "1. Изменить текст{FFFF00}(сейчас: %s){FFFFFF}\n" ..
            "2. Изменить задержку {FFFF00}(сейчас: %d сек){FFFFFF}\n" ..
            "3. Статус: %s",
            spamText, (delay / 1000), active and "{00FF00}ЗАПУЩЕН" or "{FF0000}ВЫКЛЮЧЕН"
        )
        sampShowDialog(1234, "{00FF00}FIER-SPAMER {FFFFFF}Настройки", menuText, "Выбрать", "Закрыть", 2)
    end)

    while true do
        wait(0)
        
        local result, button, list, input = sampHasDialogRespond(1234)
        if result and button == 1 then
            if list == 0 then
                sampShowDialog(1235, "Изменение текста", "Введите новый текст:", "Ок", "Отмена", 1)
            elseif list == 1 then
                sampShowDialog(1236, "Изменение времени", "Введите задержку в секундах:", "Ок", "Отмена", 1)
            elseif list == 2 then
                active = not active
            end
        end

        local resT, btnT, listT, inputT = sampHasDialogRespond(1235)
        if resT and btnT == 1 and #inputT > 0 then
            spamText = inputT
        end

        local resV, btnV, listV, inputV = sampHasDialogRespond(1236)
        if resV and btnV == 1 then
            local newDelay = tonumber(inputV)
            if newDelay and newDelay > 0 then
                delay = newDelay * 1000
            end
        end

        if active then
            sampSendChat(spamText)
            wait(delay)
        end
    end
end
