require "ISUI/ISCollapsableWindow"
require "ISUI/ISSimpleUI"

function ISSimpleUI:open()
    if not self.isUIVisible then
        self:setVisible(true);
        self:addToUIManager();
        --print("added UI from Manager");
        self.isUIVisible = true;
    end
end

function ISSimpleUI:close()
    if self.isUIVisible then
        self:setVisible(false);
        self:removeFromUIManager();
        --print("removed UI from Manager");
        self.isUIVisible = false;
    end
end

function ISSimpleUI:toggle()
    if self.isUIVisible then
        self:setVisible(false);
        self:removeFromUIManager();
        self.isUIVisible = false;
    else
        self:setVisible(true);
        self:addToUIManager();
        self.isUIVisible = true;
    end
end