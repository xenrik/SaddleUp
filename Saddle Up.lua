local SaddleUpDefaults = {
    preferFlying = true,
    includeFlightForm = true,
    showDebug = true
}

local printDebug = function(msg)
    if SaddleUpOptions.showDebug == true then
        print(msg)
    end
end

local SaddleUp = function()
    local mountIds = C_MountJournal.GetMountIDs();
    local allUsableMounts = {}
    local flyingMounts = {}
    local favoriteMounts = {}
    local favoriteFlyingMounts = {}    
    for i = 1, C_MountJournal.GetNumMounts() do
        local _, _, _, _, isUsable, _, isFavorite = C_MountJournal.GetMountInfoByID(mountIds[i])
        local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountIds[i])
        if isUsable then
            table.insert(allUsableMounts, mountIds[i])
            if mountType == 248 then
                table.insert(flyingMounts, mountIds[i])
            end

            if isFavorite then
                table.insert(favoriteMounts, mountIds[i])
                if mountType == 248 then
                    table.insert(favoriteFlyingMounts, mountIds[i])
                end
            end
        end
    end

    printDebug("You have " .. #allUsableMounts .. " usable mounts")    
    printDebug("You have " .. #flyingMounts .. " flying mounts")    
    printDebug("You have " .. #favoriteMounts .. " favorite mounts")
    printDebug("You have " .. #favoriteFlyingMounts .. " favorite flying mounts")    
    

    -- We only include flight form if we have at least one flying mount. This is because IsFlyableArea lies!
    -- The exception is Dalaran where you can use flight form, but not flying mounts!
    local zoneId = C_Map.GetBestMapForUnit("player")
    local includeFlightForm = #flyingMounts > 0 or zoneId == 125
    local _, _, classId = UnitClass("player")

    if SaddleUpOptions.includeFlightForm and classId == 11 and includeFlightForm == true then
        printDebug("Druid flight form is included")
        table.insert(allUsableMounts, -1)
        table.insert(flyingMounts, -1)

        if #favoriteMounts > 0 then
            table.insert(favoriteMounts, -1)
            table.insert(favoriteFlyingMounts, -1)
        end
    end

    local id = 0
    if SaddleUpOptions.preferFlying == true and #favoriteFlyingMounts > 0 then        
        printDebug("Using a preferred flying mount")
        id = favoriteFlyingMounts[math.random(#favoriteFlyingMounts)]  
    elseif SaddleUpOptions.preferFlying == true and #flyingMounts > 0 then
        printDebug("Using a flying mount")
        id = flyingMounts[math.random(#flyingMounts)]
    elseif #favoriteMounts > 0 then
        printDebug("Using a favorite mount")
        id = favoriteMounts[math.random(#favoriteMounts)]
    else
        printDebug("Using an available mount")
        id = allUsableMounts[math.random(#allUsableMounts)]
    end

    if id == -1 then
        -- Do nothing
        printDebug("Do Nothing --- DRUID FORM!")
    else
        C_MountJournal.SummonByID(id)
    end
end

local frame = CreateFrame("Frame")

function frame:OnEvent(event, addonName)
    if addonName == "Saddle Up" then
        SaddleUpOptions = SaddleUpOptions or {}
        self.SaddleUpOptions = SaddleUpOptions
        self:InitialiseOptions()
        for k, v in pairs(SaddleUpDefaults) do
            if self.SaddleUpOptions[k] == nil then
                self.SaddleUpOptions[k] = v
            end
        end
    elseif addonName == "Blizzard_Collections" then
        local button = CreateFrame("Button", "SummonRandomMountButton", MountJournal, "UIPanelButtonTemplate")
        button:SetSize(36, 36)
        button:SetPoint("TOPRIGHT", MountJournal, "TOPRIGHT", -7, -25)
        button:SetNormalTexture(413588)
        
        local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("RIGHT", button, "LEFT", 0, 0)
        label:SetText("Summon Random Mount")
        label:SetTextColor(1, 1, 1)
        label:SetJustifyH("RIGHT")
        button:SetScript("OnClick", SaddleUp)
    end
end

function frame:InitialiseOptions() 
    self.panel = CreateFrame("Frame")
    self.panel.name = "Saddle Up"

    local preferFlyingCB = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
    preferFlyingCB:SetPoint("TOPLEFT", 20, -20)
    preferFlyingCB.Text:SetText("Prefer Flying Mounts when they are usable")
    preferFlyingCB:SetChecked(self.SaddleUpOptions.preferFlying)
    preferFlyingCB:HookScript("OnClick", function(_, btn, down)
        self.SaddleUpOptions.preferFlying = not self.SaddleUpOptions.preferFlying
    end)
    
    local includeFlightFormCB = CreateFrame("CheckButton", nil, preferFlyingCB, "InterfaceOptionsCheckButtonTemplate")
    includeFlightFormCB:SetPoint("BOTTOMLEFT", 0, -50)
    includeFlightFormCB.Text:SetText("Allow Druid Flight Form as a flying mount")
    includeFlightFormCB:SetChecked(self.SaddleUpOptions.includeFlightForm)
    includeFlightFormCB:HookScript("OnClick", function(_, btn, down)
        self.SaddleUpOptions.includeFlightForm = not self.SaddleUpOptions.includeFlightForm
    end)

    local includeFlightFormText = CreateFrame("Frame", nil, preferFlyingCB)
    includeFlightFormText:SetSize(200, 24)
    includeFlightFormText:SetPoint("TOPLEFT", 30, -60)
    includeFlightFormText.text = includeFlightFormText:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    includeFlightFormText.text:SetPoint("TOPLEFT", includeFlightFormText, "BOTTOMLEFT", 0, 0)
    includeFlightFormText.text:SetText("Note - This addon cannot actually trigger flight form as that is a restricted operation\nTherefore if you check this option the addon will randomly 'do nothing' so you can setup\na Macro to switch to flight form. Click the button below if you want a macro created for you")
    includeFlightFormText.text:SetJustifyH("LEFT")

    local createDruidMacroButton = CreateFrame("Button", nil, includeFlightFormText, "UIPanelButtonTemplate")
    createDruidMacroButton:SetPoint("BOTTOMLEFT", 0, -70)
    createDruidMacroButton:SetSize(160, 24)
    createDruidMacroButton.Text:SetText("Generate Druid Macro")
    createDruidMacroButton:HookScript("OnClick", function(_, btn, down)
        CreateMacro("SaddleUp", "INV_MISC_QUESTIONMARK", [[#showtooltip
/SaddleUp
/cancelform
/cast [swimming]Aquatic Form
/cast [nocombat,nomod]Swift Flight Form
/cast Travel Form]], 1)
        print "Macro 'SaddleUp' Created!"
    end)

    local showDebugCB = CreateFrame("CheckButton", nil, createDruidMacroButton, "InterfaceOptionsCheckButtonTemplate")
    showDebugCB:SetPoint("BOTTOMLEFT", -30, -50)
    showDebugCB.Text:SetText("Show Debug Messages")
    showDebugCB:SetChecked(self.SaddleUpOptions.showDebug)
    showDebugCB:HookScript("OnClick", function(_, btn, down)
        self.SaddleUpOptions.showDebug = not self.SaddleUpOptions.showDebug
    end)

    InterfaceOptions_AddCategory(self.panel)
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", frame.OnEvent)

SLASH_SADDLEUP1 = "/SaddleUp"
SlashCmdList.SADDLEUP = SaddleUp