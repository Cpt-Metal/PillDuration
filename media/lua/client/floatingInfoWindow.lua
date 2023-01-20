local UI
require "XpSystem/ISUI/ISHealthPanel"

--local UIList = {ui0, ui1, ui2, ui3, ui4, ui5};

local pbs = {false, false, false, false};

local function onCreateUI()
    print("Creating Pill Info Window");
    
    pbs[1] = PillDuration_OPTIONS.showBetaBlockerValue;
    pbs[2] = PillDuration_OPTIONS.showPainkillerValue;
    pbs[3] = PillDuration_OPTIONS.showAntiDepressantsValue;
    pbs[4] = PillDuration_OPTIONS.showSleepingTabletsValue;

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
end

function everyMinute()
    updatePillInfoWindow()
end

function updatePillInfoWindow()
    local c = getCharacterObj();

    if not c then
        return false
    end    

    if pbs[1] then
        local betaEffect = c:getBetaEffect();
        local betaMapped = mapRange(betaEffect, -4, 6600, 0, 100);
        local clB = betaMapped / 100;
        UI["betaPB"]:setColor(1, 1 - clB, clB, 0);
        UI["betaPB"]:setValue(betaMapped);
    end

    
   if pbs[2] then
        local painEffect = c:getPainEffect();
        local painMapped = mapRange(painEffect, -11, 5400, 0, 100);  
        local clP = painMapped / 100;
        UI["painPB"]:setColor(1, 1 - clP, clP, 0);   
        UI["painPB"]:setValue(painMapped);
    end

    if pbs[3] then
        local depressEffect = c:getDepressEffect();
        local depressMapped = mapRange(depressEffect, 0, 6600, 0, 100);  
        local clD = depressMapped / 100;
        UI["depressPB"]:setColor(1, 1 - clD, clD, 0);  
        UI["depressPB"]:setValue(depressMapped);
    end

    if pbs[4] then
        local sleepEffect = c:getSleepingTabletEffect();
        local sleepMapped = mapRange(sleepEffect, -11, 6600, 0, 100);  
        local clS = sleepMapped / 100;
        UI["sleepPB"]:setColor(1, 1 - clS, clS, 0);    
        UI["sleepPB"]:setValue(sleepMapped);
    end

    local antibEffect = c:getReduceInfectionPower();
    local antibMapped = mapRange(antibEffect, 0, 50, 0, 100);
    local clA = antibMapped / 100;
    UI["antibPB"]:setColor(1, 1 - clA, clA, 0);    
    UI["antibPB"]:setValue(antibMapped);


    --[[
    local f1= c:getStats():getFatigue();
    local f2 = c:getBodyDamage():getInfectionGrowthRate();
    local f3 = c:getBodyDamage():getInfectionLevel();
    local f4 = c:getBodyDamage():getInfectionMortalityDuration();
    local f5 = c:getBodyDamage():getInfectionTime();
    local f6 = c:getReduceInfectionPower();
    local f7 = c:getBodyDamage():getApparentInfectionLevel();
    ]]

    print("Infection Test: ", antibEffect, " -- ", antibMapped, " -- ", clA, " -- ", 1 - clA);

end

function getPillInfoUI()
    return UI;
end

Events.OnCreateUI.Add(onCreateUI)
Events.EveryOneMinute.Add(everyMinute)