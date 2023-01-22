
require "XpSystem/ISUI/ISHealthPanel"

local UI
local UIList = {ui0, ui1, ui2, ui3, ui4, ui5};
local pbs = {false, false, false, false, false};

local stringList = {"", "", "", "", "", "", "", ""};
local valueList = {0, 0, 0, 0, 0};
local minValueList = {-4, -14, 0, -11, 0};
local maxValueList = {6600, 5400, 6600, 6600, 36000};

local activeUIid;

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

    local tmpUI;
    tmpUI = NewUI();
    tmpUI:setTitle(getText("IGUI_PillInfoTitle"));
    tmpUI:addText("t1", getText("IGUI_NoneActiveInfo"), _, "Center");
    tmpUI:saveLayout();
    tmpUI:closeAndRemove();
    UIList[1] = tmpUI;
    --print("UI CREATED: ", tostring(tmpUI), " at index ", 1);

    for i=1,5 do
        local tmpUI;

        tmpUI = NewUI();
        tmpUI:setTitle(getText("IGUI_PillInfoTitle"));

        for u=i,5 do
            local index = u - i + 1;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            --print("added ", tName, " and ", pbName);
            tmpUI:addText(tName, tName, _, "Center");
            tmpUI:addProgressBar(pbName, 0, 50, 1000);
            if u ~= 5 then
                tmpUI:nextLine(); 
            end
        end
        tmpUI:setBorderToAllElements(true); 
        tmpUI:saveLayout();
        tmpUI:closeAndRemove();

        UIList[i + 1] = tmpUI;
        --print("UI CREATED: ", tostring(tmpUI), " at index ", i + 1);
    end

    -- load settings from mod options
    pbs[1] = PillDuration_OPTIONS.showBetaBlockerValue;
    pbs[2] = PillDuration_OPTIONS.showPainkillerValue;
    pbs[3] = PillDuration_OPTIONS.showAntiDepressantsValue;
    pbs[4] = PillDuration_OPTIONS.showSleepingTabletsValue;
    pbs[5] = PillDuration_OPTIONS.showAntibioticsValue;

    local c = getDisplayCount();
    local a = getUIIndexfromCount(c);
    activeUIid = a;
    UI = UIList[activeUIid];
end

function createWindow(rowCount)
    --for i=1,rowCount do
        local tmpUI;

        tmpUI = NewUI();
        tmpUI:setTitle(getText("IGUI_PillInfoTitle"));

        for u=1,rowCount do
            local index = u;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            --print("added ", tName, " and ", pbName);
            tmpUI:addText(tName, tName, _, "Center");
            tmpUI:addProgressBar(pbName, 0, 50, 1000);
            if u ~= rowCount then
                tmpUI:nextLine(); 
            end
        end
        tmpUI:setBorderToAllElements(true); 
        tmpUI:saveLayout();
        --tmpUI:closeAndRemove();

        --UIList[i + 1] = tmpUI;
        --print("UI CREATED: ", tostring(tmpUI), " at index ", i + 1);
   -- end
    return tmpUI
end

function everyMinute()
    updatePillInfoWindow()
end

function changePBsValue(index, val)
    pbs[index] = val;
    updatePillInfoWindow();
    local c = getDisplayCount();
    local a = getUIIndexfromCount(c);
    if a ~= activeUIid then
        activeUIid = a;
        closeAllButOneUI(activeUIid);
    end
end

function closeAllButOneUI(id)
    for i=1,6 do
        local ui = UIList[i];
        if i ~= id then
            ui:closeAndRemove();
        else
            ui:openAndAdd();
        end
    end
end

function updatePillInfoWindow()


    local c = getCharacterObj();    

    if not c then
        return false
    end  

    local tmpUI = getPillInfoUI();
    local count = getDisplayCount();
    local uiIndex = getUIIndexfromCount(count);
    
    --closeAllButOneUI(activeUIid);
    
    if count == 0 then
        return
    end
    
    --print(tostring(count)," -- ", tostring(uiIndex), " - ", tostring(tmpUI));

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
            --print("Populating ", i, " at index: ", index, " - val: ", val, " ", valMin, " ", valMax, " ", mappedVal);
            local m = math.floor(val / 60);
            if m < 0 then
                m = 0;
            end
            local col = mappedVal / 1000;
            tmpUI[tName]:setText(stringList[i + 3] .. " (" .. tostring(m) .. " min)");
            tmpUI[pbName]:setColor(1, 1 - col, col, 0);
            tmpUI[pbName]:setValue(mappedVal);
            index = index + 1;
        --else
            --print("not showing ", i);
        end
    end
    --tmpUI:open();
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

function getUIIndexfromCount(count)
    local id = 1
    if count == 0 then
        id = 1;
    else 
        id = 6 - count + 1;
    end
    return id;
end

function getPillInfoUI()  
    local count = getDisplayCount();
    local id =  getUIIndexfromCount(count);
    return UIList[id]
end

Events.OnCreateUI.Add(onCreateUI)
Events.EveryOneMinute.Add(everyMinute)