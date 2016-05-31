Role = {};

function Role:new(class, count, active)
	local self = {};
	self.class = class;
	self.count = 1;
	self.active = 0;
	return self;
end
