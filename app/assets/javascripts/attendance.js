function updateTile(node, state) {
  var select = node.querySelector('select');
	switch (state) {
		case 'present':
			node.classList.remove('present-false');
			node.classList.remove('present-unknown');
			node.classList.add('present-true');
      select.value = 'present';
			break;
		case 'absent':
			node.classList.add('present-false');
			node.classList.remove('present-unknown');
			node.classList.remove('present-true');
      select.value = 'absent';
			break;
		default:
			node.classList.remove('present-false');
			node.classList.add('present-unknown');
			node.classList.remove('present-true');
      select.value = '';
			break;
	}
}

/*
function saveRoster() {
  var stored_roster = {data: {}, version: 1};
  roster.forEach(function(performer) {
    stored_roster.data[performer.number] = performer;
  });
	window.localStorage.attendance = JSON.stringify(stored_roster);
	var record = "";
}

function clearRoster() {
	window.localStorage.attendance = '';
  window.location.reload();
}
*/

function toggleTile(e) {
  if (e.target.nodeName == 'SELECT') {
    return;
  }
  var value = this.querySelector('select').value;
  if (value == '') {
    updateTile(this, 'present');
  } else if (value == 'present') {
    updateTile(this, 'absent');
  } else {
    updateTile(this, '');
  }
}

function updateTileFromSelect() {
  updateTile(this.parentNode, this.value);
}

function documentLoaded() {
  var container = document.getElementById("tiles");
  var tiles = container.querySelectorAll(".tile");
  for (var i = 0; i < tiles.length; i++) {
    tiles[i].addEventListener('click', toggleTile);
    tiles[i].querySelector('select').addEventListener('change', updateTileFromSelect);
  }

	// set up roster
	roster = {};

	// set up buttons
	// document.getElementById("save").addEventListener('click', saveRoster);
	// document.getElementById("reset").addEventListener('click', clearRoster);
}
