require "ISUI/ISCollapsableWindow"

local UI
local pbs = {false, false, false, false, false};

local stringList = {"", "", "", "", "", "", "", ""};
local valueList = {0, 0, 0, 0, 0};
local minValueList = {-4, -14, 0, -11, 0};
local maxValueList = {6600, 5400, 6600, 6600, 36000};
local toggleButton = {};

local isVisible = false;

local showBorders = true;

local function onCreateUI()

    -- place toggle button on the main screen
    toggleButton = ISPanel:new(150, 150, 52, 52);
    toggleButton.moveWithMouse = true;
    toggleButton.mybutton = ISButton:new(10, 10, 32, 32, "", toggleButton.mybutton, togglePillWindow);
    toggleButton.mybutton:setBorderRGBA(0,0,0,0);
    toggleButton.mybutton:forceImageSize(32,32); 
    toggleButton.mybutton:setImage(getTexture("media/textures/images/PDIcon32.png")); 
    toggleButton:addChild(toggleButton.mybutton);
    toggleButton:addToUIManager();

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

    isVisible = false;

    if UI then
        UI:closeAndRemove();
        isVisible = false;
    end

    local c = getDisplayCount();
    createWindow(c);
end

function setShowBorders(val)
    showBorders = val;
    UI:closeAndRemove();
    isVisible = false;
    local c = getDisplayCount();
    createWindow(c);
    updatePillInfoWindow();
end

function togglePillWindow()
    if isVisible == false then
        updatePillInfoWindow();
        UI:open();
        isVisible = true
    else
        UI:close();
        isVisible = false;
    end
end

function createWindow(rowCount)
    UI = NewUI();
    UI:setTitle(stringList[2]);

    if rowCount == 0 then
        UI:addText("t1", stringList[3], _, "Center");
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
    isVisible = false;
end

function everyMinute()
    updatePillInfoWindow()
end

function changePBsValue(index, val)
    UI:closeAndRemove();
    isVisible = false;
    pbs[index] = val;
    local c = getDisplayCount();
    createWindow(c);
    updatePillInfoWindow();
end

function updatePillInfoWindow()    
    local playerObject = getSpecificPlayer(0); 

    if not playerObject then
        return false
    end  

    local count = getDisplayCount();
    
    if count == 0 then
        return
    end

    valueList[1] = playerObject:getBetaEffect();
    valueList[2] = playerObject:getPainEffect();
    valueList[3] = playerObject:getDepressEffect();
    valueList[4] = playerObject:getSleepingTabletEffect();
    valueList[5] = playerObject:getReduceInfectionPower() * 720;

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
    isVisible = true;
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

pillToggleButton = ISCollapsableWindow:derive("pillToggleButton");

Events.OnCreateUI.Add(onCreateUI)
Events.EveryOneMinute.Add(everyMinute)