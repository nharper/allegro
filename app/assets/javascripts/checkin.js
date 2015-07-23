/* KeyboardListener class. Very simple - listens for all keystrokes, and posts
 * characters from them to callback one line at a time.
 * |callback| will be called with 1 argument of type string, and its return
 * value will be ignored.
 */
function KeyboardListener(callback) {
  this.buffer = '';
  document.addEventListener('keypress', function(e) {
    var code = e.keyCode;
    if (code == 13) { // 13 is CR, the keycode sent when 'Enter' is pressed
      callback(this.buffer);
      this.buffer = '';
      return;
    }
    this.buffer += String.fromCharCode(code);
  }.bind(this));
}

/* Performer class
 */
function Performer(name) {
  this.name_ = name;
}

function PerformerStore() {
  this.table_ = {
    'n': new Performer('Nick Harper'),
    'j': new Performer('Justin Taylor'),
    's': new Performer('Scott Mills'),
  };

  this.lookupPerformer = function(id) {
    return this.table_[id];
  }
}

function postInput(str) {
  var div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  var container = document.getElementById('content-wrapper');
  if (container.firstChild) {
    container.insertBefore(div, container.firstChild);
  } else {
    container.appendChild(div);
  }
}

function runCheckin() {
  var k = new KeyboardListener(postInput);
}
