-- PROCHAT 3.3.5 - By El Rey Flahs
local CURRENT_VERSION = "4.2.3"
local keywords = {"ICC", "SR", "ARCHA", "TOC", "FOSO", "NAXX", "ULDUAR", "SEMANAL", "VIAJEROS", "SO"}
local userMessages, history, raidGroups, collapsed = { ["TODAS"] = {} }, { ["TODAS"] = {} }, {}, {}

local fullNames = {
    ["ICC"] = "Ciudadela de la Corona de Hielo", ["SR"] = "Sagrario Rubí", ["ARCHA"] = "Cámara de Archavon",
    ["TOC"] = "Prueba del Cruzado (ToC)", ["FOSO"] = "Foso de Saron", ["NAXX"] = "Naxxramas",
    ["ULDUAR"] = "Ulduar", ["SEMANAL"] = "Misión Semanal", ["VIAJEROS"] = "Viajeros en el Tiempo", ["SO"] = "Sagrario Obsidiana",
}

for _, k in ipairs(keywords) do 
    history[k], raidGroups[k], collapsed[k] = {}, {}, false 
end

local selectedChannels, selectedContentFilter = {}, "TODAS"
local filterTime, hideGrays, showRaidWin, searchTerm = 60, false, true, ""

local filterColors = {
    ["ICC"] = "81DDF0", ["SR"] = "FF8000", ["ARCHA"] = "E6CC80", ["SEMANAL"] = "0070DE",
    ["NAXX"] = "32CD32", ["ULDUAR"] = "D2B48C", ["TOC"] = "FFFF00", ["VIAJEROS"] = "A335EE",
    ["FOSO"] = "FF69B4", ["SO"] = "FF0000", ["TODAS"] = "B0B0B0",
}

local classColors = {
    ["WARRIOR"] = "C79C6E", ["PALADIN"] = "F58CBA", ["HUNTER"] = "ABD473",
    ["ROGUE"] = "FFF569", ["PRIEST"] = "FFFFFF", ["DEATHKNIGHT"] = "C41F3B",
    ["SHAMAN"] = "0070DE", ["MAGE"] = "69CCF0", ["WARLOCK"] = "9482C9",
    ["DRUID"] = "FF7D0A"
}

local channelTags = {
    ["DECIR"]     = {t="D", c="ffffff"}, -- Blanco
    ["GRITAR"]    = {t="Y", c="ff4040"}, -- Rojo
    ["HERMANDAD"] = {t="H", c="40ff40"}, -- Verde
    ["COMERCIO"]  = {t="C", c="ffc0c0"}, -- Rosa/Naranja
    ["GENERAL"]   = {t="G", c="ffc0c0"}, -- Rosa/Naranja
    ["POSADA"]    = {t="P", c="ffc0c0"}, -- Rosa/Naranja
    ["BUSCARGRUPO"] = {t="B", c="ffc0c0"}, -- Rosa/Naranja
}

-- Registrar ventanas para que se cierren con la tecla ESC
tinsert(UISpecialFrames, "BDM_ChatWin")
tinsert(UISpecialFrames, "BDM_RaidWin")
tinsert(UISpecialFrames, "BDM_CreditsWin")
tinsert(UISpecialFrames, "BDM_WelcomeWin")

-- --- FUNCIONES DE PERSISTENCIA Y MOVIMIENTO ---
local function UpdateMinimapPos()
    local angle = ProChatDB.mmAngle or 45
    BDM_Minimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(angle)), (80 * sin(angle)) - 52)
end

local function SaveWindowState(state)
    if ProChatDB then ProChatDB.showWindows = state end
end

local function RefreshChatWindow()
    if not BDM_ChatWin_Text then return end
    BDM_ChatWin_Text:Clear()
    local data = history[selectedContentFilter]
    if data then 
        for _, entry in ipairs(data) do 
            if searchTerm == "" or string.find(entry:upper(), searchTerm:upper()) then
                if not hideGrays or not string.find(entry, "ffB0B0B0") then BDM_ChatWin_Text:AddMessage(entry) end
            end
        end 
    end
end

function UpdateRaidList()
    if not raidWin or not raidWin.text then return end
    raidWin.text:Clear()
    for i = #keywords, 1, -1 do
        local k = keywords[i]
        local count = 0
        for _ in pairs(raidGroups[k]) do count = count + 1 end
        if count > 0 then
            if not collapsed[k] then
                local l = "    "
                for p in pairs(raidGroups[k]) do l = l .. "|Hplayer:"..p.."|h["..p.."]|h " end
                raidWin.text:AddMessage(l)
            end
            local sym = collapsed[k] and "[+] " or "[-] "
            raidWin.text:AddMessage("|Hraidclick:"..k.."|h|cff"..filterColors[k]..sym..(fullNames[k] or k).." ("..count..")|r|h")
        end
    end
end

-- --- VENTANAS AUXILIARES ---
local credWin = CreateFrame("Frame", "BDM_CreditsWin", UIParent)
credWin:SetSize(380, 320); credWin:SetPoint("CENTER"); credWin:Hide(); credWin:SetFrameStrata("TOOLTIP")
credWin:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = {8,8,8,8}})
local cT = credWin:CreateFontString(nil, "OVERLAY", "GameFontNormal"); cT:SetPoint("TOP", 0, -15); cT:SetText("|cffA335EECréditos y Comandos de ProChat|r")
local cX = credWin:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); cX:SetPoint("TOPLEFT", 20, -45); cX:SetWidth(340); cX:SetJustifyH("LEFT")
cX:SetText("Creado por |cffffffffEl Rey Flahs|r.\n\n|cffFFFF00COMANDOS DISPONIBLES:|r\n\n|cffFFD100/pc|r o |cffFFD100/prochat|r\nUsa este comando para abrir o cerrar rápidamente el panel principal del addon.\n\n|cffFFD100/pc reset|r\nRestablece las ventanas a su posición original, reinicia los tamaños, vuelve a mostrar la bienvenida y activa todos los paneles por defecto.\n\n|cff00ff00Repositorio:|r github.com/elreyflahs/ProChat")
local cC = CreateFrame("Button", nil, credWin, "UIPanelButtonTemplate"); cC:SetSize(80, 22); cC:SetPoint("BOTTOM", 0, 15); cC:SetText("Cerrar"); cC:SetScript("OnClick", function() credWin:Hide() end)

local welcomeWin = CreateFrame("Frame", "BDM_WelcomeWin", UIParent)
welcomeWin:SetSize(400, 260); welcomeWin:SetPoint("CENTER"); welcomeWin:Hide(); welcomeWin:SetFrameStrata("HIGH")
welcomeWin:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = {8,8,8,8}})
local wT = welcomeWin:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); wT:SetPoint("TOP", 0, -25); wT:SetText("|cffA335EE¡Gracias por descargar ProChat!|r")
local wX = welcomeWin:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); wX:SetPoint("TOP", 0, -65); wX:SetWidth(340); wX:SetJustifyH("CENTER")
wX:SetText("Tu asistente de búsqueda de mazmorras ha sido instalado correctamente.\n\nEstado: |cff00ff00Addon Actualizado|r\nVersión: |cffFFD100" .. CURRENT_VERSION .. "|r\n\nUsa |cffFFD100/pc|r para empezar a filtrar el chat masivo.")
local wB = CreateFrame("Button", nil, welcomeWin, "UIPanelButtonTemplate"); wB:SetSize(120, 30); wB:SetPoint("BOTTOM", 0, 25); wB:SetText("Entendido"); wB:SetScript("OnClick", function() welcomeWin:Hide() end)

-- --- CREADOR DE VENTANAS ---
local function CreateAdvancedWindow(name, title)
    local f = CreateFrame("Frame", name, UIParent)
    local width = (name == "BDM_ChatWin") and 800 or 250
    f:SetSize(width, 420); f:SetPoint("CENTER"); f:SetMovable(true); f:SetResizable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
    if name == "BDM_ChatWin" then f:SetMinResize(550, 300) else f:SetMinResize(250, 250) end
    f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = {8,8,8,8}})

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() 
        f:Hide() 
        if name == "BDM_ChatWin" then 
            raidWin:Hide() 
            SaveWindowState(false) 
        end 
    end)
    
    local tBtn = CreateFrame("Button", nil, f); tBtn:SetSize(width - 40, 25); tBtn:SetPoint("TOP", 0, -8)
    local t = tBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); t:SetPoint("CENTER", 0, 0); t:SetText(title)
    if name == "BDM_ChatWin" then tBtn:SetScript("OnClick", function() if credWin:IsVisible() then credWin:Hide() else credWin:Show() end end) end

    local rb = CreateFrame("Button", name.."_Resize", f); rb:SetSize(16, 16); rb:SetPoint("BOTTOMRIGHT", -7, 7); rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    rb:SetScript("OnMouseDown", function() f:StartSizing() end); rb:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    local sf = CreateFrame("ScrollingMessageFrame", name.."_Text", f)
    sf:SetPoint("TOPLEFT", 15, -125); sf:SetPoint("BOTTOMRIGHT", -30, 65); sf:SetFontObject(GameFontHighlightSmall)
    sf:SetMaxLines(500); sf:SetFading(false); sf:SetJustifyH("LEFT"); sf:EnableMouseWheel(true); sf:SetHyperlinksEnabled(true)
    if name == "BDM_RaidWin" then sf:SetInsertMode("TOP") end
    
    sf:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
        else if IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end end
    end)

    sf:SetScript("OnHyperlinkClick", function(self, link, text, button)
        local type, value = strsplit(":", link)
        if type == "player" then
            if button == "RightButton" then FriendsFrame_ShowDropdown(value, 1)
            elseif IsShiftKeyDown() then local eb = ChatEdit_GetActiveWindow(); if eb then eb:Insert(text) else SendWho(value) end
            else ChatFrame_OpenChat("/w "..value.." ", DEFAULT_CHAT_FRAME) end
        elseif type == "raidclick" then collapsed[value] = not collapsed[value]; UpdateRaidList()
        else ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE"); ItemRefTooltip:SetHyperlink(link); ItemRefTooltip:Show() end
    end)
    
    f:SetScript("OnMouseDown", function(self) self:StartMoving() end); f:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    f.text = sf; return f
end

chatWin = CreateAdvancedWindow("BDM_ChatWin", "|cffA335EEProChat|r |cffFF4D4Dv"..CURRENT_VERSION.."|r |cffffffffBy El Rey Flahs|r")
raidWin = CreateAdvancedWindow("BDM_RaidWin", "|cffA335EELíderes de Raids|r")
raidWin:SetPoint("CENTER", 530, 0)

-- --- PANEL DE CONTROL ---
local function AddLabel(text, x, parent)
    local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); l:SetPoint("TOP", x, -70); l:SetText(text)
end

AddLabel("Seleccionar canal:", -160, chatWin); AddLabel("Seleccionar Mazmorra:", 0, chatWin); AddLabel("Seleccionar tiempo de spam:", 160, chatWin)

local chanDrop = CreateFrame("Frame", "BDM_ChanDrop", chatWin, "UIDropDownMenuTemplate"); chanDrop:SetPoint("TOP", -170, -85); UIDropDownMenu_SetWidth(chanDrop, 100)
UIDropDownMenu_Initialize(chanDrop, function()
    
    local extra = {"Decir", "Gritar", "Hermandad"}
    for _, name in ipairs(extra) do
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.value = name, name
        info.keepShownOnClick, info.isNotRadio = true, true
        info.checked = selectedChannels[name:upper()]
        info.func = function(self)
            selectedChannels[name:upper()] = self.checked
            local count = 0
            for k, v in pairs(selectedChannels) do if v then count = count + 1 end end
            UIDropDownMenu_SetText(chanDrop, count .. " Canales")
            chatWin.text:Clear()
            RefreshChatWindow()
        end
        UIDropDownMenu_AddButton(info)
    end

    local channels = { GetChannelList() }
    for i = 1, #channels, 2 do
        local name = channels[i+1]
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.value = name, name
        info.keepShownOnClick, info.isNotRadio = true, true
        info.checked = selectedChannels[name:upper()]
        info.func = function(self)
            selectedChannels[name:upper()] = self.checked
            local count = 0
            for k, v in pairs(selectedChannels) do if v then count = count + 1 end end
            UIDropDownMenu_SetText(chanDrop, count .. " Canales")
            chatWin.text:Clear()
            RefreshChatWindow()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

local filterDrop = CreateFrame("Frame", "BDM_FilterDrop", chatWin, "UIDropDownMenuTemplate"); filterDrop:SetPoint("TOP", -10, -85); UIDropDownMenu_SetWidth(filterDrop, 110)
UIDropDownMenu_Initialize(filterDrop, function()
    local opts = {"TODAS"}
    for _, k in ipairs(keywords) do table.insert(opts, k) end
    for _, opt in ipairs(opts) do
        local info = UIDropDownMenu_CreateInfo()
        local c = filterColors[opt] or "ffffff"
        info.text, info.value = "|cff"..c..opt.."|r", opt
        info.func = function(self) 
            selectedContentFilter = self.value
            UIDropDownMenu_SetText(filterDrop, "|cff"..c..self.value.."|r")
            RefreshChatWindow() 
        end
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetText(filterDrop, "TODAS")

local timeDrop = CreateFrame("Frame", "BDM_TimeDrop", chatWin, "UIDropDownMenuTemplate"); timeDrop:SetPoint("TOP", 150, -85); UIDropDownMenu_SetWidth(timeDrop, 80)
UIDropDownMenu_Initialize(timeDrop, function()
    local t = {{s="30s", v=30}, {s="1min", v=60}, {s="2min", v=120}, {s="3min", v=180}, {s="5min", v=300}}
    for _, item in ipairs(t) do
        local info = UIDropDownMenu_CreateInfo(); info.text, info.value = item.s, item.v
        info.func = function(self) 
            filterTime = self.value; UIDropDownMenu_SetText(timeDrop, item.s)
            print("|cffA335EEProChat:|r Tiempo del filtro de spam ajustado. Ahora, el jugador deberá esperar |cffFFFF00"..item.s.."|r para que su mensaje aparezca nuevamente en ProChat.")
        end
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetText(timeDrop, "1min")

local searchBox = CreateFrame("EditBox", "PC_SearchBox", chatWin, "InputBoxTemplate"); searchBox:SetSize(130, 20); searchBox:SetPoint("BOTTOMRIGHT", -20, 12); searchBox:SetAutoFocus(false)
searchBox:SetScript("OnTextChanged", function(self) searchTerm = self:GetText(); RefreshChatWindow() end)
local searchLabel = chatWin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); searchLabel:SetPoint("RIGHT", searchBox, "LEFT", -8, 0); searchLabel:SetText("Filtro:")

local scaleSlider = CreateFrame("Slider", "BDM_ChatScale", chatWin, "OptionsSliderTemplate")
scaleSlider:SetPoint("BOTTOM", 0, 22); scaleSlider:SetWidth(140); scaleSlider:SetMinMaxValues(8, 18); scaleSlider:SetValue(8); scaleSlider:SetValueStep(1)
_G[scaleSlider:GetName().."Text"]:SetText("Escala"); _G[scaleSlider:GetName().."Low"]:SetText(""); _G[scaleSlider:GetName().."High"]:SetText("")
scaleSlider:SetScript("OnValueChanged", function(self, value)
    local f1, _, fl1 = chatWin.text:GetFont(); chatWin.text:SetFont(f1, value, fl1)
    local f2, _, fl2 = raidWin.text:GetFont(); raidWin.text:SetFont(f2, value, fl2)
end)

local checkMM = CreateFrame("CheckButton", "PC_CheckMM", chatWin, "UICheckButtonTemplate"); checkMM:SetPoint("TOP", -180, -35); _G[checkMM:GetName().."Text"]:SetText("Icono Minimapa"); checkMM:SetChecked(true)
checkMM:SetScript("OnClick", function(self) if self:GetChecked() then BDM_Minimap:Show() else BDM_Minimap:Hide() end end)

local checkGrays = CreateFrame("CheckButton", "PC_CheckGrays", chatWin, "UICheckButtonTemplate"); checkGrays:SetPoint("TOP", -30, -35); _G[checkGrays:GetName().."Text"]:SetText("Ocultar Grises"); checkGrays:SetChecked(false)
checkGrays:SetScript("OnClick", function(self) hideGrays = self:GetChecked(); RefreshChatWindow() end)

local checkRaid = CreateFrame("CheckButton", "PC_CheckRaid", chatWin, "UICheckButtonTemplate"); checkRaid:SetPoint("TOP", 120, -35); _G[checkRaid:GetName().."Text"]:SetText("Mostrar líderes"); checkRaid:SetChecked(true)
checkRaid:SetScript("OnClick", function(self) showRaidWin = self:GetChecked(); if chatWin:IsVisible() then if showRaidWin then raidWin:Show() else raidWin:Hide() end end end)

local globalClear = CreateFrame("Button", nil, chatWin, "UIPanelButtonTemplate")
globalClear:SetSize(75, 22); globalClear:SetPoint("BOTTOMLEFT", 20, 12); globalClear:SetText("Limpiar")
globalClear:SetScript("OnClick", function() 
    chatWin.text:Clear(); for k in pairs(history) do history[k] = {} end
    raidWin.text:Clear(); for _, k in ipairs(keywords) do raidGroups[k] = {} end
    UpdateRaidList()
end)

-- --- MINIMAPA (CON MOVIMIENTO) ---
local mm = CreateFrame("Button", "BDM_Minimap", Minimap); mm:SetSize(33, 33); mm:EnableMouse(true); mm:SetFrameStrata("MEDIUM"); mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local icon = mm:CreateTexture(nil, "BACKGROUND"); icon:SetTexture("Interface\\Icons\\INV_Misc_Note_02"); icon:SetSize(20, 20); icon:SetPoint("CENTER")
local border = mm:CreateTexture(nil, "OVERLAY"); border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); border:SetSize(52, 52); border:SetPoint("TOPLEFT")

mm:RegisterForDrag("LeftButton")
mm:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", function()
    local xpos, ypos = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    local scale = Minimap:GetEffectiveScale()
    local x = (xmin + (Minimap:GetWidth()/2)) - (xpos/scale)
    local y = (ypos/scale) - (ymin + (Minimap:GetHeight()/2))
    ProChatDB.mmAngle = math.deg(math.atan2(y, x))
    UpdateMinimapPos()
end) end)
mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

mm:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:AddLine("|cffA335EEProChat "..CURRENT_VERSION.."|r")
    GameTooltip:AddLine("Click: Mostrar/Ocultar\nArrastrar: Mover icono", 1, 1, 1); GameTooltip:Show()
end)
mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
mm:SetScript("OnClick", function(self)
    if IsControlKeyDown() then credWin:Show()
    elseif IsShiftKeyDown() then self:Hide(); PC_CheckMM:SetChecked(false)
    else 
        if chatWin:IsVisible() then 
            chatWin:Hide(); raidWin:Hide(); SaveWindowState(false)
        else 
            chatWin:Show(); if showRaidWin then raidWin:Show() end; SaveWindowState(true)
        end 
    end
end)

-- --- COMANDOS ---
SLASH_PROCHAT1 = "/pc"; SLASH_PROCHAT2 = "/prochat"
SlashCmdList["PROCHAT"] = function(msg)
    if msg == "reset" then
        
        chatWin:SetSize(800, 420); chatWin:SetPoint("CENTER")
        raidWin:SetSize(250, 420); raidWin:SetPoint("CENTER", 530, 0)
        scaleSlider:SetValue(8)
        
        for k in pairs(history) do history[k] = {} end
        for k in pairs(raidGroups) do raidGroups[k] = {} end
        for k in pairs(selectedChannels) do selectedChannels[k] = false end
        
        searchTerm = ""; searchBox:SetText("")
        selectedContentFilter = "TODAS"
        UIDropDownMenu_SetText(filterDrop, "TODAS")
        UIDropDownMenu_SetText(chanDrop, "0 Canales")
        
        ProChatDB.mmAngle = 45; UpdateMinimapPos()
        welcomeWin:Show(); SaveWindowState(true)
        chatWin:Show(); if showRaidWin then raidWin:Show() end
        
        RefreshChatWindow(); UpdateRaidList()
        print("|cffA335EEProChat:|r El addon ha sido restablecido por completo.")
    else 
        if chatWin:IsVisible() then 
            chatWin:Hide(); raidWin:Hide(); SaveWindowState(false)
        else 
            chatWin:Show(); if showRaidWin then raidWin:Show() end; SaveWindowState(true)
        end 
    end
end

-- --- LISTENERs ---
local listener = CreateFrame("Frame")
listener:RegisterEvent("CHAT_MSG_CHANNEL"); listener:RegisterEvent("ADDON_LOADED"); listener:RegisterEvent("PLAYER_ENTERING_WORLD")
listener:RegisterEvent("CHAT_MSG_SAY")
listener:RegisterEvent("CHAT_MSG_YELL")
listener:RegisterEvent("CHAT_MSG_GUILD")
listener:RegisterEvent("PLAYER_REGEN_DISABLED") -- Detectar inicio de combate

listener:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and select(1, ...) == "ProChat" then
        if not ProChatDB then ProChatDB = {} end
        if ProChatDB.mmAngle == nil then ProChatDB.mmAngle = 45 end
        if ProChatDB.showWindows == nil then ProChatDB.showWindows = true end
        if ProChatDB.firstRun == nil then welcomeWin:Show(); ProChatDB.firstRun = false end
        
        -- Aplicar estado guardado
        UpdateMinimapPos()
        if ProChatDB.showWindows then 
            chatWin:Show()
            if showRaidWin then raidWin:Show() end
        else 
            chatWin:Hide(); raidWin:Hide()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        print("|cffA335EEProChat:|r Cargado. Versión |cffffffff"..CURRENT_VERSION.."|r Estado: |cff00ff00Addon Actualizado|r.")

    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Ocultar ventanas automáticamente al entrar en combate v4.1
        if chatWin:IsVisible() then
            chatWin:Hide()
            raidWin:Hide()
            SaveWindowState(false)
            print("|cffA335EEProChat:|r Ventanas ocultadas por combate.")
        end

 elseif event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_GUILD" then
    -- Capturamos hasta el argumento 12 para obtener el GUID
    local msg, sender, _, _, _, _, _, _, chanName, _, _, guid = ...
    
    -- 1. Mapeo manual para eventos de sistema
    if event == "CHAT_MSG_SAY" then chanName = "Decir"
    elseif event == "CHAT_MSG_YELL" then chanName = "Gritar"
    elseif event == "CHAT_MSG_GUILD" then chanName = "Hermandad"
    end

    if not chatWin:IsVisible() or not chanName then return end
    
    local isSelected = false
    local chanUpper = chanName:upper()

    for selectedName, active in pairs(selectedChannels) do
        if active and string.find(chanUpper, selectedName:upper()) then
            isSelected = true
            break
        end
    end

    if not isSelected then return end

    local now = GetTime()
    if not userMessages[sender] or (now - userMessages[sender] > filterTime) then
        local msgU = msg:upper(); local matched = nil
        for _, k in ipairs(keywords) do if string.find(" "..msgU.." ", "[^%a]"..k.."[^%a]") then matched = k; break end end
        local cat = matched or "TODAS"; local c = filterColors[cat]
        
        local nameColor = c
        if guid then
            local _, classUpper = GetPlayerInfoByGUID(guid)
            if classUpper and classColors[classUpper] then
                nameColor = classColors[classUpper]
            end
        end

        local cleanName = chanName:gsub("%d+%.%s*", ""):upper()
        local tagData = channelTags[cleanName] or {t=string.sub(cleanName,1,1), c="ffffff"}
        
        local dungeonTag = ""
        if matched then dungeonTag = " |cff"..c.."["..matched.."]|r" end

        local formatted = "|cff"..tagData.c.."["..tagData.t.."]|r |cff"..c.."[|r|Hplayer:"..sender.."|h|cff"..nameColor..sender.."|r|h|cff"..c.."]|r"..dungeonTag..": "..msg
        
        table.insert(history["TODAS"], formatted)
        if matched then 
            table.insert(history[matched], formatted)
            raidGroups[matched][sender] = true
            UpdateRaidList() 
        end

        if selectedContentFilter == "TODAS" or selectedContentFilter == cat then
            if searchTerm == "" or string.find(formatted:upper(), searchTerm:upper()) then
                if not hideGrays or cat ~= "TODAS" then chatWin.text:AddMessage(formatted) end
            end
        end
        userMessages[sender] = now
    end

if not isSelected then return end

    local now = GetTime()
    if not userMessages[sender] or (now - userMessages[sender] > filterTime) then
        local msgU = msg:upper(); local matched = nil
        for _, k in ipairs(keywords) do if string.find(" "..msgU.." ", "[^%a]"..k.."[^%a]") then matched = k; break end end
        local cat = matched or "TODAS"; local c = filterColors[cat]
        
        local cleanName = chanName:gsub("%d+%.%s*", ""):upper()
        local tagData = channelTags[cleanName] or {t=string.sub(cleanName,1,1), c="ffffff"}
        
        local dungeonTag = ""
        if matched then
            dungeonTag = " |cff"..c.."["..matched.."]|r"
        end

        local formatted = "|cff"..tagData.c.."["..tagData.t.."]|r |cff"..c.."[|r|Hplayer:"..sender.."|h|cff"..c..sender.."|r|h|cff"..c.."]|r"..dungeonTag..": "..msg
        
        table.insert(history["TODAS"], formatted)
        if matched then 
            table.insert(history[matched], formatted)
            raidGroups[matched][sender] = true
            UpdateRaidList() 
        end

        if selectedContentFilter == "TODAS" or selectedContentFilter == cat then
            if searchTerm == "" or string.find(formatted:upper(), searchTerm:upper()) then
                if not hideGrays or cat ~= "TODAS" then chatWin.text:AddMessage(formatted) end
            end
        end
        userMessages[sender] = now
    end
end  
end)

