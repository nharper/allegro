function AttendanceGrid(root, storage_key) {
  /**
   * Updates the display of a tile |node| to state |state|. This updates the
   * color of the div and the value in the select.
   */
  this.updateTile = function(node, state) {
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
    this.saveState(select.name, select.value);
  }

  this.saveState = function(name, value) {
    this.roster_[name] = value;
    window.localStorage.setItem(this.storage_key_, JSON.stringify({data: this.roster_, version: 1}));
  }

  this.restoreState = function() {
    var stored_state = {};
    try {
      stored_state = JSON.parse(window.localStorage.getItem(this.storage_key_));
    } catch (e) {
      console.log(e);
    }
    if (!stored_state || !stored_state.data) {
      stored_state = {data: {}, version: 1};
    }
    if (stored_state.version != 1) {
      stored_state.data = {};
    }
    return stored_state.data;
  }

  this.resetState = function() {
    window.localStorage.removeItem(this.storage_key_);
    this.roster_ = {};
    var tiles =  this.container_.querySelectorAll('.tile');
    for (var i = 0; i < tiles.length; i++) {
      this.updateTile(tiles[i], '');
    }
  }

  var toggleTile = function(e) {
    if (e.target.nodeName == 'SELECT') {
      return;
    }
    var value = e.target.querySelector('select').value;
    if (value == '') {
      this.updateTile(e.target, 'present');
    } else if (value == 'present') {
      this.updateTile(e.target, 'absent');
    } else {
      this.updateTile(e.target, '');
    }
  };
  var updateTileFromSelect = function(e) {
    this.updateTile(e.target.parentNode, e.target.value);
  };
  this.container_ = root;
  this.storage_key_ = storage_key;
  this.roster_ = {};

  var restore_state = this.restoreState();
  var tiles =  this.container_.querySelectorAll('.tile');
  for (var i = 0; i < tiles.length; i++) {
    tiles[i].addEventListener('click', toggleTile.bind(this));
    var select = tiles[i].querySelector('select');
    select.addEventListener('change', updateTileFromSelect.bind(this));

    if (restore_state[select.name]) {
      this.updateTile(tiles[i], restore_state[select.name]);
    } else {
      this.updateTile(tiles[i], select.value);
    }
  }
}

function documentLoaded(rehearsal, section) {
  attendanceGrid = new AttendanceGrid(document.getElementById("tiles"), 'attendance:' + section + ':' + rehearsal);
  // set up buttons
  var reset = document.getElementById('reset');
  reset.addEventListener('click', attendanceGrid.resetState.bind(attendanceGrid));
}
