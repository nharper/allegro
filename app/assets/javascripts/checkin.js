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

  this.updateDisplay = function() {
    this.display_dom_node_.innerHTML = this.value_ ? this.value_ : "&nbsp;";
  };
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

  this.lookupPerformer = function(id) {
    return this.by_id_[this.cards_[id]];
  }

  this.lookupByChorusNumber = function(num) {
    return this.by_chorus_number_[num];
  }
}

function performer_card_from_checkin(performer, time) {
  var name = "Card not recognized";
  var section = "";
  var photo_path = "";
  if (performer != null) {
    name = performer.name;
    section = performer.section;
    photo_path = performer.photo_path;
  }
  var div = document.createElement('div');
  div.setAttribute('class', 'card');

  var time_span = document.createElement('span');
  time_span.setAttribute('class', 'time');
  time_span.appendChild(document.createTextNode(format_time(time)));
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

function format_time(time) {
  var h = time.getHours();
  var m = time.getMinutes();
  var pm = h > 12;
  h = h % 12;
  m = m < 10 ? "0" + m : m;
  return h + ":" + m + (pm ? " PM" : " AM");
}

function addCheckin(performer, time) {
  var card = performer_card_from_checkin(performer, time);
  var container = document.getElementById('checkin-list');
  if (container.firstChild) {
    container.insertBefore(document.createElement('hr'), container.firstChild);
    container.insertBefore(card, container.firstChild);
  } else {
    container.appendChild(card);
  }
}

function runCheckin() {
  var store = new PerformerStore();
  var k = new KeyboardListener(function(str) {
    var performer = store.lookupPerformer(str);
    addCheckin(performer, new Date());
  });
  var numpad = new Numpad(document.getElementById('numpad'), function(str) {
    var performer = store.lookupByChorusNumber(str);
    addCheckin(performer, new Date());
  });

  displayTime();
  setInterval(displayTime, 5000);
}

function displayTime() {
  var time = document.getElementById('current-time');
  while (time.lastChild) {
    time.removeChild(time.lastChild);
  }
  time.appendChild(document.createTextNode(format_time(new Date())));
}
