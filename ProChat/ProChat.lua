-- PROCHAT 3.3.5 - By El Rey Flahs Version
  local CURRENT_VERSION = "4.4.2" 
-- --- LABELS INICIALES ---
    local keywords = {"ICC", "SR", "ARCHA", "TOC", "FOSO", "NAXX", "ULDUAR", "SEMANAL", "VIAJEROS", "SO"}
    local userMessages, history, raidGroups, collapsed = {}, { ["TODAS"] = {} }, {}, {}
    local PC_ClassCache = {}
    local fullNames = {
        ["ICC"] = "ICC", ["SR"] = "SR", ["ARCHA"] = "ARCHA",
        ["TOC"] = "TOC", ["FOSO"] = "FOSO", ["NAXX"] = "NAXX",
        ["ULDUAR"] = "ULDUAR", ["SEMANAL"] = "SEM", ["VIAJEROS"] = "VT", ["SO"] = "SO",
    }

    for _, k in ipairs(keywords) do 
        history[k], raidGroups[k], collapsed[k] = {}, {}, true 
    end

    local selectedChannels = {}
    local selectedDungeons = { ["TODAS"] = true }
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
        ["DECIR"]     = {t="D", c="ffffff"},
        ["GRITAR"]    = {t="Y", c="ff4040"},
        ["HERMANDAD"] = {t="H", c="40ff40"},
        ["COMERCIO"]  = {t="C", c="ffc0c0"},
        ["GENERAL"]   = {t="G", c="ffc0c0"},
        ["POSADA"]    = {t="P", c="ffc0c0"},
        ["BUSCARGRUPO"] = {t="B", c="ffc0c0"},
    }

    local L = {}

    tinsert(UISpecialFrames, "BDM_ChatWin")
    tinsert(UISpecialFrames, "BDM_CreditsWin")
    tinsert(UISpecialFrames, "BDM_WelcomeWin")

-- --- FUNCIONES AUXILIARES ---

        --- DB COLORES ---
            if guid then
                local _, classUpper = GetPlayerInfoByGUID(guid)
                if classUpper and classColors[classUpper] then
                    nameColor = classColors[classUpper]
                    PC_ClassCache[sender] = nameColor
                end
            end

            table.insert(history["TODAS"], formatted)
            
            if matched then 
                table.insert(history[matched], formatted)
                raidGroups[matched][sender] = true
                UpdateRaidList()
            end

    local function UpdateMinimapPos()
            local angle = ProChatDB.mmAngle or 45
            if BDM_Minimap then BDM_Minimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(angle)), (80 * sin(angle)) - 52) end
        end

        local function SaveWindowState(state) if ProChatDB then ProChatDB.showWindows = state end end

        local function RefreshChatWindow()
        if not chatWin or not chatWin.text then return end
        chatWin.text:Clear()
        local displayedMessages = {}

        for dung, active in pairs(selectedDungeons) do
            if active then
                local data = history[dung]
                if data then
                    for _, entry in ipairs(data) do
                        if not displayedMessages[entry] then
                            local matchAny = false
                            if searchTerm == "" then
                                matchAny = true
                            else
                                for word in searchTerm:gmatch("%S+") do 
                                    if string.find(entry:upper(), word:upper(), 1, true) then
                                        matchAny = true
                                        break
                                    end
                                end
                            end

                            if matchAny then
                                if not hideGrays or not string.find(entry, "ffB0B0B0") then 
                                    chatWin.text:AddMessage(entry)
                                    displayedMessages[entry] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    function UpdateRaidList()
    local rf = chatWin and chatWin.raidText
    if not rf then return end
    rf:Clear()
    rf:SetInsertMode("TOP")
    
    for i = #keywords, 1, -1 do
        local k = keywords[i]
        if raidGroups[k] then
            local playersToShow = {}
            for p in pairs(raidGroups[k]) do
                local data = userMessages[p]
                local playerMsg = data and data.msg or ""
                        
                -- LÓGICA DE FILTRADO (OR)
                local matchAny = false
                if searchTerm == "" then
                    matchAny = true
                else
                    -- Si el mensaje del jugador contiene CUALQUIERA de las palabras, es un match
                    for word in searchTerm:gmatch("%S+") do
                        if string.find(playerMsg:upper(), word:upper(), 1, true) then
                            matchAny = true
                            break -- Encontró una, no hace falta seguir buscando
                        end
                    end
                end
            
                if matchAny then
                    table.insert(playersToShow, p)
                end
            end
            
            if #playersToShow > 0 then
                if not collapsed[k] then
                    for _, p in ipairs(playersToShow) do
                        local cColor = PC_ClassCache[p] or "ffffff"
                        rf:AddMessage("      |Hplayer:"..p.."|h|cff"..cColor.."["..p.."]|h|r")
                    end
                end

                local symColor = collapsed[k] and "00ff00" or "ff3333"
                local symText = collapsed[k] and "[ + ]" or "[  -  ]"
                local titleName = (fullNames[k] or k):upper()
                local titleColor = filterColors[k] or "ffffff"
                
                rf:AddMessage("|Hraidclick:"..k.."|h|cff"..symColor..symText.."|r |cff"..titleColor..titleName.."|r|h (|cffffffff"..#playersToShow.."|r)")
            end
            end
        end
    end


-- --- VENTANAS AUXILIARES ---

    -- Ventana de Créditos
       local credWin = CreateFrame("Frame", "BDM_CreditsWin", UIParent)
               credWin:SetSize(380, 320)
               credWin:SetPoint("CENTER")
               credWin:Hide()
               credWin:SetFrameStrata("TOOLTIP")
               credWin:SetBackdrop({
                   bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
                   edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
                   tile = true, tileSize = 32, edgeSize = 32, 
                   insets = {8,8,8,8}
           })
       
           local cT = credWin:CreateFontString(nil, "OVERLAY", "GameFontNormal")
               cT:SetPoint("TOP", 0, -15)
               cT:SetText("|cffA335EECréditos y Comandos de ProChat|r")
       
           local cX = credWin:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
               cX:SetPoint("TOPLEFT", 20, -45)
               cX:SetWidth(340)
               cX:SetJustifyH("LEFT")
               cX:SetText("Creado por |cffffffffEl Rey Flahs|r.\n\n|cffFFFF00COMANDOS DISPONIBLES:|r\n\n|cffFFD100/pc|r o |cffFFD100/prochat|r\nUsa este comando para abrir o cerrar rápidamente el paneprincipal del addon.\n\n|cffFFD100/pc reset|r\nRestablece las ventanas a su posición original, reinicia los tamaños, vuelve a mostrar la bienvenida y activa todos los paneles podefecto.\n\n|cff00ff00Repositorio:|r   github.com/elreyflahs/ProChat")
       
           local cC = CreateFrame("Button", nil, credWin, "UIPanelButtonTemplate")
               cC:SetSize(80, 22)
               cC:SetPoint("BOTTOM", 0, 15)
               cC:SetText("Cerrar")
               cC:SetScript("OnClick", function() credWin:Hide() 
           end)


    -- Ventana de Bienvenida
        local welcomeWin = CreateFrame("Frame", "BDM_WelcomeWin", UIParent)
            welcomeWin:SetSize(400, 260); welcomeWin:SetPoint("CENTER"); welcomeWin:Hide()
            welcomeWin:SetFrameStrata("HIGH")
            welcomeWin:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
                tile = true, tileSize = 32, edgeSize = 32, insets = {8,8,8,8}
            })
        
        wT = welcomeWin:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            wT:SetPoint("TOP", 0, -25)
        
        wX = welcomeWin:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            wX:SetPoint("TOP", 0, -65); wX:SetWidth(340); wX:SetJustifyH("CENTER")
        
        wB = CreateFrame("Button", nil, welcomeWin, "UIPanelButtonTemplate")
            wB:SetSize(120, 30); wB:SetPoint("BOTTOM", 0, 25)
            wB:SetScript("OnClick", function() welcomeWin:Hide() end)
        
        local function RefreshWelcomeTexts()
            local lang = (ProChatDB and ProChatDB.lang) or (GetLocale():sub(1,2) == "es" and "es" or "en")

            if lang == "es" then
                wT:SetText("|cffA335EE¡Gracias por descargar ProChat!|r")
                wX:SetText("Tu asistente de búsqueda de mazmorras ha sido instalado correctamente.\n\nEstado: |cff00ff00Addon Actualizado|r\nVersión: |cffFFD100" .. CURRENT_VERSION .. "\r\n\nUsa |cffFFD100/pc|r para empezar a filtrar el chat masivo.")
                wB:SetText("Entendido")
            else
                wT:SetText("|cffA335EEThanks for downloading ProChat!|r")
                wX:SetText("Your dungeon search assistant has been successfully installed.\n\nStatus: |cff00ff00Addon Updated|r\nVersion: |cffFFD100" .. CURRENT_VERSION .. "\n\nUse |cffFFD100/pc|r to start filtering the massive chat.")
                wB:SetText("Got it")
            end
        end

        local function RefreshCreditsTexts()
            if not cT or not cX or not cC then return end
            local lang = (ProChatDB and ProChatDB.lang) or (GetLocale():sub(1,2) == "es" and "es" or "en")

            if lang == "es" then
                cT:SetText("|cffA335EECréditos y Comandos de ProChat|r")
                cX:SetText("Creado por |cffffffffEl Rey Flahs|r.\n\n|cffFFFF00COMANDOS DISPONIBLES:|r\n\n|cffFFD100/pc|r o |cffFFD100/prochat|r\nUsa este comando para abrir o cerrar el panel principal.\n\n|cffFFD100/pc reset|r\nRestablece ventanas, tamaños y muestra la bienvenida.\n\n|cff00ff00Repositorio:|r github.com/elreyflahs/ProChat")
                cC:SetText("Cerrar")
            else
                cT:SetText("|cffA335EEProChat Credits & Commands|r")
                cX:SetText("Created by |cffffffffEl Rey Flahs|r.\n\n|cffFFFF00AVAILABLE COMMANDS:|r\n\n|cffFFD100/pc|r or |cffFFD100/prochat|r\nUse this command to toggle the main panel.\n\n|cffFFD100/pc reset|r\nResets windows, sizes, and shows the welcome screen.\n\n|cff00ff00Repository:|r github.com/elreyflahs/ProChat")
                cC:SetText("Close")
            end
        end

-- --- CREADOR DE VENTANAS ---
    local function CreateAdvancedWindow(name, title)
        local f = CreateFrame("Frame", name, UIParent)
        local width = (name == "BDM_ChatWin") and 850 or 250 
        f:SetSize(width, 420); f:SetPoint("CENTER"); f:SetMovable(true); f:SetResizable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
        if name == "BDM_ChatWin" then f:SetMinResize(600, 300) else f:SetMinResize(250, 250) end

        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
            tile = true, tileSize = 32, edgeSize = 32, 
            insets = {8,8,8,8}
        })

        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -5, -5)
        close:SetScript("OnClick", function() f:Hide() 
            if name == "BDM_ChatWin" then SaveWindowState(false) end 
        end)

        local tBtn = CreateFrame("Button", nil, f); tBtn:SetSize(width - 550, 25); tBtn:SetPoint("TOP", 0, -8)
        local t = tBtn:CreateFontString(name.."Title", "OVERLAY", "GameFontNormalLarge"); t:SetPoint("CENTER", 0, 0); t:SetText(title)

        if name == "BDM_ChatWin" then 
            tBtn:SetScript("OnClick", function() if credWin:IsVisible() then credWin:Hide() else credWin:Show() end end) 
        end

        local rb = CreateFrame("Button", name.."_Resize", f); rb:SetSize(16, 16); rb:SetPoint("BOTTOMRIGHT", -7, 7); rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetScript("OnMouseDown", function() f:StartSizing() end); rb:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

        -- ÁREA DE CHAT PRINCIPAL
            local sf = CreateFrame("ScrollingMessageFrame", name.."_Text", f)
                sf:SetPoint("TOPLEFT", 15, -125)
            local rightOffset = (name == "BDM_ChatWin") and -210 or -30
                sf:SetPoint("BOTTOMRIGHT", rightOffset, 65)
                sf:SetFontObject(GameFontHighlightSmall)
                sf:SetMaxLines(500); sf:SetFading(false); sf:SetJustifyH("LEFT"); sf:EnableMouseWheel(true); sf:SetHyperlinksEnabled(true)

            -- ACCION BOTON BAJAR TODO
            sf:SetScript("OnMouseWheel", function(self, delta)
            if delta > 0 then 
                if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
                if BDM_ScrollBottom then BDM_ScrollBottom:Show() end
            else 
                if IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end 
                if self:GetVerticalScroll() == 0 and BDM_ScrollBottom then 
                    BDM_ScrollBottom:Hide() 
                end
            end
        end)

            -- INTEGRACIÓN DEL PANEL DE RAIDS ACTIVAS
            if name == "BDM_ChatWin" then
                -- Barra Separadora
                local sep = f:CreateTexture(nil, "OVERLAY")
                sep:SetWidth(2); sep:SetTexture(0.5, 0.5, 0.5, 0.5)
                sep:SetPoint("TOPLEFT", sf, "TOPRIGHT", 5, 0)
                sep:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", 5, 0)
                f.separator = sep

                -- Panel de Raids activas
                local rf = CreateFrame("ScrollingMessageFrame", "BDM_RaidTextIntegrated", f)
                rf:SetPoint("TOPLEFT", sep, "TOPRIGHT", 5, 0)
                rf:SetPoint("BOTTOMRIGHT", -25, 65)
                rf:SetFontObject(GameFontHighlightSmall)
                rf:SetMaxLines(100); rf:SetFading(false); rf:SetJustifyH("LEFT"); rf:EnableMouseWheel(true); rf:SetHyperlinksEnabled(true)
                rf:SetHyperlinksEnabled(true)
                f.raidText = rf
                rf:SetScript("OnMouseWheel", function(self, delta)
                    if delta > 0 then self:ScrollUp() else self:ScrollDown() end
                end)
            end

            local function handleHyperlinks(self, link, text, button)
            local type, value = strsplit(":", link)
            if type == "player" then
                if button == "RightButton" then FriendsFrame_ShowDropdown(value, 1)
                elseif IsShiftKeyDown() then 
                    local eb = ChatEdit_GetActiveWindow(); 
                    if eb then eb:Insert(text) else SendWho(value) end
                else 
                    ChatFrame_OpenChat("/w "..value.." ", DEFAULT_CHAT_FRAME) 
                end
            elseif type == "raidclick" then 
                collapsed[value] = not collapsed[value]
                UpdateRaidList()
            else 
                ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE"); 
                ItemRefTooltip:SetHyperlink(link); 
                ItemRefTooltip:Show() 
            end
        end

        sf:SetScript("OnHyperlinkClick", handleHyperlinks)
        if f.raidText then
        f.raidText:SetScript("OnHyperlinkClick", handleHyperlinks)
        end
-- --- ACTIVAR ARRASTRE DE VENTANA ---
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not IsModifierKeyDown() then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", function(self)
            self:StopMovingOrSizing()
        end)
        f.text = sf
        return f
    end

    --- TITULO DE LA VENTANA ---
    chatWin = CreateAdvancedWindow("BDM_ChatWin", "|cffA335EEProChat|r |cffFF4D4Dv"..CURRENT_VERSION.."|r |cffffffffBy El Rey Flahs|r")

    --- INTERFAZ LOCALIZADA ---

        local function AddLabel(text, x, parent)
            local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            l:SetPoint("TOP", x, -70)
            l:SetText(text)
            return l
        end
        
        local labelChan = AddLabel(L["SELECT_CHAN"], -160, chatWin)
        local labelDung = AddLabel(L["SELECT_DUNGEON"], 0, chatWin)
        local labelSpam = AddLabel(L["SELECT_SPAM"], 160, chatWin)
-- --- DROPDOWNs ---
    -- --- DROPDOWN: SELECCIONAR CANAL ---
        local chanDrop = CreateFrame("Frame", "BDM_ChanDrop", chatWin, "UIDropDownMenuTemplate")
            chanDrop:SetPoint("TOP", -170, -85)
            UIDropDownMenu_SetWidth(chanDrop, 100)

            UIDropDownMenu_Initialize(chanDrop, function()
        -- BASE
            local extra = {"Decir", "Gritar", "Hermandad"}
            for _, name in ipairs(extra) do
                local info = UIDropDownMenu_CreateInfo()
                local internalName = name:upper() 

                info.text = name
                info.value = internalName
                info.keepShownOnClick, info.isNotRadio = true, true
                info.checked = selectedChannels[internalName]

                info.func = function(self)
                    selectedChannels[internalName] = self.checked

                    local count = 0
                    for k, v in pairs(selectedChannels) do if v then count = count + 1 end end

                    UIDropDownMenu_SetText(chanDrop, count .. " " .. (L["CHANNELS_TEXT"] or "Canales"))
                    chatWin.text:Clear()
                    RefreshChatWindow()
                end
                UIDropDownMenu_AddButton(info)
            end

        -- DINAMICA ---
            local channels = { GetChannelList() }
            for i = 1, #channels, 2 do
                local chanID = channels[i]
                local chanName = channels[i+1]

                local info = UIDropDownMenu_CreateInfo()
                local internalName = chanName:upper()

                info.text, info.value = chanName, internalName
                info.keepShownOnClick, info.isNotRadio = true, true
                info.checked = selectedChannels[internalName]

                info.func = function(self)
                    selectedChannels[internalName] = self.checked

                    local count = 0
                    for k, v in pairs(selectedChannels) do if v then count = count + 1 end end
                    UIDropDownMenu_SetText(chanDrop, count .. " " .. (L["CHANNELS_TEXT"] or "Canales"))
                    chatWin.text:Clear()
                    RefreshChatWindow()
                end
                UIDropDownMenu_AddButton(info)
                end
            end)
            UIDropDownMenu_SetText(chanDrop, "0 " .. (L["CHANNELS_TEXT"] or "Canales"))

    -- --- DROPDOWN: FILTRO DE MAZMORRA ---
        local filterDrop = CreateFrame("Frame", "BDM_FilterDrop", chatWin, "UIDropDownMenuTemplate")
        filterDrop:SetPoint("TOP", -10, -85)
        UIDropDownMenu_SetWidth(filterDrop, 110)

        UIDropDownMenu_Initialize(filterDrop, function()
            local info = UIDropDownMenu_CreateInfo()
            info.text = L["ALL_TEXT"] or "TODAS"
            info.value = "TODAS"
            info.keepShownOnClick, info.isNotRadio = true, true
            info.checked = selectedDungeons["TODAS"]
            info.func = function(self)
                for k in pairs(selectedDungeons) do selectedDungeons[k] = false end
                selectedDungeons["TODAS"] = true
                UIDropDownMenu_SetText(filterDrop, L["ALL_TEXT"] or "TODAS")

                chatWin.text:Clear()
                RefreshChatWindow()
                CloseDropDownMenus()
            end
        UIDropDownMenu_AddButton(info)

        -- DINAMICA
            for _, k in ipairs(keywords) do
                local info = UIDropDownMenu_CreateInfo()
                local c = filterColors[k] or "ffffff"
                info.text = "|cff"..c..k.."|r"
                info.value = k
                info.keepShownOnClick, info.isNotRadio = true, true
                info.checked = selectedDungeons[k]

                info.func = function(button)
                    selectedDungeons["TODAS"] = false
                    selectedDungeons[k] = button.checked
                    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
                        local btn = _G["DropDownList1Button"..i]
                        if btn and btn.value == "TODAS" then
                            _G["DropDownList1Button"..i.."Check"]:Hide()
                        end
                    end

                    -- Conteo de selecciones
                    local count = 0
                    for dk, v in pairs(selectedDungeons) do if v then count = count + 1 end end

                    if count == 0 then 
                        selectedDungeons["TODAS"] = true
                        UIDropDownMenu_SetText(filterDrop, L["ALL_TEXT"] or "TODAS")
                        for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
                            local btn = _G["DropDownList1Button"..i]
                            if btn and btn.value == "TODAS" then
                                _G["DropDownList1Button"..i.."Check"]:Show()
                            end
                        end
                    else
                        UIDropDownMenu_SetText(filterDrop, count .. " " .. (L["DUNGEONS_TEXT"] or "Mazmorras"))
                    end

                    chatWin.text:Clear()
                    RefreshChatWindow()
                end
                UIDropDownMenu_AddButton(info)
        end
        end)
        selectedDungeons = { ["TODAS"] = true }
        UIDropDownMenu_SetText(filterDrop, L["ALL_TEXT"] or "TODAS")

    -- --- DROPDOWN: TIEMPO DE MSG ---
        local timeDrop = CreateFrame("Frame", "BDM_TimeDrop", chatWin, "UIDropDownMenuTemplate")
        timeDrop:SetPoint("TOP", 150, -85)
        UIDropDownMenu_SetWidth(timeDrop, 80)

        UIDropDownMenu_Initialize(timeDrop, function()
            local t = {{s="30s", v=30}, {s="1min", v=60}, {s="2min", v=120}, {s="3min", v=180}, {s="5min", v=300}}
            for _, item in ipairs(t) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.s
                info.value = item.v
                local sText = item.s 
                local sValue = item.v
            
                info.func = function() 
                    filterTime = sValue
                    UIDropDownMenu_SetText(timeDrop, sText)
                    local mins = sValue / 60
                    local tag = "|cffA335EEProChat|r: "
                    local etiqueta = L["TIME_CHANGED"] or "Filter time changed to: "
                    DEFAULT_CHAT_FRAME:AddMessage(tag .. etiqueta .. "|cffffff00" .. mins .. " min|r")
                    if ProChatDB then ProChatDB.filterTime = sValue end
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetText(timeDrop, "1min")

-- --- FILTRO ---
    local searchBox = CreateFrame("EditBox", "PC_SearchBox", chatWin, "InputBoxTemplate")
    searchBox:SetSize(130, 20); searchBox:SetPoint("BOTTOMRIGHT", -20, 12); searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self) searchTerm = self:GetText(); RefreshChatWindow() UpdateRaidList() end)

    local searchLabel = chatWin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("RIGHT", searchBox, "LEFT", -8, 0)
    searchLabel:SetText(L["SEARCH_LABEL"])


    
-- --- CHECKBOXs ---
    -- MINIMAPA
        local checkMM = CreateFrame("CheckButton", "PC_CheckMM", chatWin, "UICheckButtonTemplate")
        checkMM:SetPoint("TOP", -180, -35)
        _G[checkMM:GetName().."Text"]:SetText("Minimap")
        checkMM:SetChecked(ProChatDB and ProChatDB.showMinimap or true)
        checkMM:SetScript("OnClick", function(self) 
            if self:GetChecked() then BDM_Minimap:Show() else BDM_Minimap:Hide() end 
            if ProChatDB then ProChatDB.showMinimap = self:GetChecked() end
        end)

    -- OCULTAR GRISES
        local checkGrays = CreateFrame("CheckButton", "PC_CheckGrays", chatWin, "UICheckButtonTemplate")
        checkGrays:SetPoint("TOP", -30, -35)
        _G[checkGrays:GetName().."Text"]:SetText(L["HIDE_GRAYS"] or "Ocultar Grises") 
        checkGrays:SetScript("OnClick", function(self) 
            hideGrays = self:GetChecked()
            if ProChatDB then ProChatDB.hideGrays = hideGrays end
            RefreshChatWindow() 
        end)

    -- MOSTRAR LÍDERES
        local checkRaid = CreateFrame("CheckButton", "PC_CheckRaid", chatWin, "UICheckButtonTemplate")
        checkRaid:SetPoint("TOP", 120, -35)
        _G[checkRaid:GetName().."Text"]:SetText(L["SHOW_LEADERS"] or "Líderes")
        checkRaid:SetChecked(ProChatDB and ProChatDB.showRaidWin or true)
        checkRaid:SetScript("OnClick", function(self) 
            local isChecked = self:GetChecked()
            if ProChatDB then ProChatDB.showRaidWin = isChecked end

            if isChecked then
                if chatWin.raidText then chatWin.raidText:Show() end
                if chatWin.separator then chatWin.separator:Show() end
                chatWin.text:SetPoint("BOTTOMRIGHT", -210, 65)
                UpdateRaidList()
            else
                if chatWin.raidText then chatWin.raidText:Hide() end
                if chatWin.separator then chatWin.separator:Hide() end
                chatWin.text:SetPoint("BOTTOMRIGHT", -30, 65)
            end
        end)

    --- CHECKBOX OPCIONES ---
        local checkOptions = CreateFrame("CheckButton", "PC_CheckOptions", chatWin, "UICheckButtonTemplate")
        checkOptions:SetPoint("TOPRIGHT", -110, -8) 
        _G[checkOptions:GetName().."Text"]:SetText(L["OPTIONS_CHECK"] or "Opciones")
        checkOptions:SetChecked(true)

-- --- BOTÓN LIMPIAR ---
    local globalClear = CreateFrame("Button", nil, chatWin, "UIPanelButtonTemplate")
    globalClear:SetSize(75, 22); globalClear:SetPoint("BOTTOMLEFT", 20, 12)
    globalClear:SetText(L["CLEAN_BTN"])
        
    globalClear:SetScript("OnClick", function()
        chatWin.text:Clear() 
        if chatWin.raidText then chatWin.raidText:Clear() end
        for k in pairs(history) do history[k] = {} end
        for _, k in ipairs(keywords) do 
            raidGroups[k] = {} 
            collapsed[k] = true 
        end
        UpdateRaidList() 
    end)

-- --- BOTON BB ---
    local lfgBtn = CreateFrame("Button", "PC_LFG_BlizzBtn", chatWin, "UIPanelButtonTemplate")
    lfgBtn:SetSize(65, 20)
    lfgBtn:SetPoint("LEFT", globalClear, "RIGHT", 1, 0)
    lfgBtn:SetText("Buscador")
        
    lfgBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["LFG_TOOLTIP_TITLE"] or "|cffA335EEBuscador de Bandas|r")
        GameTooltip:AddLine(L["LFG_TOOLTIP_DESC"] or "Haz clic para abrir el buscador original de Blizzard (/bb).", 1, 1, 1)
        GameTooltip:Show()
    end)
    lfgBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    lfgBtn:SetScript("OnClick", function()
        ToggleLFRParentFrame() 
    end)    

-- --- MINIMAPA ---
    local mm = CreateFrame("Button", "BDM_Minimap", Minimap)
        mm:SetSize(33, 33); mm:EnableMouse(true); mm:SetFrameStrata("MEDIUM")
        mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = mm:CreateTexture(nil, "BACKGROUND")
        icon:SetTexture("Interface\\Icons\\INV_Misc_Note_02")
        icon:SetSize(20, 20); icon:SetPoint("CENTER")

    local border = mm:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        border:SetSize(52, 52); border:SetPoint("TOPLEFT")
        mm:RegisterForDrag("LeftButton")
        mm:SetScript("OnDragStart", function(self) 
            self:SetScript("OnUpdate", function()
                local xpos, ypos = GetCursorPosition()
                local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
                local scale = Minimap:GetEffectiveScale()
                local x = (xmin + (Minimap:GetWidth()/2)) - (xpos/scale)
                local y = (ypos/scale) - (ymin + (Minimap:GetHeight()/2))
                ProChatDB.mmAngle = math.deg(math.atan2(y, x))
                UpdateMinimapPos()
            end) 
        end)

        mm:SetScript("OnDragStop", function(self) 
            self:SetScript("OnUpdate", nil) 
    end)

    -- Tooltip informativa
        mm:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cffA335EEProChat "..CURRENT_VERSION.."|r")
        GameTooltip:AddLine("Click: Mostrar/Ocultar\nArrastrar: Mover icono", 1, 1, 1)
        GameTooltip:Show()
    end)

        mm:SetScript("OnLeave", function() GameTooltip:Hide() 
    end)

    --- ICONO MINIMAPA
    mm:SetScript("OnClick", function(self)
        if IsControlKeyDown() then 
            if credWin then credWin:Show() end
        elseif IsShiftKeyDown() then
            self:Hide()
            if PC_CheckMM then PC_CheckMM:SetChecked(false) end
        else 
            if chatWin:IsVisible() then 
                chatWin:Hide()
                SaveWindowState(false)
            else 
                chatWin:Show()
                SaveWindowState(true)
            end 
        end
    end)

-- --- COMANDOS ---
    SLASH_PROCHAT1 = "/pc"; SLASH_PROCHAT2 = "/prochat"
    SlashCmdList["PROCHAT"] = function(msg)
        if msg == "reset" then
            if ProChatDB then
                ProChatDB.mmAngle = 45
                ProChatDB.showWindows = true
                ProChatDB.showRaidWin = true
                ProChatDB.uiScale = 1.0
                ProChatDB.fontSize = 12
                ProChatDB.filterTime = 60
                ProChatDB.hideGrays = false
                ProChatDB.showMinimap = true
                ProChatDB.showOptions = true
            end

            chatWin:ClearAllPoints()
            chatWin:SetPoint("CENTER")
            chatWin:SetSize(850, 420)
            chatWin:SetScale(1.0)
            if scaleSlider then scaleSlider:SetValue(1.0) end

            if fontSlider then
                fontSlider:SetValue(12)
                local font, _, flags = chatWin.text:GetFont()
                chatWin.text:SetFont(font, 12, flags)
                if chatWin.raidText then
                    chatWin.raidText:SetFont(font, 12, flags)
                end
            end

            filterTime = 60
            if timeDrop then UIDropDownMenu_SetText(timeDrop, "1min") end

            searchTerm = ""
            if searchBox then searchBox:SetText("") end

            for k in pairs(selectedDungeons) do selectedDungeons[k] = false end
            selectedDungeons["TODAS"] = true
            if filterDrop then 
                UIDropDownMenu_SetText(filterDrop, L["ALL_TEXT"] or "TODAS") 
            end

            for k in pairs(selectedChannels) do selectedChannels[k] = false end
            if chanDrop then 
                UIDropDownMenu_SetText(chanDrop, "0 " .. (L["CHANNELS_TEXT"] or "Canales")) 
            end

            if PC_CheckRaid and not PC_CheckRaid:GetChecked() then PC_CheckRaid:Click() end
            if PC_CheckGrays and PC_CheckGrays:GetChecked() then PC_CheckGrays:Click() end
            hideGrays = false
            if PC_CheckOptions and not PC_CheckOptions:GetChecked() then PC_CheckOptions:Click() end
            if PC_CheckMM and not PC_CheckMM:GetChecked() then PC_CheckMM:Click() end

            chatWin.text:Clear() 
            for k in pairs(history) do history[k] = {} end
            if chatWin.raidText then chatWin.raidText:Clear() end

            for _, k in ipairs(keywords) do 
                raidGroups[k] = {}
                collapsed[k] = true
            end

            UpdateMinimapPos()
            UpdateRaidList()
            RefreshChatWindow()
            RefreshWelcomeTexts()
            RefreshCreditsTexts()

            if welcomeWin then welcomeWin:Show() end
            chatWin:Show()
            chatWin.text:SetPoint("BOTTOMRIGHT", -210, 65)
        
            local resetMsg = (ProChatDB.lang == "es") 
                and "Reset completo. Todo ha vuelto a su estado original y las raids se han acoplado." 
                or "Reset complete. Everything has returned to its original state and raids have been collapsed."

            print("|cffA335EEProChat:|r " .. resetMsg)
        else 
            if chatWin:IsVisible() then 
                chatWin:Hide(); SaveWindowState(false)
            else 
                chatWin:Show(); SaveWindowState(true)
            end 
        end
    end

-- --- SLIDER DE ESCALA DE TEXTO ---
    local fontSlider = CreateFrame("Slider", "BDM_FontSlider", chatWin, "OptionsSliderTemplate")
        fontSlider:SetPoint("BOTTOM", chatWin, "BOTTOM", 0, 15) 
        fontSlider:SetWidth(140)
        fontSlider:SetHeight(17)
        fontSlider:SetMinMaxValues(8, 20)
        fontSlider:SetValueStep(1)
        fontSlider:SetValue(ProChatDB and ProChatDB.fontSize or 12)
        _G[fontSlider:GetName() .. "Text"]:SetText("Scale") 
        _G[fontSlider:GetName() .. "Low"]:SetText("")      
        _G[fontSlider:GetName() .. "High"]:SetText("")     

        fontSlider:SetScript("OnValueChanged", function(self, value)
            local size = math.floor(value)
            if chatWin.text then
                local font, _, flags = chatWin.text:GetFont()
                chatWin.text:SetFont(font, size, flags)
            end
            if chatWin.raidText then
                local rFont, _, rFlags = chatWin.raidText:GetFont()
                chatWin.raidText:SetFont(rFont, size, rFlags)
            end
            if ProChatDB then 
                ProChatDB.fontSize = size 
            end
        end)

        fontSlider:EnableMouseWheel(true)
        fontSlider:SetScript("OnMouseWheel", function(self, delta)
            self:SetValue(self:GetValue() + (delta > 0 and 1 or -1))
    end)


-- --- SELECTOR DE IDIOMA
    local langDrop = CreateFrame("Frame", "BDM_LangDrop", chatWin, "UIDropDownMenuTemplate")
        langDrop:SetPoint("TOPLEFT", 10, -8)
        UIDropDownMenu_SetWidth(langDrop, 80)

        UIDropDownMenu_Initialize(langDrop, function()
    local languages = {
        {text = "Español", value = "es"},
        {text = "English", value = "en"}
    }
    
    for _, lang in ipairs(languages) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = lang.text
        info.func = function(self)
            ProChatDB.lang = lang.value
            UIDropDownMenu_SetText(langDrop, lang.text)
            
            if lang.value == "es" then
                L["LANG_NAME"] = "Español"
                L["LANG_CHANGED"] = "Idioma cambiado a Español."
                L["TIME_CHANGED"] = "Tiempo de filtro cambiado a: "
                L["SELECT_CHAN"] = "Seleccionar canal:"
                L["SELECT_DUNGEON"] = "Seleccionar Mazmorra:"
                L["SELECT_SPAM"] = "Tiempo por msg:"
                L["SEARCH_LABEL"] = "Filtro:"
                L["CLEAN_BTN"] = "Limpiar"
                L["HIDE_GRAYS"] = "Ocultar Spam"
                L["SHOW_LEADERS"] = "Raids activas"
                L["CHANNELS_TEXT"] = "Canales"
                L["OPTIONS_CHECK"] = "Opciones"
                L["DUNGEONS_TEXT"] = "Mazmorras"
                L["LFG_BTN_TEXT"] = "Buscador"
                L["LFG_TOOLTIP_TITLE"] = "|cffA335EEBuscador de Bandas|r"
                L["LFG_TOOLTIP_DESC"] = "Haz clic para abrir el buscador original de Blizzard (/bb)."
                L["ALL_TEXT"] = "TODAS"
            else
                L["LANG_NAME"] = "English"
                L["LANG_CHANGED"] = "Language changed to English."
                L["TIME_CHANGED"] = "Filter time changed to: "
                L["SELECT_CHAN"] = "Select channel:"
                L["SELECT_DUNGEON"] = "Select Dungeon:"
                L["SELECT_SPAM"] = "Time per msg:"
                L["SEARCH_LABEL"] = "Search:"
                L["CLEAN_BTN"] = "Clear"
                L["HIDE_GRAYS"] = "Hide Spam"
                L["SHOW_LEADERS"] = "Active Raids"
                L["CHANNELS_TEXT"] = "Channels"
                L["OPTIONS_CHECK"] = "Options"
                L["DUNGEONS_TEXT"] = "Dungeons"
                L["LFG_BTN_TEXT"] = "LFG"
                L["LFG_TOOLTIP_TITLE"] = "|cffA335EERaid Browser|r"
                L["LFG_TOOLTIP_DESC"] = "Click to open the original Blizzard Raid Browser (/bb)."
                L["ALL_TEXT"] = "ALL"
            end

            if labelChan then labelChan:SetText(L["SELECT_CHAN"]) end
            if labelDung then labelDung:SetText(L["SELECT_DUNGEON"]) end
            if labelSpam then labelSpam:SetText(L["SELECT_SPAM"]) end
            if searchLabel then searchLabel:SetText(L["SEARCH_LABEL"]) end
            if chatWin.raidTitle then 
                chatWin.raidTitle:SetText("|cffA335EE" .. L["LEADERS_RAIDS"] .. "|r") 
            elseif BDM_RaidWinTitle then
                BDM_RaidWinTitle:SetText("|cffA335EE" .. L["LEADERS_RAIDS"] .. "|r")
            end
            if globalClear then globalClear:SetText(L["CLEAN_BTN"]) end
            if PC_CheckOptions then _G[PC_CheckOptions:GetName().."Text"]:SetText(L["OPTIONS_CHECK"]) end
            if PC_CheckGrays then _G[PC_CheckGrays:GetName().."Text"]:SetText(L["HIDE_GRAYS"]) end
            if PC_CheckRaid then _G[PC_CheckRaid:GetName().."Text"]:SetText(L["SHOW_LEADERS"]) end
            local chanCount = 0
            for k, v in pairs(selectedChannels) do if v then chanCount = chanCount + 1 end end
            if chanDrop then
                UIDropDownMenu_SetText(chanDrop, chanCount .. " " .. L["CHANNELS_TEXT"])
            end

            if filterDrop then
                if selectedDungeons["TODAS"] then
                    UIDropDownMenu_SetText(filterDrop, L["ALL_TEXT"] or "TODAS")
                else
                    local dungCount = 0
                    for k, v in pairs(selectedDungeons) do if v then dungCount = dungCount + 1 end end
                    UIDropDownMenu_SetText(filterDrop, dungCount .. " " .. L["DUNGEONS_TEXT"])
                end
            end

            if lfgBtn then 
                lfgBtn:SetText(L["LFG_BTN_TEXT"]) 
            end
            
            RefreshWelcomeTexts()
            RefreshCreditsTexts()

            if ProChatDB then ProChatDB.lang = lang.value end
                print("|cffA335EEProChat:|r " .. L["LANG_CHANGED"])
            end

        UIDropDownMenu_AddButton(info)

        end
    end)
    local currentLang = (ProChatDB and ProChatDB.lang == "en") and "English" or "Español"
    UIDropDownMenu_SetText(langDrop, currentLang)


-- --- BOTÓN BAJAR TODO ---
        BDM_ScrollBottom = CreateFrame("Button", "BDM_ScrollBottom", chatWin)
        BDM_ScrollBottom:SetSize(28, 28)
        BDM_ScrollBottom:SetPoint("BOTTOMRIGHT", chatWin, "BOTTOMRIGHT", -25, 40) 
        BDM_ScrollBottom:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up")
        BDM_ScrollBottom:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Down")
        BDM_ScrollBottom:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        BDM_ScrollBottom:SetFrameStrata("FULLSCREEN")
        BDM_ScrollBottom:Hide()
        
        BDM_ScrollBottom:SetScript("OnClick", function(self)
            if chatWin.text then chatWin.text:ScrollToBottom() end
            self:Hide()
        end)

-- --- ELEMENTOS QUE SE OCULTAN CON EL CHECKBOX DE OPCIONES ---
    local uiElements = {
        BDM_ChanDrop, BDM_FilterDrop, BDM_TimeDrop, BDM_LangDrop, 
        labelChan, labelDung, labelSpam,
        PC_CheckMM, PC_CheckGrays, PC_CheckRaid,
    }

    checkOptions:SetScript("OnClick", function(self)
        local isVisible = self:GetChecked()

        for _, element in ipairs(uiElements) do
            if element then
                if isVisible then element:Show() else element:Hide() end
            end
        end

        if isVisible then
            chatWin.text:SetPoint("TOPLEFT", 15, -125)
        else
            chatWin.text:SetPoint("TOPLEFT", 15, -45)
        end
    end)

-- --- DETECTOR DE IDIOMA --
        local function InitializeLanguage()
            if ProChatDB and ProChatDB.lang then return end
            local clientLocale = GetLocale()
            if clientLocale == "esES" or clientLocale == "esMX" then
                ProChatDB.lang = "es"
            else
                ProChatDB.lang = "en"
            end
        end

-- --- LISTENERs ---
    local listener = CreateFrame("Frame")
        listener:RegisterEvent("CHAT_MSG_CHANNEL")
        listener:RegisterEvent("CHAT_MSG_SAY")
        listener:RegisterEvent("CHAT_MSG_YELL")
        listener:RegisterEvent("CHAT_MSG_GUILD")
        listener:RegisterEvent("ADDON_LOADED")
        listener:RegisterEvent("PLAYER_ENTERING_WORLD")
        listener:RegisterEvent("PLAYER_REGEN_DISABLED")

        listener:SetScript("OnEvent", function(self, event, ...)

-- --- ADDON LOADED
        if event == "ADDON_LOADED" and select(1, ...) == "ProChat" then
            if not ProChatDB then ProChatDB = {} end
            if not ProChatDB.lang then
                local locale = GetLocale()
                ProChatDB.lang = (locale == "esES" or locale == "esMX") and "es" or "en"
            end
        
            if ProChatDB.lang == "es" then
                L["LANG_NAME"] = "Español"; 
                L["SELECT_CHAN"] = "Seleccionar canales:"; 
                L["SELECT_DUNGEON"] = "Seleccionar mazmorra:"; 
                L["SELECT_SPAM"] = "Tiempo por msg:"; 
                L["SEARCH_LABEL"] = "Filtro:"; 
                L["CLEAN_BTN"] = "Limpiar"; 
                L["HIDE_GRAYS"] = "Ocultar Spam"; 
                L["SHOW_LEADERS"] = "Raids Activas"; 
                L["CHANNELS_TEXT"] = "Canales"; 
                L["OPTIONS_CHECK"] = "Opciones"; 
                L["TIME_CHANGED"] = "Tiempo de filtro cambiado a: "; 
                L["DUNGEONS_TEXT"] = "Mazmorras"; 
                L["LFG_BTN_TEXT"] = "Buscador"; L["ALL_TEXT"] = "TODAS"
                L["START_MSG"] = "Cargado. Versión"
                L["STATUS_TXT"] = "Estado: |cff00ff00Addon Actualizado|r."
                L["COMBAT_MSG"] = "Ventana ocultada por combate."
                L["WELCOME_TITLE"] = "|cffA335EE¡Gracias por descargar ProChat!|r"
                L["WELCOME_TEXT"] = "Tu asistente de búsqueda de mazmorras ha sido instalado correctamente.\n\nEstado: |cff00ff00Addon Actualizado|r\nVersión: |cffFFD100" .. CURRENT_VERSION .. "\r\n\nUsa |cffFFD100/pc|r para empezar a filtrar el chat masivo."
                L["WELCOME_BTN"] = "Entendido"
            else
                L["LANG_NAME"] = "English"; 
                L["SELECT_CHAN"] = "Select channels:"; 
                L["SELECT_DUNGEON"] = "Select dungeon:"; 
                L["SELECT_SPAM"] = "Time per msg:"; 
                L["SEARCH_LABEL"] = "Search:"; 
                L["CLEAN_BTN"] = "Clear"; 
                L["HIDE_GRAYS"] = "Hide Spam"; 
                L["SHOW_LEADERS"] = "Active Raids"; 
                L["CHANNELS_TEXT"] = "Channels"; 
                L["OPTIONS_CHECK"] = "Options"; 
                L["TIME_CHANGED"] = "Filter time changed to: "; 
                L["DUNGEONS_TEXT"] = "Dungeons"; 
                L["LFG_BTN_TEXT"] = "LFG"; L["ALL_TEXT"] = "ALL"
                L["START_MSG"] = "Loaded. Version"
                L["STATUS_TXT"] = "Status: |cff00ff00Addon Updated|r."
                L["COMBAT_MSG"] = "Window hidden due to combat."
                L["WELCOME_TITLE"] = "|cffA335EEThanks for downloading ProChat!|r"
                L["WELCOME_TEXT"] = "Your dungeon search assistant has been successfully installed.\n\nStatus: |cff00ff00Addon Updated|r\nVersion: |cffFFD100" .. CURRENT_VERSION .. "\r\n\nUse |cffFFD100/pc|r to start filtering the massive chat."
                L["WELCOME_BTN"] = "Got it"
            end

            RefreshWelcomeTexts()
            RefreshCreditsTexts()
        
            if labelChan then labelChan:SetText(L["SELECT_CHAN"]) end
            if labelDung then labelDung:SetText(L["SELECT_DUNGEON"]) end
            if labelSpam then labelSpam:SetText(L["SELECT_SPAM"]) end
            if searchLabel then searchLabel:SetText(L["SEARCH_LABEL"]) end
            if globalClear then globalClear:SetText(L["CLEAN_BTN"]) end
            if lfgBtn then lfgBtn:SetText(L["LFG_BTN_TEXT"]) end
            if PC_CheckGrays then _G[PC_CheckGrays:GetName().."Text"]:SetText(L["HIDE_GRAYS"]) end
            if PC_CheckRaid then _G[PC_CheckRaid:GetName().."Text"]:SetText(L["SHOW_LEADERS"]) end
            if PC_CheckOptions then _G[PC_CheckOptions:GetName().."Text"]:SetText(L["OPTIONS_CHECK"]) end

            if langDrop then
                UIDropDownMenu_SetText(langDrop, (ProChatDB.lang == "es" and "Español" or "English"))
            end

            ProChatDB.mmAngle = ProChatDB.mmAngle or 45
            ProChatDB.showWindows = (ProChatDB.showWindows == nil) and true or ProChatDB.showWindows
            ProChatDB.showRaidWin = (ProChatDB.showRaidWin == nil) and true or ProChatDB.showRaidWin

            hideGrays = ProChatDB.hideGrays or false
            filterTime = ProChatDB.filterTime or 60

            if ProChatDB.firstRun == nil then 
                if welcomeWin then welcomeWin:Show() end
                ProChatDB.firstRun = false 
            end

            UpdateMinimapPos()

            if ProChatDB.showWindows then 
                chatWin:Show()
                if PC_CheckRaid then
                    PC_CheckRaid:SetChecked(ProChatDB.showRaidWin)
                    local script = PC_CheckRaid:GetScript("OnClick")
                    if script then script(PC_CheckRaid) end
                end
            else 
                chatWin:Hide()
            end

            if ProChatDB.uiScale then
                chatWin:SetScale(ProChatDB.uiScale)
                if scaleSlider then scaleSlider:SetValue(ProChatDB.uiScale) end
            else
                ProChatDB.uiScale = 1.0
            end

            RefreshWelcomeTexts()
            RefreshCreditsTexts()
-- --- MENSAJE DE VERSION EN EL CHAT ---
        elseif event == "PLAYER_ENTERING_WORLD" then
            local msgInicio = L["START_MSG"] or "Cargado. Versión"
            local statusText = L["STATUS_TXT"] or "Estado: |cff00ff00Addon Actualizado|r."
        print("|cffA335EEProChat:|r " .. msgInicio .. " |cffffffff"..CURRENT_VERSION.."|r. " .. statusText)

        elseif event == "PLAYER_REGEN_DISABLED" then
            if chatWin:IsVisible() then
                chatWin:Hide()
                SaveWindowState(false)
                
                local combatMsg = L["COMBAT_MSG"] or "Ventana ocultada por combate."
                print("|cffA335EEProChat:|r " .. combatMsg)
            end
-- --- FUNCION DE PROCHAT ---
        elseif event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_GUILD" then
            local msg, sender, _, _, _, _, _, _, chanName, _, _, guid = ...

            if sender then sender = strsplit("-", sender) end

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
            local currentFilterLimit = filterTime or 60
            local puedeMostrar = false
            if not userMessages[sender] or (now - userMessages[sender].time >= currentFilterLimit) then
                puedeMostrar = true
            end

            if puedeMostrar then
                local msgU = msg:upper()
                local matched = nil
                for _, k in ipairs(keywords) do 
                    if string.find(" "..msgU.." ", "[^%a]"..k.."[^%a]") then matched = k; break end 
                end

                local cat = matched or "TODAS"
                local c = filterColors[cat]
                local nameColor = c
                
                if guid then
                    local _, classUpper = GetPlayerInfoByGUID(guid)
                    if classUpper and classColors[classUpper] then
                        nameColor = classColors[classUpper]
                        PC_ClassCache[sender] = nameColor
                    end
                end

                local cleanName = chanName:gsub("%d+%.%s*", ""):upper()
                local tagData = channelTags[cleanName] or {t=string.sub(cleanName,1,1), c="ffffff"}
                local dungeonTag = matched and (" |cff"..c.."["..matched.."]|r") or ""

                local formatted = "|cff"..tagData.c.."["..tagData.t.."]|r |cff"..c.."[|r|Hplayer:"..sender.."|h|cff"..nameColor..sender.."|r|h|cff"..c.."]|r"..dungeonTag..": "..msg

                table.insert(history["TODAS"], formatted)
                if matched then 
                    table.insert(history[matched], formatted)
                    raidGroups[matched][sender] = true
                    UpdateRaidList()
                end

                local mostrarPorDungeon = selectedDungeons["TODAS"] or (matched and selectedDungeons[matched])

                if mostrarPorDungeon then
                    local mostrarPorTermino = false
                    if searchTerm == "" then
                        mostrarPorTermino = true
                    else
                        for word in searchTerm:gmatch("%S+") do
                            if string.find(formatted:upper(), word:upper(), 1, true) then
                                mostrarPorTermino = true
                                break
                            end
                        end
                    end

                    if mostrarPorTermino then
                        if not hideGrays or matched then 
                            chatWin.text:AddMessage(formatted) 
                        end
                    end
                end
                userMessages[sender] = { time = now, msg = msg }
            end
        end
    end)
