local ichi = ...

function ichi.AddGizmo(gizmo)
  table.insert(ichi.Actors, gizmo.__actor)
end
