if Example then return end -- this is our load blocker

-- base class
class 'Example' {
	Field = true,
	Method = function(self) return true end
}

-- derived class
class 'Example2' : extends 'Example' {
	NewField = 'foo',
	Method = function(self) return false end,
	NewMethod = function(self) return 'foo' end
}
