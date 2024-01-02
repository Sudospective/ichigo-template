if Example then return end -- this is our load blocker

class 'Example' {
	Field = true,
	Method = function(self) return true end
}

class 'Example2' : extends 'Example' {
	NewField = 'foo',
	NewMethod = function(self) return 'foo' end
}
