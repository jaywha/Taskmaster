message('Debug mode is enabled.')
message('WoWHead Pathfinder will attempt to link and be shown as a quest.')


function dump(o) -- From https://stackoverflow.com/a/27028488/7476183
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

local Congratz_EventFrame = CreateFrame("Frame")
Congratz_EventFrame:RegisterEvent("PLAYER_LEVEL_UP")

Congratz_EventFrame:SetScript("OnEvent", 
function(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
    print('Congratulations on reaching level ' ..arg1..', ' .. UnitName("Player").. '! You gained ' ..arg2.. ' HP and ' ..arg3.. ' MP!')
end)

local QuestTarget_EventFrame = CreateFrame("Frame")
QuestTarget_EventFrame:RegisterEvent("QUEST_LOG_UPDATE")

QuestTarget_EventFrame:SetScript("OnEvent",
function(self, event, ...)
    -- print('Quest log update registered!')
    local i = 1
    local distance = nil
    while distance == nil do
        distance = GetDistanceSqToQuest(i)
        i = i + 1
        if i > GetNumQuestLogEntries() then break end
    end
    --print('Distance to closest quest objective = ' .. tostring(distance))
end)

-- From https://us.battle.net/forums/en/wow/topic/8796521407#post-2 with udpates
-- create a frame where we put our stuff
local f=CreateFrame("Frame")
f:SetSize(288,150)
f.text = 
f:CreateFontString(nil,"ARTWORK","QuestFont_Shadow_Small")
f.text:SetAllPoints(true)
f.text:SetJustifyH("LEFT")
f.text:SetJustifyV("TOP")
f.text:SetTextColor(0,0,0,1)

local function updateDetailFrame()
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency,
    questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory =
    GetQuestLogTitle(GetQuestLogSelection())

    local CurrentQuestDistance = (GetDistanceSqToQuest(GetQuestLogSelection())/1000)
    local _,q_x,q_y,obj = QuestPOIGetIconInfo(questID)
    print(format("(X: %d, Y: %d) for Objective %s", q_x, q_y, obj))
    -- Given q_x² + q_y² = CurrentQuestDistance then trig for rotation

    local QuestDistanceString = "is "..tostring(CurrentQuestDistance).." km² away."
    if hasLocalPOI~=true then QuestDistanceString = "has no local POIs."
    elseif CurrentQuestDistance >= 4294967.295 then QuestDistanceString = "is on another continent." end
    f.text:SetText(format("This detailed quest has ID: %d\nand %s", questID, QuestDistanceString))
    return f
end

table.insert(QUEST_TEMPLATE_MAP_DETAILS.elements,updateDetailFrame)
table.insert(QUEST_TEMPLATE_MAP_DETAILS.elements,0)
table.insert(QUEST_TEMPLATE_MAP_DETAILS.elements,-10)
