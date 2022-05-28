extends Node
#class_name ResourceQueue

var thread
var mutex
var semaphore
var exit_thread = false

var time_max = 100 # Milliseconds.

var queue = []
var pending = {}

func _lock(_caller):
	mutex.lock()


func _unlock(_caller):
	mutex.unlock()


func _post(_caller):
	semaphore.post()


func _wait(_caller):
	semaphore.wait()


func queue_resource(path, p_in_front = false):
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_P): return ERR_SKIP
	_lock("queue_resource")
	if path in pending:
		_unlock("queue_resource")
		return OK
	elif ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		pending[path] = res
		_unlock("queue_resource")
		return OK
	else:
		var res = ResourceLoader.load_interactive(path)
		if !res: return FAILED
		res.set_meta("path", path)
		if p_in_front:
			queue.insert(0, res)
		else:
			queue.push_back(res)
		pending[path] = res
		_post("queue_resource")
		_unlock("queue_resource")
		return OK


func cancel_resource(path):
	_lock("cancel_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			queue.erase(pending[path])
		pending.erase(path)
	_unlock("cancel_resource")


func get_progress(path):
	_lock("get_progress")
	var ret = -1
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			ret = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			ret = 1.0
	_unlock("get_progress")
	return ret


func is_ready(path):
	var ret
	_lock("is_ready")
	if path in pending:
		ret = !(pending[path] is ResourceInteractiveLoader)
	else:
		ret = false
	_unlock("is_ready")
	return ret


func _wait_for_resource(res, path):
	_unlock("wait_for_resource")
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		_lock("wait_for_resource")
		if queue.size() == 0 || queue[0] != res:
			return pending[path]
		_unlock("wait_for_resource")


func get_resource(path):
	_lock("get_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			var res = pending[path]
			if res != queue[0]:
				var pos = queue.find(res)
				queue.remove(pos)
				queue.insert(0, res)

			res = _wait_for_resource(res, path)
			pending.erase(path)
			_unlock("return")
			return res
		else:
			var res = pending[path]
			pending.erase(path)
			_unlock("return")
			return res
	else:
		_unlock("return")
		return ResourceLoader.load(path)


func thread_process():
	_wait("thread_process")
	
	_lock("process")
	while queue.size() > 0:
		var res = queue[0]
		_unlock("process_poll")
		var ret = OK
		if !Input.is_key_pressed(KEY_P): ret = res.poll()
		_lock("process_check_queue")

		if ret == ERR_FILE_EOF || ret != OK:
			var path = res.get_meta("path")
			if path in pending: # Else, it was already retrieved.
				if ret == ERR_FILE_EOF:
					pending[res.get_meta("path")] = res.get_resource()
				else: pending[res.get_meta("path")] = false
			# Something might have been put at the front of the queue while
			# we polled, so use erase instead of remove.
			queue.erase(res)
	_unlock("process")


func thread_func(_u):
	while true:
		mutex.lock()
		var should_exit = exit_thread # Protect with Mutex.
		mutex.unlock()

		if should_exit:
			break
		thread_process()


func start():
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread = Thread.new()
	thread.start(self, "thread_func", 0)

# Triggered by calling "get_tree().quit()".
func _exit_tree():
	mutex.lock()
	exit_thread = true # Protect with Mutex.
	mutex.unlock()

	# Unblock by posting.
	semaphore.post()

	# Wait until it exits.
	thread.wait_to_finish()

func _ready(): start()
