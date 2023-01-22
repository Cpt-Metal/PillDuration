require "XpSystem/ISUI/ISHealthPanel"

local UI
local pbs = {false, false, false, false, false};

local stringList = {"", "", "", "", "", "", "", ""};
local valueList = {0, 0, 0, 0, 0};
local minValueList = {-4, -14, 0, -11, 0};
local maxValueList = {6600, 5400, 6600, 6600, 36000};

local showBorders = true;

local function onCreateUI()
    
    -- redefine arrays because the values are somehow not loaded
    stringList[1] = getText("IGUI_PillInfoOpen");
    stringList[2] = getText("IGUI_PillInfoTitle");
    stringList[3] = getText("IGUI_NoneActiveInfo");
    stringList[4] = getText("IGUI_PillBeta");
    stringList[5] = getText("IGUI_PillPain");
    stringList[6] = getText("IGUI_PillDepr");
    stringList[7] = getText("IGUI_PillSleep");
    stringList[8] = getText("IGUI_Antibiotics");
    
    minValueList[1] = -4;
    minValueList[2] = -14;
    minValueList[3] = 0;
    minValueList[4] = -11;
    minValueList[5] = 0;

    maxValueList[1] = 6600;
    maxValueList[2] = 5400;
    maxValueList[3] = 6600;
    maxValueList[4] = 6600;
    maxValueList[5] = 36000;

    -- load settings from mod options
    showBorders = PillDuration_OPTIONS.showBorders;
    pbs[1] = PillDuration_OPTIONS.showBetaBlockerValue;
    pbs[2] = PillDuration_OPTIONS.showPainkillerValue;
    pbs[3] = PillDuration_OPTIONS.showAntiDepressantsValue;
    pbs[4] = PillDuration_OPTIONS.showSleepingTabletsValue;
    pbs[5] = PillDuration_OPTIONS.showAntibioticsValue;

    local c = getDisplayCount();
    if UI then
        UI:closeAndRemove();
    end

    createWindow(c);

end

function setShowBorders(val)
    showBorders = val;
    UI:closeAndRemove();
    local c = getDisplayCount();
    createWindow(c);
    updatePillInfoWindow();
    UI:openAndAdd();
end

function createWindow(rowCount)
    UI = NewUI();
    UI:setTitle(getText("IGUI_PillInfoTitle"));

    if rowCount == 0 then
        UI:setTitle(getText("IGUI_PillInfoTitle"));
        UI:addText("t1", getText("IGUI_NoneActiveInfo"), _, "Center");
    else
        for i=1,rowCount do
            local tName = "t" .. tostring(i);
            local pbName = "pb" .. tostring(i);
            UI:addText(tName, tName, _, "Center");
            UI:addProgressBar(pbName, 0, 50, 1000);
            if i ~= rowCount then
                UI:nextLine(); 
            end
        end
    end

    if showBorders then
        UI:setBorderToAllElements(true); 
    end

    UI:saveLayout();
    UI:close();      
end

function everyMinute()
    updatePillInfoWindow()
end

function changePBsValue(index, val)
    --UI:close();
    UI:closeAndRemove();
    pbs[index] = val;
    local c = getDisplayCount();
    createWindow(c);
    updatePillInfoWindow();
    UI:openAndAdd();
end

function updatePillInfoWindow()
    local c = getCharacterObj();    

    if not c then
        return false
    end  

    --local tmpUI = getPillInfoUI();
    local count = getDisplayCount();
    
    if count == 0 then
        return
    end

    valueList[1] = c:getBetaEffect();
    valueList[2] = c:getPainEffect();
    valueList[3] = c:getDepressEffect();
    valueList[4] = c:getSleepingTabletEffect();
    valueList[5] = c:getReduceInfectionPower() * 720;

    local index = 1;

    for i=1,5 do
        if pbs[i] then
            local val = valueList[i];
            local valMin = minValueList[i];
            local valMax = maxValueList[i];
            local mappedVal = mapRange(val, valMin, valMax, 0, 1000);
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            local m = math.floor(val / 60);
            if m < 0 then
                m = 0;
            end
            local col = mappedVal / 1000;
            UI[tName]:setText(stringList[i + 3] .. " (" .. tostring(m) .. " min)");
            UI[pbName]:setColor(1, 1 - col, col, 0);
            UI[pbName]:setValue(mappedVal);
            index = index + 1;
        end
    end
end

function updateAndShow()
    updatePillInfoWindow();
    UI:open();
end

function getDisplayCount()
    local count = 0;
    for i=1,5 do
        if  pbs[i] == true then
            count = count + 1;
        end
    end
    return count
end

function getPillInfoUI()  
    return UI
end

Events.OnCreateUI.Add(onCreateUI)
Events.EveryOneMinute.Add(everyMinute)