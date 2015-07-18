# widget configuration

unit_system   = "METRIC"
date_format   = "%H:%M"
animate_views = true

SCHEDULER.every "2m", first_in: 0 do |job|
  fitbit = Fitbit.new unit_system: unit_system, date_format: date_format
  if fitbit.errors?
    send_event "fitbit", { error: fitbit.error }
  else
    send_event "fitbit1", {
      device:   fitbit.device,
      steps:    fitbit.steps,
      calories: fitbit.calories,
      distance: fitbit.distance,
      active:   fitbit.active,
      animate:  animate_views,
      show:     [0, 1] #steps
    }
    send_event "fitbit2", {
      device:   fitbit.device,
      steps:    fitbit.steps,
      calories: fitbit.calories,
      distance: fitbit.distance,
      active:   fitbit.active,
      animate:  animate_views,
      show:     [2, 5] #calories, active times
    }
    send_event "fitbit3", {
      device:   fitbit.device,
      steps:    fitbit.steps,
      calories: fitbit.calories,
      distance: fitbit.distance,
      active:   fitbit.active,
      animate:  animate_views,
      show:     [3, 4] #distances
    }
  end
end

