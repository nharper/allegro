function updateTile(node, state) {
	switch (state) {
		case 'present':
			node.classList.remove('present-false');
			node.classList.remove('present-unknown');
			node.classList.add('present-true');
			break;
		case 'not present':
			node.classList.add('present-false');
			node.classList.remove('present-unknown');
			node.classList.remove('present-true');
			break;
		default:
			node.classList.remove('present-false');
			node.classList.add('present-unknown');
			node.classList.remove('present-true');
			break;
	}
}

function toggleState(node, rosterEntry, event) {
	if (!rosterEntry.attendance || rosterEntry.attendance == 'unknown') {
		rosterEntry.attendance = 'present';
	} else if (rosterEntry.attendance == 'present') {
		rosterEntry.attendance = 'not present';
	} else if (rosterEntry.attendance == 'not present') {
		rosterEntry.attendance = 'unknown';
	}
	updateTile(node, rosterEntry.attendance);
  saveRoster();
}

function createTile(performer) {
	var container = document.createElement("div");
	container.setAttribute("class", "tile");
	container.addEventListener("click", toggleState.bind(this, container, performer));

  var image = document.createElement("img");
  image.setAttribute("src", "/performers/" + performer.id + "/photo");
  container.appendChild(image);

	var text_wrapper = document.createElement("span");

	var ch_num = document.createElement("span");
	ch_num.setAttribute("class", "ch_num");
	ch_num.appendChild(document.createTextNode(performer.number));
	text_wrapper.appendChild(ch_num);

	text_wrapper.appendChild(document.createTextNode(" "));
	var name_node = document.createElement("span");
	name_node.setAttribute("class", "name");
	name_node.appendChild(document.createTextNode(performer.name));
	text_wrapper.appendChild(name_node);

	if (false) {
		text_wrapper.appendChild(document.createTextNode(" "));
		var status_node = document.createElement("span");
		status_node.setAttribute("class", "status");
		status_node.appendChild(document.createTextNode(stat));
		text_wrapper.appendChild(status_node);
	}
	container.appendChild(text_wrapper);
	return container;
}

function rosterLoadDone() {
	var tiles = document.getElementById("tiles");

  // Intentionally put roster in global scope.
	roster = JSON.parse(this.responseText);
  // TODO: Re-figure out localStorage. Remember that localStorage is across
  // the whole domain (so key things properly).
	var saved_roster = {};
	try {
		saved_roster = JSON.parse(window.localStorage.attendance);
	} catch (e) {
	}

  // The roster from the XHR to /performers.json provides an array of
  // Performer objects, with keys id, name, number, and section.
  roster.forEach(function(performer) {
    var cn = performer.number;
    if (saved_roster.version == 1 && saved_roster.data[cn]) {
      performer.attendance = saved_roster.data[cn].attendance;
    }
		var tile = createTile(performer);
		tiles.appendChild(tile);
		updateTile(tile, performer.attendance);
	});
  updateDisplay();
}

function saveRoster() {
  var stored_roster = {data: {}, version: 1};
  roster.forEach(function(performer) {
    stored_roster.data[performer.number] = performer;
  });
	window.localStorage.attendance = JSON.stringify(stored_roster);
	var record = "";
  updateDisplay();
}

function updateDisplay() {
  var record = '';
  roster.forEach(function(performer) {
			record += performer.number + ": ";
			if (performer.attendance == 'present') {
				record += "_✓_";
			} else if (performer['status'] == 'LOA') {
				record += "LOA";
			} else {
				record += "___";
			}
			record += "\n";
	});
	document.getElementById("record").innerHTML = record;
}

function clearRoster() {
	window.localStorage.attendance = '';
  window.location.reload();
}

function documentLoaded() {
	// set up roster
	roster = {};
	var roster_request = new XMLHttpRequest();
	roster_request.onload = rosterLoadDone;
	roster_request.open("GET", "/performers.json", true);
	roster_request.send();

	// set up buttons
	document.getElementById("save").addEventListener('click', saveRoster);
	document.getElementById("reset").addEventListener('click', clearRoster);
}
