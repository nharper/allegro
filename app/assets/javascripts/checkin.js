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

  for (var i = 0; i < 10; i++) {
    var key = this.root_.querySelector("#n" + i);
    key.addEventListener('click', function(i) {
      this.value_ += i;
      this.updateDisplay();
    }.bind(this, i));
  }
  this.root_.querySelector("#delete").addEventListener('click', function(e) {
    this.value_ = this.value_.slice(0, -1);
    this.updateDisplay();
  }.bind(this));
  this.root_.querySelector("#enter").addEventListener('click', function(e) {
    this.callback_(this.value_);
    this.value_ = '';
    this.updateDisplay();
  }.bind(this));
};

Numpad.prototype.updateDisplay = function() {
  this.display_dom_node_.innerHTML = this.value_ ? this.value_ : "&nbsp;";
};

function PerformerStore() {
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
  performers_request.onload = function(p) {
    var performers = JSON.parse(p.target.responseText);
    performers.forEach(function(performer) {
      this.by_id_[performer.id] = performer;
      this.by_chorus_number_[performer.chorus_number] = performer;
    }.bind(this));
  }.bind(this);
  performers_request.open('GET', '/performers.json', true);
  performers_request.send();
}

PerformerStore.prototype.lookupPerformer = function(id) {
  return this.by_id_[this.cards_[id]];
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
  var pm = h > 12;
  h = h % 12;
  m = m < 10 ? "0" + m : m;
  return h + ":" + m + (pm ? " PM" : " AM");
}

function Checkin(performer, time) {
  this.performer = performer;
  this.time = time;
}

function runCheckin() {
  checkins = [];
  var store = new PerformerStore();
  var display = new CheckinDisplay(document.getElementById('checkin-list'));
  var callback = function(lookup_callback, str) {
    var performer = lookup_callback(str);
    var checkin = new Checkin(performer, new Date());
    display.add(checkin);
    checkins.push(checkin);
  };
  var k = new KeyboardListener(
      callback.bind(this, store.lookupPerformer.bind(store)));
  var numpad = new Numpad(document.getElementById('numpad'),
      callback.bind(this, store.lookupByChorusNumber.bind(store)));

  displayTime();
  setInterval(displayTime, 5000);

  document.getElementById('upload').addEventListener('click', function() {
    console.log(checkins);
    var request_data = JSON.stringify(checkins.filter(function(checkin) {
      if (checkin.performer) {
        return checkin;
      }
    }).map(function(checkin) {
      return {'performer': checkin.performer.id, 'time': checkin.time};
    }));
    var csrf_token = document.getElementsByTagName('meta')['csrf-token'].content;
    var post_request = new XMLHttpRequest();
    post_request.open('POST', window.location.pathname, true);
    post_request.setRequestHeader('Content-type', 'application/json');
    post_request.setRequestHeader('X-CSRF-Token', csrf_token);
    post_request.send(request_data);
  });
}

function displayTime() {
  var time = document.getElementById('current-time');
  while (time.lastChild) {
    time.removeChild(time.lastChild);
  }
  time.appendChild(document.createTextNode(format_time(new Date())));
}
