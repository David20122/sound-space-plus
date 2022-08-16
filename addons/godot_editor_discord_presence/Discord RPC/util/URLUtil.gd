class_name URLUtil

static func dict_to_url_encoded(data: Dictionary) -> String:
	var parameters: PoolStringArray
	for key in data.keys():
		parameters.append("%s=%s" % [str(key), str(data[key]).percent_encode()]) 
	return parameters.join("&")
