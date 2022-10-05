extends Node

func Linear(t:float) -> float:
	return t

func InQuad(t:float) -> float:
	return t * t

func OutQuad(t:float) -> float:
	return -t * (t - 2)

func InOutQuad(t:float) -> float:
	if t < 0.5:
		return 2 * t * t
	else:
		t = 2*t - 1
		return -0.5 * (t*(t-2) - 1)

func InCubic(t:float) -> float:
	return t * t * t

func OutCubic(t:float) -> float:
	t -= 1
	return t*t*t + 1

func InOutCubic(t:float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t * t
	else:
		t -= 2
		return 0.5 * (t*t*t + 2)

func InQuart(t:float) -> float:
	return t * t * t * t

func OutQuart(t:float) -> float:
	t -= 1
	return -(t*t*t*t - 1)

func InOutQuart(t:float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t * t * t
	else:
		t -= 2
		return -0.5 * (t*t*t*t - 2)

func InQuint(t:float) -> float:
	return t * t * t * t * t

func OutQuint(t:float) -> float:
	t -= 1
	return t*t*t*t*t + 1

func InOutQuint(t:float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t * t * t * t
	else:
		t -= 2
		return 0.5 * (t*t*t*t*t + 2)

func InSine(t:float) -> float:
	return -1*cos(t*PI/2) + 1

func OutSine(t:float) -> float:
	return sin(t * PI / 2)

func InOutSine(t:float) -> float:
	return -0.5 * (cos(PI*t) - 1)

func InExpo(t:float) -> float:
	if t == 0:
		return 0.0
	else:
		return pow(2, 10*(t-1))

func OutExpo(t:float) -> float:
	if t == 1:
		return 1.0
	else:
		return 1 - pow(2, -10*t)

func InOutExpo(t:float) -> float:
	if t == 0:
		return 0.0
	elif t == 1:
		return 1.0
	else:
		if t < 0.5:
			return 0.5 * pow(2, (20*t)-10)
		else:
			return 1 - 0.5*pow(2, (-20*t)+10)

func InCirc(t:float) -> float:
	return -1 * (sqrt(1-t*t) - 1)

func OutCirc(t:float) -> float:
	t -= 1
	return sqrt(1 - (t * t))

func InOutCirc(t:float) -> float:
	t *= 2
	if t < 1:
		return -0.5 * (sqrt(1-t*t) - 1)
	else:
		t = t - 2
		return 0.5 * (sqrt(1-t*t) + 1)

func InBack(t:float) -> float:
	var s = 1.70158
	return t * t * ((s+1)*t - s)

func OutBack(t:float) -> float:
	var s = 1.70158
	t -= 1
	return t*t*((s+1)*t+s) + 1

func InOutBack(t:float) -> float:
	var s = 1.70158
	t *= 2
	if t < 1:
		s *= 1.525
		return 0.5 * (t * t * ((s+1)*t - s))
	else:
		t -= 2
		s *= 1.525
		return 0.5 * (t*t*((s+1)*t+s) + 2)

func InBounce(t:float) -> float:
	return 1 - OutBounce(1-t)

func OutBounce(t:float) -> float:
	if t < 4/11.0:
		return (121 * t * t) / 16.0
	elif t < 8/11.0:
		return (363 / 40.0 * t * t) - (99 / 10.0 * t) + 17/5.0
	elif t < 9/10.0:
		return (4356 / 361.0 * t * t) - (35442 / 1805.0 * t) + 16061/1805.0
	else:
		return (54 / 5.0 * t * t) - (513 / 25.0 * t) + 268/25.0

func InOutBounce(t:float) -> float:
	if t < 0.5:
		return InBounce(2*t) * 0.5
	else:
		return OutBounce(2*t-1)*0.5 + 0.5

func InSquare(t:float) -> float:
	if t < 1:
		return 0.0
	else:
		return 1.0

func OutSquare(t:float) -> float:
	if t > 0:
		return 1.0
	else:
		return 0.0

func InOutSquare(t:float) -> float:
	if t < 0.5:
		return 0.0
	else:
		return 1.0
	
