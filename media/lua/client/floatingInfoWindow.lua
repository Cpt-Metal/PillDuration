
require "XpSystem/ISUI/ISHealthPanel"

local UI
local UIList = {ui0, ui1, ui2, ui3, ui4, ui5};
local pbs = {false, false, false, false, false};

local stringList = {"", "", "", "", "", "", "", ""};
local minValueList = {-4, -11, 0, -11, 0};
local maxValueList = {6600, 5400, 6600, 6600, 50};

local function onCreateUI()
    --print("Creating Pill Info Window");

    stringList[1] = getText("IGUI_PillInfoOpen");
    stringList[2] = getText("IGUI_PillInfoTitle");
    stringList[3] = getText("IGUI_NoneActiveInfo");
    stringList[4] = getText("IGUI_PillBeta");
    stringList[5] = getText("IGUI_PillPain");
    stringList[6] = getText("IGUI_PillDepr");
    stringList[7] = getText("IGUI_PillSleep");
    stringList[8] = getText("IGUI_Antibiotics");


    local tmpUI;
    tmpUI = NewUI();
    tmpUI:setTitle(getText("IGUI_PillInfoTitle") .. tostring(i));
    tmpUI:addText("t1", getText("IGUI_NoneActiveInfo"), _, "Center");
    tmpUI:saveLayout();
    tmpUI:close();
    UIList[1] = tmpUI;
    --print("UI CREATED: ", tostring(tmpUI), " at index ", 1);

    for i=1,5 do
        local tmpUI;

        tmpUI = NewUI();
        tmpUI:setTitle(getText("IGUI_PillInfoTitle") .. tostring(i));

        for u=i,5 do
            local index = u - i + 1;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            print("added ", tName, " and ", pbName);
            tmpUI:addText(tName, tName, _, "Center");
            local tmp = u * 10;
            tmpUI:addProgressBar(pbName, 0, 50, 100);
            if u ~= 5 then
                tmpUI:nextLine(); 
            end
        end
        tmpUI:setBorderToAllElements(true); 
        tmpUI:saveLayout();
        tmpUI:close();

        UIList[i + 1] = tmpUI;
        print("UI CREATED: ", tostring(tmpUI), " at index ", i + 1);
    end



    -- load settings from mod options
    pbs[1] = PillDuration_OPTIONS.showBetaBlockerValue;
    pbs[2] = PillDuration_OPTIONS.showPainkillerValue;
    pbs[3] = PillDuration_OPTIONS.showAntiDepressantsValue;
    pbs[4] = PillDuration_OPTIONS.showSleepingTabletsValue;
    pbs[5] = PillDuration_OPTIONS.showAntibioticsValue;

    --[[
	UI = NewUI();
    UI:setTitle(getText("IGUI_PillInfoTitle"));

    local atLeastOneDisplayed = false;

    
    if PillDuration_OPTIONS.showBetaBlockerValue == true then
        UI:addText("t1", getText("IGUI_PillBeta"), _, "Center");
        UI:addProgressBar("betaPB", 0, 0, 100);
        UI:nextLine();
    end

      
    if PillDuration_OPTIONS.showPainkillerValue then
        UI:addText("t2", getText("IGUI_PillPain"), _, "Center");
        UI:addProgressBar("painPB", 0, 0, 100);
        UI:nextLine();
    end

      
    if PillDuration_OPTIONS.showAntiDepressantsValue then
        UI:addText("t3", getText("IGUI_PillDepr"), _, "Center");
        UI:addProgressBar("depressPB", 0, 0, 100);
        UI:nextLine();
    end

      
    if PillDuration_OPTIONS.showSleepingTabletsValue then
        UI:addText("t4", getText("IGUI_PillSleep"), _, "Center");
        UI:addProgressBar("sleepPB", 0, 0, 100);
        UI:nextLine();
    end

    UI:addText("t5", getText("IGUI_Antibiotics"), _, "Center");
    UI:addProgressBar("antibPB", 0, 0, 100);
    UI:nextLine();

    UI:saveLayout();
    UI:close();
    --]]
end

function everyMinute()
    updatePillInfoWindow()
end

function changePBsValue(index, val)
    pbs[index] = val;
    closeAllUIs();
    updatePillInfoWindow();
end

function closeAllUIs()
    for i=1,6 do
        local tmp = UIList[i];
        tmp:close();
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

    local index = 1;
    
    print(tostring(count)," -- ", tostring(uiIndex), " - ", tostring(tmpUI));

    if count > 0 then
  

        if pbs[1] then


            local betaEffect = c:getBetaEffect();
            local betaMapped = mapRange(betaEffect, -4, 6600, 0, 100);
            local clB = betaMapped / 100;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            local s = math.floor(betaEffect);
            --print("changing ", tName, " and ", pbName);
            tmpUI[tName]:setText(getText("IGUI_PillBeta") .. " (" .. tostring(s) .. "min)");
            tmpUI[pbName]:setColor(1, 1 - clB, clB, 0);
            tmpUI[pbName]:setValue(betaMapped);
            index = index + 1;
        end

        
        if pbs[2] then
            local painEffect = c:getPainEffect();
            local painMapped = mapRange(painEffect, -11, 5400, 0, 100);  
            local clP = painMapped / 100;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            --print("changing ", tName, " and ", pbName);
            tmpUI[tName]:setText(getText("IGUI_PillPain"));
            tmpUI[pbName]:setColor(1, 1 - clP, clP, 0);
            tmpUI[pbName]:setValue(painMapped);
            index = index + 1;
        end

        if pbs[3] then
            local depressEffect = c:getDepressEffect();
            local depressMapped = mapRange(depressEffect, 0, 6600, 0, 100);  
            local clD = depressMapped / 100;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            --print("changing ", tName, " and ", pbName);
            tmpUI[tName]:setText(getText("IGUI_PillDepr"));
            tmpUI[pbName]:setColor(1, 1 - clD, clD, 0);
            tmpUI[pbName]:setValue(depressMapped);
            index = index + 1;
        end

        if pbs[4] then
            local sleepEffect = c:getSleepingTabletEffect();
            local sleepMapped = mapRange(sleepEffect, -11, 6600, 0, 100);  
            local clS = sleepMapped / 100;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            --print("changing ", tName, " and ", pbName);
            tmpUI[tName]:setText(getText("IGUI_PillSleep"));
            tmpUI[pbName]:setColor(1, 1 - clS, clS, 0);
            tmpUI[pbName]:setValue(sleepMapped);
            index = index + 1;
        end

        if pbs[5] then
            local antibEffect = c:getReduceInfectionPower();
            local antibMapped = mapRange(antibEffect, 0, 50, 0, 100);
            local clA = antibMapped / 100;
            local tName = "t" .. tostring(index);
            local pbName = "pb" .. tostring(index);
            --print("changing ", tName, " and ", pbName);
            tmpUI[tName]:setText(getText("IGUI_Antibiotics"));
            tmpUI[pbName]:setColor(1, 1 - clA, clA, 0);
            tmpUI[pbName]:setValue(antibMapped);
            index = index + 1;
        end


        --[[
        local f1= c:getStats():getFatigue();
        local f2 = c:getBodyDamage():getInfectionGrowthRate();
        local f3 = c:getBodyDamage():getInfectionLevel();
        local f4 = c:getBodyDamage():getInfectionMortalityDuration();
        local f5 = c:getBodyDamage():getInfectionTime();
        local f6 = c:getReduceInfectionPower();
        local f7 = c:getBodyDamage():getApparentInfectionLevel();
        ]]

        --print("Infection Test: ", antibEffect, " -- ", antibMapped, " -- ", clA, " -- ", 1 - clA);
    end

    

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
    return 6 - count + 1
end

function getPillInfoUI()  
    local count = getDisplayCount();
    local id =  getUIIndexfromCount(count);
    return UIList[id]
end

Events.OnCreateUI.Add(onCreateUI)
Events.EveryOneMinute.Add(everyMinute)