//#region node_modules/rescript/lib/es6/caml_option.js
function some(x) {
	if (x === void 0) return { BS_PRIVATE_NESTED_SOME_NONE: 0 };
	else if (x !== null && x.BS_PRIVATE_NESTED_SOME_NONE !== void 0) return { BS_PRIVATE_NESTED_SOME_NONE: x.BS_PRIVATE_NESTED_SOME_NONE + 1 | 0 };
	else return x;
}
function nullable_to_opt(x) {
	if (x == null) return;
	else return some(x);
}
function valFromOption(x) {
	if (!(x !== null && x.BS_PRIVATE_NESTED_SOME_NONE !== void 0)) return x;
	var depth = x.BS_PRIVATE_NESTED_SOME_NONE;
	if (depth === 0) return;
	else return { BS_PRIVATE_NESTED_SOME_NONE: depth - 1 | 0 };
}

//#endregion
//#region node_modules/rescript/lib/es6/belt_Array.js
function concatMany(arrs) {
	var lenArrs = arrs.length;
	var totalLen = 0;
	for (var i = 0; i < lenArrs; ++i) totalLen = totalLen + arrs[i].length | 0;
	var result = new Array(totalLen);
	totalLen = 0;
	for (var j = 0; j < lenArrs; ++j) {
		var cur = arrs[j];
		for (var k = 0, k_finish = cur.length; k < k_finish; ++k) {
			result[totalLen] = cur[k];
			totalLen = totalLen + 1 | 0;
		}
	}
	return result;
}

//#endregion
//#region node_modules/@rescript/core/src/Core__Dict.res.mjs
function $$delete$1(dict, string) {
	delete dict[string];
}

//#endregion
//#region node_modules/@rescript/core/src/Core__Array.res.mjs
function reduce(arr, init, f) {
	return arr.reduce(f, init);
}

//#endregion
//#region node_modules/@rescript/core/src/Core__Error.res.mjs
function panic(msg) {
	throw new Error("Panic! " + msg);
}

//#endregion
//#region node_modules/@rescript/core/src/Core__Option.res.mjs
function getExn(x, message) {
	if (x !== void 0) return valFromOption(x);
	else return panic(message !== void 0 ? message : "Option.getExn called for None value");
}

//#endregion
//#region src/Elym.res.mjs
var listeners = new WeakMap();
function select(selector) {
	if (selector.TAG === "Selector") return {
		TAG: "Single",
		_0: nullable_to_opt(document.querySelector(selector._0))
	};
	else return {
		TAG: "Single",
		_0: some(selector._0)
	};
}
function selectChild(selection, selector) {
	if (selection.TAG === "Single") {
		var element = selection._0;
		if (element !== void 0) return {
			TAG: "Single",
			_0: nullable_to_opt(valFromOption(element).querySelector(selector))
		};
		else return {
			TAG: "Single",
			_0: void 0
		};
	}
	var firstMatch = reduce(selection._0, void 0, function(first, el) {
		if (first !== void 0) return first;
		else return nullable_to_opt(el.querySelector(selector));
	});
	return {
		TAG: "Single",
		_0: firstMatch
	};
}
function attributed(selection, attrName, exists) {
	var result;
	if (selection.TAG === "Single") {
		var el = selection._0;
		if (el !== void 0) {
			var el$1 = valFromOption(el);
			if (exists !== void 0) if (exists) {
				el$1.setAttribute(attrName, "");
				result = void 0;
			} else {
				el$1.removeAttribute(attrName);
				result = void 0;
			}
			else result = el$1.hasAttribute(attrName);
		} else {
			console.error("Elym: attributed - Single element is None.");
			result = void 0;
		}
	} else {
		var elements = selection._0;
		if (exists !== void 0) if (exists) {
			elements.forEach(function(el$2) {
				el$2.setAttribute(attrName, "");
			});
			result = void 0;
		} else {
			elements.forEach(function(el$2) {
				el$2.removeAttribute(attrName);
			});
			result = void 0;
		}
		else {
			console.error("Elym: attributed - getter not supported on multiple elements.");
			result = void 0;
		}
	}
	return [selection, result];
}
function property(selection, propName, value) {
	var getValue = function(el$2) {
		var rawValue = getExn(el$2[propName], void 0);
		var match = typeof rawValue;
		if (match === "boolean") return rawValue;
		else if (match === "string") return rawValue;
		else if (match === "number") return rawValue;
		else return;
	};
	var setValue = function(el$2, v) {
		return Object.assign(el$2, Object.fromEntries([[propName, v]]));
	};
	var result;
	if (selection.TAG === "Single") {
		var el = selection._0;
		if (el !== void 0) {
			var el$1 = valFromOption(el);
			if (value !== void 0) {
				setValue(el$1, value);
				result = void 0;
			} else result = getValue(el$1);
		} else {
			console.error("Elym: property - Single element is None.");
			result = void 0;
		}
	} else if (value !== void 0) {
		selection._0.forEach(function(el$2) {
			setValue(el$2, value);
		});
		result = void 0;
	} else {
		console.error("Elym: property - getter not supported on multiple elements.");
		result = void 0;
	}
	return [selection, result];
}
function on(selection, eventType, callback) {
	var addListener = function(el$1) {
		var id = window.crypto.randomUUID();
		var dict = listeners.get(el$1);
		var listenersForElement;
		if (dict !== void 0) listenersForElement = dict;
		else {
			var newDict = {};
			listeners.set(el$1, newDict);
			listenersForElement = newDict;
		}
		var arr = listenersForElement[eventType];
		var listenersForEvent = arr !== void 0 ? arr : [];
		listenersForElement[eventType] = concatMany([[[id, callback]], listenersForEvent]);
		el$1.addEventListener(eventType, callback);
	};
	if (selection.TAG === "Single") {
		var el = selection._0;
		if (el !== void 0) addListener(valFromOption(el));
		else console.error("Elym: on - Single element is None.");
	} else selection._0.forEach(addListener);
	return selection;
}
function off(selection, eventType) {
	var removeListener = function(el$1) {
		var dict = listeners.get(el$1);
		if (dict === void 0) return;
		var arr = dict[eventType];
		if (arr !== void 0) {
			arr.forEach(function(param) {
				el$1.removeEventListener(eventType, param[1]);
			});
			return $$delete$1(dict, eventType);
		}
	};
	if (selection.TAG === "Single") {
		var el = selection._0;
		if (el !== void 0) removeListener(valFromOption(el));
		else console.error("Elym: off - Single element is None.");
	} else selection._0.forEach(removeListener);
	return selection;
}
function append(selection, elementType) {
	var createElement$1 = function(parentEl, tag) {
		var ownerDoc = parentEl.ownerDocument;
		var parentNamespace = parentEl.namespaceURI;
		if (parentNamespace !== void 0) switch (parentNamespace) {
			case "http://www.w3.org/1998/Math/MathML": return ownerDoc.createElementNS("http://www.w3.org/1998/Math/MathML", tag);
			case "http://www.w3.org/2000/svg": return ownerDoc.createElementNS("http://www.w3.org/2000/svg", tag);
			default:
		}
		switch (tag) {
			case "math": return ownerDoc.createElementNS("http://www.w3.org/1998/Math/MathML", tag);
			case "svg": return ownerDoc.createElementNS("http://www.w3.org/2000/svg", tag);
			default: return ownerDoc.createElement(tag);
		}
	};
	var appendElement = function(parentEl) {
		var newEl$1;
		newEl$1 = elementType.TAG === "Dom" ? elementType._0 : createElement$1(parentEl, elementType._0);
		parentEl.appendChild(newEl$1);
		return newEl$1;
	};
	if (selection.TAG === "Single") {
		var el = selection._0;
		if (el !== void 0) {
			var newEl = appendElement(valFromOption(el));
			return {
				TAG: "Single",
				_0: some(newEl)
			};
		}
		console.error("Elym: append - Single element is None.");
		return {
			TAG: "Single",
			_0: void 0
		};
	}
	var newElements = selection._0.map(appendElement);
	return {
		TAG: "Many",
		_0: newElements
	};
}
function createElement(tagName) {
	var match = tagName.split(":");
	var match$1;
	if (match.length !== 2) match$1 = [void 0, tagName];
	else {
		var ns = match[0];
		var t = match[1];
		match$1 = ns === "svg" ? ["http://www.w3.org/2000/svg", t] : ns === "math" ? ["http://www.w3.org/1998/Math/MathML", t] : [void 0, tagName];
	}
	var tag = match$1[1];
	var namespace = match$1[0];
	if (namespace !== void 0) return document.createElementNS(namespace, tag);
	else return document.createElement(tag);
}
function create(creator) {
	if (creator.TAG === "Tag") return some(createElement(creator._0));
	else {
		var html = creator._0;
		var fragment = document.createRange().createContextualFragment(html);
		var el = fragment.firstElementChild;
		if (el === null) return;
		else return some(el);
	}
}
function removeAllEventListeners(element) {
	var dict = listeners.get(element);
	if (dict !== void 0) {
		Object.keys(dict).forEach(function(eventType) {
			off({
				TAG: "Single",
				_0: some(element)
			}, eventType);
		});
		listeners.delete(element);
	}
	var children = Array.from(element.querySelectorAll("*"));
	children.forEach(function(child) {
		var match = child.nodeType;
		if (match !== 1) return;
		else return removeAllEventListeners(child);
	});
}
function removeWithListeners(selection) {
	var removeSingleElement = function(el$1) {
		removeAllEventListeners(el$1);
		el$1.remove();
	};
	if (selection.TAG === "Single") {
		var el = selection._0;
		if (el !== void 0) return removeSingleElement(valFromOption(el));
		else {
			console.error("Elym: removeWithListeners - Single element is None.");
			return;
		}
	}
	selection._0.forEach(removeSingleElement);
}
var remove = removeWithListeners;

//#endregion
//#region example/Index.res.mjs
function createTask(content) {
	var node = create({
		TAG: "Template",
		_0: "\r\n    <li class=\"todo__list-task\">\r\n      <div class=\"todo__list-task-content\">\r\n        <textarea class=\"todo__list-task-description\" placeholder=\"Enter your task here\" disabled>" + content + "</textarea>\r\n        <button class=\"todo__list-task-button-edit\">✏</button>\r\n        <button class=\"todo__list-task-button-delete\">🗑</button>\r\n      </div>\r\n    </li>"
	});
	if (node !== void 0) {
		var n = valFromOption(node);
		on(selectChild(select({
			TAG: "Dom",
			_0: n
		}), ".todo__list-task-button-edit"), "click", function(param) {
			attributed(selectChild(select({
				TAG: "Dom",
				_0: n
			}), ".todo__list-task-description"), "disabled", false);
		});
		on(selectChild(select({
			TAG: "Dom",
			_0: n
		}), ".todo__list-task-description"), "blur", function(evt) {
			evt.target.disabled = true;
		});
		on(selectChild(select({
			TAG: "Dom",
			_0: n
		}), ".todo__list-task-button-delete"), "click", function(param) {
			remove(select({
				TAG: "Dom",
				_0: n
			}));
		});
	}
	return node;
}
var formTodoInput = select({
	TAG: "Selector",
	_0: "#todo__form-input"
});
var formButtonAddTodo = select({
	TAG: "Selector",
	_0: "#todo__form-add-task-button"
});
var todoList = select({
	TAG: "Selector",
	_0: "#todo__list"
});
on(formTodoInput, "input", function(evt) {
	if (evt.target.value.length > 3) attributed(formButtonAddTodo, "disabled", false);
	else attributed(formButtonAddTodo, "disabled", true);
});
on(formButtonAddTodo, "click", function(param) {
	var match = property(formTodoInput, "value", void 0);
	var match$1 = match[1];
	if (match$1 !== void 0) switch (typeof match$1) {
		case "string":
			var task = createTask(match$1);
			if (task !== void 0) {
				append(todoList, {
					TAG: "Dom",
					_0: valFromOption(task)
				});
				return;
			} else return;
		case "number":
		case "boolean":
			console.error("Error on the input, it is invalid");
			return;
	}
	else {
		console.error("Error on the input, it is invalid");
		return;
	}
});

//#endregion
export { createTask, formButtonAddTodo, formTodoInput, todoList };