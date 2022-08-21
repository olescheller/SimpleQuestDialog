function table.tostring(anyObject, depth)
    depth = depth or -1
    local result = tostring(anyObject)
    if depth ~= 0 and type(anyObject) == 'table' then
        local elementArray = {}
        for k, v in pairs(anyObject) do
            table.insert(elementArray, '(' .. tostring(k) .. ', ' .. table.tostring(v, depth - 1) .. ')')
        end
        result = '{' .. table.concat(elementArray, ', ') .. '}'
    end
    return result
end

function table.print(anyObject, depth)
    print(table.tostring(anyObject, depth))
end

local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");

-- Globals Section
SimpleQuestDialog_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)


local f = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate");
f:SetFrameStrata("Tooltip")

f:SetPoint("BOTTOMLEFT", UIParent, 0, 0)
local t = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
local t2 = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
t:SetPoint("CENTER", 0, 0)
t2:SetPoint("BOTTOMRIGHT", 0, -10)
t:SetText("Click to accept")
t2:SetText("by SimpleQuestDialog")
t2:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")

f:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 } });
f:SetBackdropColor(0, 0, 0, 1);
f:SetWidth(t:GetStringWidth() + 20)
f:SetHeight(t:GetStringHeight() + 20)

local function resizeTooltip()
    f:SetWidth(t:GetStringWidth() + 20)
    f:SetHeight(t:GetStringHeight() + 20)
end

local function OnDoubleClick(self, button)
    LFGListSearchPanel_SignUp(self:GetParent():GetParent():GetParent())
end

local function OnDoubleClickPlayer(self, button)
    C_PartyInfo.LeaveParty()
end

local function OnClickQuestDetailScrollFrame(self, button)
    AcceptQuest()
end

local function OnClickQuestRewardScrollFrame(self, button)
    if ( GetNumQuestChoices() == 1 ) then
		QuestInfoFrame.itemChoice = 1;
	end
    if (QuestInfoFrame.itemChoice ~= nil) then
        GetQuestReward(QuestInfoFrame.itemChoice)
    end
end

local function OnClickGossipGreetingScrollFrame(self, button)
    local numberQuests = C_GossipInfo.GetNumAvailableQuests()
    print("GetNumAvailableQuests" .. numberQuests)
    print("GetNumAvailableQuests() " .. GetNumAvailableQuests())
    if (numberQuests > 0) then
        C_GossipInfo.SelectAvailableQuest(1)
    else
        local numberActiveQuests = C_GossipInfo.GetNumActiveQuests()
        print("GetNumActiveQuests" .. numberActiveQuests)
        print("GetNumActiveQuests() " .. GetNumActiveQuests())
        local info = C_GossipInfo.GetActiveQuests()
        for i = 1, numberActiveQuests, 1 do
            local isComplete = info[i]['isComplete']
            if isComplete then
                C_GossipInfo.SelectActiveQuest(i)
                break
            end
        end
    end
end

local function OnClickQuestGreetingScrollFrame(self, button)
    local numberQuests = GetNumAvailableQuests()
    if (numberQuests > 0) then
        SelectAvailableQuest(1)
    else
        local numberActiveQuests = GetNumActiveQuests()
        for i = 1, numberActiveQuests, 1 do
            local title, isComplete = GetActiveTitle(i);
            if isComplete then
                SelectActiveQuest(i)
                break
            end
        end
    end
end

local function OnClickQuestProgressScrollFrame(self, button)
    QuestFrameCompleteButton:Click()
end

local function getIndexOfTopFinishedActiveQuest()
    local numberActiveQuests = C_GossipInfo.GetNumActiveQuests()
    local info = C_GossipInfo.GetActiveQuests()
    for i = 1, numberActiveQuests, 1 do
        local isComplete = info[i]['isComplete']
        if isComplete then
            return i
        end
    end
end

local function getIndexOfTopFinishedActiveQuest_OLD_API()
    local numberActiveQuests = GetNumActiveQuests()
    for i = 1, numberActiveQuests, 1 do
        local title, isComplete = GetActiveTitle(i);
        if isComplete then
            return i
        end
    end
    return nil
end

local function getActiveQuestInfo(index)
    local info = C_GossipInfo.GetActiveQuests()
    return info[index]["title"], info[index]["isComplete"], info[index]["isLegendary"],
        info[index]["frequency"], info[index]["isRepeatable"], info[index]["isCampaign"],
        info[index]["isConvenantCalling"]
end

local function getActiveQuestInfo_OLD_API(index)
    local title, isComplete = GetActiveTitle(index);
    local isTrivial, frequency, isRepeatable, isLegendary, questID = GetAvailableQuestInfo(index)
    local activeQuestID = GetActiveQuestID(index);
    return title, isComplete, isLegendary,
    frequency, isRepeatable,  QuestUtil.ShouldQuestIconsUseCampaignAppearance(activeQuestID), C_QuestLog.IsQuestCalling(activeQuestID)
end

local function getAvailableQuestInfo(index)
    local info = C_GossipInfo.GetAvailableQuests()
    return info[index]["title"], info[index]["isLegendary"],
        info[index]["frequency"], info[index]["isRepeatable"], info[index]["isCampaign"],
        info[index]["isConvenantCalling"]
end

local function getAvailableQuestInfo_OLD_API(index)
    local title, isComplete = GetAvailableTitle(index);
    local isTrivial, frequency, isRepeatable, isLegendary, questID = GetAvailableQuestInfo(index)
    return title, isLegendary, frequency, isRepeatable, QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID),
        C_QuestLog.IsQuestCalling(questID)
end

local function init()
    for _, button in pairs(LFGListFrame.SearchPanel.ScrollFrame.buttons) do
        button:SetScript("OnDoubleClick", OnDoubleClick)
    end
    PlayerFrame:SetScript("OnDoubleClick", OnDoubleClickPlayer)
    QuestDetailScrollFrame:SetScript("OnMouseDown", OnClickQuestDetailScrollFrame)
    QuestRewardScrollFrame:SetScript("OnMouseDown", OnClickQuestRewardScrollFrame)
    GossipGreetingScrollFrame:SetScript("OnMouseDown", OnClickGossipGreetingScrollFrame)
    QuestFrameGreetingPanel:GetParent():SetScript("OnMouseDown", OnClickQuestGreetingScrollFrame)
    QuestProgressScrollFrame:SetScript("OnMouseDown", OnClickQuestProgressScrollFrame)
end

function frame:OnEvent(event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "SimpleQuestDialog" then
        init()
    end

end

-- Functions Section
function SimpleQuestDialog_OnUpdate(self, elapsed)

    local scale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition();
    local isOverDetail = MouseIsOver(QuestDetailScrollFrame) and QuestDetailScrollFrame:IsVisible()
    local isOverGossip = MouseIsOver(GossipGreetingScrollFrame) and GossipGreetingScrollFrame:IsVisible()
    local isOverQuestGreeting = MouseIsOver(QuestGreetingScrollFrame) and QuestGreetingScrollFrame:IsVisible()
    local isOverReward = MouseIsOver(QuestRewardScrollFrame) and QuestRewardScrollFrame:IsVisible()
    local isOverQuestProgress = MouseIsOver(QuestProgressScrollFrame) and QuestProgressScrollFrame:IsVisible()

    if isOverDetail then
        t:SetText("Click to accept")
        resizeTooltip()
        f:Show()
        f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
    elseif isOverQuestProgress then
        t:SetText("Click to continue")
        resizeTooltip()
        f:Show()
        f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
    elseif isOverQuestGreeting then
        local activeQuestIndex = getIndexOfTopFinishedActiveQuest_OLD_API()
            if(activeQuestIndex ~= nil) then
                local activeQuestName, isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling = getActiveQuestInfo_OLD_API(activeQuestIndex)
                t:SetText("Click to select " ..
                    "|T" ..
                    QuestUtil.GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign,
                        isCovenantCalling) .. ":16:16:0:0:64:64:4:60:4:60|t " .. activeQuestName .. "")
                resizeTooltip()
                f:Show()
                f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
        
        else if GetNumAvailableQuests() > 0 then
                local availableQuestName, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling = getAvailableQuestInfo_OLD_API(1)
                t:SetText("Click to select " ..
                    "|T" ..
                    QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling) ..
                    ":16:16:0:0:64:64:4:60:4:60|t " .. availableQuestName .. "")
                resizeTooltip()
                f:Show()
                f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
            end
        end 
    elseif isOverGossip then
        if C_GossipInfo.GetNumActiveQuests() > 0 then
            local activeQuestIndex = getIndexOfTopFinishedActiveQuest()
            local activeQuestName, isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling = getActiveQuestInfo(activeQuestIndex)
            t:SetText("Click to select " ..
                "|T" ..
                QuestUtil.GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign,
                    isCovenantCalling) .. ":16:16:0:0:64:64:4:60:4:60|t " .. activeQuestName .. "")
            resizeTooltip()
            f:Show()
            f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
        else if C_GossipInfo.GetNumAvailableQuests() > 0 then
                local availableQuestName, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling = getAvailableQuestInfo(1)
                t:SetText("Click to select " ..
                    "|T" ..
                    QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling) ..
                    ":16:16:0:0:64:64:4:60:4:60|t " .. availableQuestName .. "")
                resizeTooltip()
                f:Show()
                f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
            end
        end
    elseif isOverReward then
        if QuestInfoFrame.itemChoice ~= nil then
            t:SetText("Click to complete")
        else
            t:SetText("Select reward")
        end
        resizeTooltip()
        f:Show()
        f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
    else
        f:Hide()
    end
end

frame:SetScript("OnUpdate", SimpleQuestDialog_OnUpdate)

frame:SetScript("OnEvent", frame.OnEvent)
