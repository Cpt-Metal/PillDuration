-- These are the default options.
PillDuration_OPTIONS = { 
  showBetaBlockerValue = true,
  showPainkillerValue = true,
  showAntiDepressantsValue = true,
  showSleepingTabletsValue = true,
  showAntibioticsValue = true,
}

  -- Connecting the options to the menu, so user can change and save them.
  if ModOptions and ModOptions.getInstance then
    local settings = ModOptions:getInstance(PillDuration_OPTIONS, "PillDuration", "Pill Duration");

    ModOptions:loadFile();
  end

return PillDuration_OPTIONS;