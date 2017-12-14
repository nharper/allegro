class SectionSelector extends React.Component {
  constructor(props) {
    super(props);
    var sections = {};
    for (var section in this.props.sections) {
      sections[section] = this.props.initialSectionState[section];
    }
    this.state = {'sections':sections};
  }

  handleChange(section, checked) {
    this.props.onSectionChange(section, checked);
    this.setState(function(oldState, props) {
      oldState.sections[section] = checked;
      return oldState;
    });
  }

  setAll(checked) {
    for (var section in this.props.sections) {
      ReactDOM.findDOMNode(this.refs[section]).checked = checked;
      this.handleChange(section, checked);
    }
  }

  render() {
    var checks = [];
    for (var section in this.props.sections) {
      checks.push(
        <input
            type="checkbox"
            checked={this.state.sections[section]}
            ref={section}
            id={section}
            key={section + '.input'}
            onChange={function(section, e) {this.handleChange(section, e.target.checked)}.bind(this, section)}
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
}
