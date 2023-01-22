require "ISUI/ISCollapsableWindow"
require "ISUI/ISSimpleUI"

function ISSimpleUI:openAndAdd()
    if not self.isUIVisible then
        self:setVisible(true);
        self:addToUIManager();
        --print("added UI from Manager");
        self.isUIVisible = true;
    end
end

function ISSimpleUI:closeAndRemove()
    if self.isUIVisible then
        self:setVisible(false);
        self:removeFromUIManager();
        --print("removed UI from Manager");
        self.isUIVisible = false;
    end
end

--function ISSimpleUI:isOpen()
 --   return self.isUIVisible
--end