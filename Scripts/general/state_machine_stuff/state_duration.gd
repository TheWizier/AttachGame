extends State
class_name StateDuration

var duration: float
var transition_to: String
var current_time: float

func _init(duration: float, transition_to: String, parent: StateMachine):
	super(parent)
	self.duration = duration
	self.transition_to = transition_to
	self.current_time = 0

func update(delta: float):
	current_time += delta
	if current_time >= duration:
		current_time = 0
		self.parent_machine.set_state(transition_to)
	