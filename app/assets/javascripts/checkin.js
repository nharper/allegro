/* KeyboardListener class. Very simple - listens for all keystrokes, and posts
 * characters from them to callback one line at a time.
 * |callback| will be called with 1 argument of type string, and its return
 * value will be ignored.
 */
function KeyboardListener(callback) {
  this.buffer = '';
  document.addEventListener('keypress', function(e) {
    var code = e.keyCode;
    // 13 is CR, 10 is LF (or NL); recognize either as 'Enter'
    if (code == 13 || code == 10) {
      callback(this.buffer);
      this.buffer = '';
      return;
    }
    this.buffer += String.fromCharCode(code);
  }.bind(this));
}

function Numpad(root, enter_callback) {
  this.root_ = root;
  this.callback_ = enter_callback;
  this.value_ = '';
  this.display_dom_node_ = root.querySelector("#numpad-input");
  this._buildDisplay();
};

Numpad.prototype.updateDisplay = function() {
  this.display_dom_node_.innerHTML = this.value_ ? this.value_ : "&nbsp;";
};

Numpad.prototype._buildDisplay = function() {
  for (var i = 1; i < 10; i++) {
    this._addNum(i);
  }
  var del = document.createElement('span');
  del.classList.add('num');
  del.id = 'delete';
  del.appendChild(document.createTextNode('⌫'));
  del.addEventListener('click', function() {
    this.value_ = this.value_.slice(0, -1);
    this.updateDisplay();
  }.bind(this));
  this.root_.appendChild(del);
  this._addNum('0');
  var enter = document.createElement('span');
  enter.classList.add('num');
  enter.id = 'enter';
  enter.appendChild(document.createTextNode('⏎'));
  enter.addEventListener('click', function() {
    this.callback_(this.value_);
    this.value_ = '';
    this.updateDisplay();
  }.bind(this));
  this.root_.appendChild(enter);
}

Numpad.prototype._addNum = function(num) {
  var key = document.createElement('span');
  key.classList.add('num');
  key.appendChild(document.createTextNode(num));
  key.addEventListener('click', function(num) {
    this.value_ += num;
    this.updateDisplay();
  }.bind(this, num));
  this.root_.appendChild(key);
}

function PerformerStore(loaded_callback) {
  this.cards_ = {};
  this.by_id_ = {};
  this.by_chorus_number_ = {};

  var card_request = new XMLHttpRequest();
  card_request.onload = function(p) {
    var cards = JSON.parse(p.target.responseText);
    cards.forEach(function(card) {
      this.cards_[card.card_id] = card.performer_id;
    }.bind(this));
  }.bind(this);
  card_request.open('GET', '/cards.json', true);
  card_request.send();

  var performers_request = new XMLHttpRequest();
  performers_request.onload = function(callback, p) {
    var performers = JSON.parse(p.target.responseText);
    performers.forEach(function(performer) {
      this.by_id_[performer.id] = performer;
      this.by_chorus_number_[performer.chorus_number] = performer;
    }.bind(this));
    callback();
  }.bind(this, loaded_callback);
  performers_request.open('GET', '/performers.json', true);
  performers_request.send();
}

PerformerStore.prototype.lookupPerformer = function(id) {
  return this.by_id_[this.cards_[id]];
}

PerformerStore.prototype.lookupById = function(id) {
  return this.by_id_[id];
}

PerformerStore.prototype.lookupByChorusNumber = function(num) {
  return this.by_chorus_number_[num];
}

function CheckinDisplay(parent_node) {
  this.node = parent_node;
}

CheckinDisplay.prototype._cardFromCheckin = function(checkin) {
  var name = "Card not recognized";
  var section = "";
  var photo_path = "";
  if (checkin.performer != null) {
    name = checkin.performer.name;
    section = checkin.performer.section;
    photo_path = checkin.performer.photo_path;
  }
  var div = document.createElement('div');
  div.setAttribute('class', 'card');

  var time_span = document.createElement('span');
  time_span.setAttribute('class', 'time');
  time_span.appendChild(document.createTextNode(format_time(checkin.time)));
  div.appendChild(time_span);

  var performer_div = document.createElement('div');
  performer_div.setAttribute('class', 'performer');
  var img = document.createElement('img');
  img.setAttribute('class', 'pic');
  img.src = photo_path;
  performer_div.appendChild(img);
  var name_span = document.createElement('span');
  name_span.setAttribute('class', 'name');
  name_span.appendChild(document.createTextNode(name));
  performer_div.appendChild(name_span);
  performer_div.appendChild(document.createElement('br'));
  var section_span = document.createElement('span');
  section_span.setAttribute('class', 'section');
  section_span.appendChild(document.createTextNode(section));
  performer_div.appendChild(section_span);

  div.appendChild(performer_div);
  return div;
}

CheckinDisplay.prototype.add = function(checkin) {
  var card = this._cardFromCheckin(checkin);
  if (this.node.firstChild) {
    this.node.insertBefore(document.createElement('hr'), this.node.firstChild);
    this.node.insertBefore(card, this.node.firstChild);
  } else {
    this.node.appendChild(card);
  }
}

function format_time(time) {
  var h = time.getHours();
  var m = time.getMinutes();
  var pm = h >= 12;
  h = ((h - 1) % 12) + 1;
  m = m < 10 ? "0" + m : m;
  return h + ":" + m + (pm ? " PM" : " AM");
}

function Checkin(performer, time, type) {
  this.performer = performer;
  this.time = time;
  this.type = type;
}

/* Stores checkin records, and persists them to local storage.
 */
function Checkins(performer_store) {
  this.checkins_ = [];
  this.checkin_type_ = 'checkin';
  this.performer_store_ = performer_store;
  // TODO(nharper): consider using a different storage key?
  this.storage_key_ = window.location.pathname;

  this.listeners_ = {
    'load': [function(e){console.log('load');console.log(e)}],
    'error': [function(e){console.log('error');console.log(e)}],
  };
  this._loadFromLocalStorage();
}

Checkins.prototype._callListeners = function(eventType, event) {
  this.listeners_[eventType].forEach(function(listener) {
    listener(event);
  }.bind(this));
}

Checkins.prototype.setCheckinType = function(type) {
  this.checkin_type_ = type;
}

Checkins.prototype.addCheckin = function(checkin) {
  if (!checkin.performer) {
    return;
  }
  checkin.type = this.checkin_type_;
  this.checkins_.push(checkin);
  this._updateLocalStorage();
}

Checkins.prototype._updateLocalStorage = function() {
  window.localStorage.setItem(this.storage_key_, this.serialize());
}

Checkins.prototype._clear = function() {
  window.localStorage.removeItem(this.storage_key_);
  this.checkins_ = [];
  // TODO(nharper): view will also want to know that data is cleared. Is caller
  // going to relay this call to the view, or is this going to propogate it
  // somehow?
}

Checkins.prototype._loadFromLocalStorage = function(callback) {
  try {
    var checkins = JSON.parse(window.localStorage.getItem(this.storage_key_));
    for (i in checkins) {
      console.log(checkins[i].performer);
      var checkin = new Checkin(
          this.performer_store_.lookupById(checkins[i].performer),
          new Date(checkins[i].time),
          checkins[i].type);
      this.checkins_.push(checkin);
      if (callback) {
        callback(checkin);
      }
    }
  } catch (e) {
    console.log(e);
  }
}


Checkins.prototype.serialize = function() {
  return JSON.stringify(this.checkins_.map(function(checkin) {
    return {
      'performer': checkin.performer.id,
      'time': checkin.time.getTime(),
      'type': checkin.type,
    };
  }));
}

Checkins.prototype.saveToServer = function() {
  var request_data = this.serialize();
  var csrf_token = document.getElementsByTagName('meta')['csrf-token'].content;
  var post_request = new XMLHttpRequest();
  post_request.addEventListener('load', function(e) {
    if (e.target.status == 200) {
      this._callListeners('load', e);
    } else {
      this._callListeners('error', e);
    }
  }.bind(this));
  post_request.addEventListener('error', function(e) {
    this._callListeners('error', e);
  }.bind(this));

  var csrf_token_request = new XMLHttpRequest();
  var csrf_token = '';
  csrf_token_request.addEventListener('load', function(e) {
    var request = e.target;
    // Check for status == 302 (redirect) - means need to log in again.
    if (request.status != 200) {
      this._callListeners('error', e);
    }
    csrf_token = request.responseText;

    post_request.open('POST', window.location.pathname, true);
    post_request.setRequestHeader('Content-type', 'application/json');
    post_request.setRequestHeader('X-CSRF-Token', csrf_token);
    post_request.send(request_data);
  }.bind(this));
  csrf_token_request.addEventListener('error', function(e) {
    this._callListeners('error', e);
  }.bind(this));
  csrf_token_request.open('GET', '/auth/token', true);
  csrf_token_request.send();
}

function performerStoreLoaded() {
  checkins = new Checkins(store);
  var display = new CheckinDisplay(document.getElementById('checkin-list'));
  var callback = function(lookup_callback, str) {
    var performer = lookup_callback(str);
    var checkin = new Checkin(performer, new Date());
    display.add(checkin);
    checkins.addCheckin(checkin);
  };
  var k = new KeyboardListener(
      callback.bind(this, store.lookupPerformer.bind(store)));
  var numpad = new Numpad(document.getElementById('numpad'),
      callback.bind(this, store.lookupByChorusNumber.bind(store)));

  displayTime();
  setInterval(displayTime, 5000);

  document.getElementById('upload').addEventListener('click', checkins.saveToServer.bind(checkins));

  document.getElementById('type').addEventListener('click', function(e) {
    var checkin_type = 'checkin';
    if (e.target.innerText == 'checkin') {
      checkin_type = 'checkout';
    }
    e.target.innerText = checkin_type;
    checkins.setCheckinType(checkin_type);
  });
}

function runCheckin() {
  store = new PerformerStore(performerStoreLoaded);
}

function displayTime() {
  var time = document.getElementById('current-time');
  while (time.lastChild) {
    time.removeChild(time.lastChild);
  }
  time.appendChild(document.createTextNode(format_time(new Date())));
}
