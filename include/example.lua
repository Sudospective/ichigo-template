if Example then return end -- this is our load blocker

-- base class
class "Example" {
  __init = function(self)
    print(self.__class)
  end;
  Field = true;
  Method = function(self) return self.Field end;
}

-- derived class
class "Example2" : extends "Example" {
  Field = false; -- overwrites base class field
  NewField = "foo";
  NewMethod = function(self) return self.NewField end;
}
