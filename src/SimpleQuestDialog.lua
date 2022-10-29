local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("GOSSIP_SHOW");
frame:RegisterEvent("QUEST_GREETING");

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

-- Globals Section
SimpleQuestDialog_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)


local f = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate");
f:SetFrameStrata("Tooltip")

f:SetPoint("BOTTOMLEFT", UIParent, 0, 0)
local t = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
local t2 = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
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
    print("OnClickGossipGreetingScrollFrame")
    local numberQuests = C_GossipInfo.GetNumAvailableQuests()
    if (numberQuests > 0) then
        C_GossipInfo.SelectAvailableQuest(1)
    else
        local numberActiveQuests = C_GossipInfo.GetNumActiveQuests()
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

local function OnClickGossipFrame(self, button)
    print("OnClickGossipFrame")
    local availableQuests = C_GossipInfo.GetAvailableQuests()
    if (#availableQuests > 0) then 
        C_GossipInfo.SelectAvailableQuest(availableQuests[1].questID)
    else
        local numberActiveQuests = C_GossipInfo.GetNumActiveQuests()
        local info = C_GossipInfo.GetActiveQuests()
        for i = 1, numberActiveQuests, 1 do
            local isComplete = info[i]['isComplete']
            if isComplete then
                C_GossipInfo.SelectActiveQuest(info[i].questID)
                break
            end
        end
    end
end


local function OnClickQuestGreetingScrollFrame(self, button)
    print("OnClickQuestGreetingScrollFrame")
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
    frequency, isRepeatable,  QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID), C_QuestLog.IsQuestCalling(questID)
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
end

function frame:OnEvent(event, arg1, ...) 
    if event == "ADDON_LOADED" and arg1 == "SimpleQuestDialog" then
        -- init()
    elseif event == "GOSSIP_SHOW" then
    elseif event == "QUEST_GREETING" then
    end
end

local isPlayerFrameInitialized = false
local isQuestDetailScrollFrameInitialized = false
local isQuestRewardScrollFrameInitialized = false
local isGossipGreetingScrollFrameInitialized = false
local isGossipFrameInitialized = false
local isQuestFrameGreetingPanelInitialized = false
local isQuestProgressScrollFrameInitialized = false
local isQuestGreetingScrollFrameInitialized = false

-- Functions Section
function SimpleQuestDialog_OnUpdate(self, elapsed)
    if not isPlayerFrameInitialized and PlayerFrame ~= nil then
        PlayerFrame:SetScript("OnMouseDown", OnDoubleClickPlayer)
        isPlayerFrameInitialized = true
    end    
    if not isQuestDetailScrollFrameInitialized and QuestDetailScrollFrame ~= nil then
        QuestDetailScrollFrame:SetScript("OnMouseDown", OnClickQuestDetailScrollFrame)
        isQuestDetailScrollFrameInitialized = true
    end    
    if not isQuestRewardScrollFrameInitialized and QuestRewardScrollFrame ~= nil then
        QuestRewardScrollFrame:SetScript("OnMouseDown", OnClickQuestRewardScrollFrame)
        isQuestRewardScrollFrameInitialized = true
    end
    if not isGossipGreetingScrollFrameInitialized and GossipGreetingScrollFrame ~= nil then
        GossipGreetingScrollFrame:SetScript("OnMouseDown", OnClickGossipGreetingScrollFrame)
        isGossipGreetingScrollFrameInitialized = true
    end
    if not isGossipFrameInitialized and GossipFrame.GreetingPanel.ScrollBox ~= nil then
        GossipFrame.GreetingPanel.ScrollBox:SetScript("OnMouseDown", OnClickGossipFrame)
        isGossipFrameInitialized = true
    end    
    if not isQuestFrameGreetingPanelInitialized and QuestFrameGreetingPanel ~= nil then
        QuestFrameGreetingPanel:SetScript("OnMouseDown", OnClickQuestFrameGreetingPanel)
        isQuestFrameGreetingPanelInitialized = true
    end
    if not isQuestGreetingScrollFrameInitialized and QuestGreetingScrollFrame ~= nil then
        QuestGreetingScrollFrame:SetScript("OnMouseDown", OnClickQuestGreetingScrollFrame)
        isQuestGreetingScrollFrameInitialized = true
    end
    if not isQuestProgressScrollFrameInitialized and QuestProgressScrollFrame ~= nil then
        QuestProgressScrollFrame:SetScript("OnMouseDown", OnClickQuestProgressScrollFrame)
        isQuestProgressScrollFrameInitialized = true
    end 


    local scale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition();
    local isOverDetail = QuestDetailScrollFrame ~= nil and MouseIsOver(QuestDetailScrollFrame) and QuestDetailScrollFrame:IsVisible()
    local isOverGossip = GossipGreetingScrollFrame ~= nil and MouseIsOver(GossipGreetingScrollFrame) and GossipGreetingScrollFrame:IsVisible()
    local isOverGossipFrame = GossipFrame.GreetingPanel.ScrollBox ~= nil and MouseIsOver(GossipFrame.GreetingPanel.ScrollBox) and GossipFrame.GreetingPanel.ScrollBox:IsVisible()
    local isOverQuestGreeting = QuestGreetingScrollFrame ~= nil and MouseIsOver(QuestGreetingScrollFrame) and QuestGreetingScrollFrame:IsVisible()
    local isOverReward = QuestRewardScrollFrame ~= nil and MouseIsOver(QuestRewardScrollFrame) and QuestRewardScrollFrame:IsVisible()
    local isOverQuestProgress = QuestProgressScrollFrame ~= nil and MouseIsOver(QuestProgressScrollFrame) and QuestProgressScrollFrame:IsVisible()
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
        print("isOverQuestGreeting")
        -- print("isOverQuestGreeting")
        -- local activeQuestIndex = getIndexOfTopFinishedActiveQuest_OLD_API()
        --     if(activeQuestIndex ~= nil) then
        --         local activeQuestName, isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling = getActiveQuestInfo_OLD_API(activeQuestIndex)
        --         t:SetText("Click to select " ..
        --             "|T" ..
        --             QuestUtil.GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign,
        --                 isCovenantCalling) .. ":16:16:0:0:64:64:4:60:4:60|t " .. activeQuestName .. "")
        --         resizeTooltip()
        --         f:Show()
        --         f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
        
        -- else if GetNumAvailableQuests() > 0 then
        --         local availableQuestName, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling = getAvailableQuestInfo_OLD_API(1)
        --         t:SetText("Click to select " ..
        --             "|T" ..
        --             QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling) ..
        --             ":16:16:0:0:64:64:4:60:4:60|t " .. availableQuestName .. "")
        --         resizeTooltip()
        --         f:Show()
        --         f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
        --     end
        -- end 
    elseif isOverGossip or isOverGossipFrame then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        
        local activeQuestIndex = getIndexOfTopFinishedActiveQuest()
        if #activeQuests > 0 and activeQuestIndex ~= nil then
            t:SetText("Click to select " ..
                "|T" ..
                GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign,
                    isCovenantCalling) .. ":16:16:0:0:64:64:4:60:4:60|t " .. activeQuestName .. "")
            resizeTooltip()
            f:Show()
            f:SetPoint("BOTTOMLEFT", UIParent, x / scale + 10, y / scale)
        else if #availableQuests > 0 then
                local q = availableQuests[1]
                t:SetText("Click to select " ..
                    "|T" ..
                    GetQuestIconOfferForQuestID(q.questID) ..
                    ":16:16:0:0:64:64:4:60:4:60|t " .. q.title)

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

function GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling)
	if isLegendary then
		return "Interface/GossipFrame/AvailableLegendaryQuestIcon", false;
	elseif isCampaign then
		return "Interface/GossipFrame/CampaignAvailableQuestIcon", true;
	elseif isCovenantCalling then
		return "Interface/GossipFrame/CampaignAvailableDailyQuestIcon", true;
	elseif frequency == Enum.QuestFrequency.Daily then
		return "Interface/GossipFrame/DailyQuestIcon", false;
	elseif isRepeatable then
		return "Interface/GossipFrame/DailyActiveQuestIcon", false;
	end

	return "Interface/GossipFrame/AvailableQuestIcon", false;
end

function GetQuestIconOfferForQuestID(questID)
	local quest = QuestCache:Get(questID);
	return GetQuestIconOffer(quest.isLegendary, quest.frequency, quest.isRepeatable, ShouldQuestIconsUseCampaignAppearance(questID));
end

function ShouldQuestIconsUseCampaignAppearance(questID)
	local quest = QuestCache:Get(questID);
	if quest:IsCampaign() then
		return not CampaignCache:Get(quest:GetCampaignID()):UsesNormalQuestIcons();
	end

	return false;
end