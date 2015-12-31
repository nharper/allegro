var SectionSelector = React.createClass({
  'getInitialState': function() {
    var sections = {};
    for (var section in this.props.sections) {
      sections[section] = this.props.initialSectionState[section];
    }
    return {'sections':sections};
  },
  'handleChange': function(section, checked) {
    this.props.onSectionChange(section, checked);
    this.setState(function(oldState, props) {
      oldState.sections[section] = checked;
      return oldState;
    });
  },
  'setAll': function(checked) {
    for (var section in this.props.sections) {
      ReactDOM.findDOMNode(this.refs[section]).checked = checked;
      this.handleChange(section, checked);
    }
  },
  'render': function() {
    var checks = [];
    for (var section in this.props.sections) {
      checks.push(
        <input
            type="checkbox"
            checked={this.state.sections[section]}
            ref={section}
            id={section}
            key={section + '.input'}
            onChange={function(e) {this.handleChange(section, e.target.checked)}.bind(this)}
        />
      );
      checks.push(
        <label htmlFor={section} key={section + '.label'}>
          {this.props.sections[section]}
        </label>
      );
    }
    return (
      <div className="section-selector">
        {checks}
        <input type="button" value="Select All" onClick={this.setAll.bind(this, true)} />
        <input type="button" value="Clear All" onClick={this.setAll.bind(this, false)} />
      </div>
    );
  }
});
