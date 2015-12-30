var AttendanceList = React.createClass({
  'rehearsals': function() {
    return this.props.rehearsals.map(function(rehearsal) {
      var reh = rehearsal;
      rehearsal.start_date = new Date(rehearsal.start_date);
      rehearsal.end_date = new Date(rehearsal.end_date);
      return rehearsal;
    });
  },

  'render': function() {
    return <AttendanceTable rehearsals={this.rehearsals()} performers={this.props.performers} records={this.props.records} />;
  }
});

var AttendanceTable = React.createClass({
  'records': function(performer) {
    return this.props.records[performer.id];
  },

  'render': function() {
    var headers = this.props.rehearsals.map(function(rehearsal) {
      var start_date = new Date(rehearsal.start_date);
      var date_str = (start_date.getMonth() + 1) + '-' + start_date.getDate();
      return (
        <th key={rehearsal.id}>{date_str}</th>
      );
    });

    var rows = this.props.performers.map(function(performer) {
      return (
        <AttendanceTableRow performer={performer} rehearsals={this.props.rehearsals} records={this.records(performer)} key={performer.id}/>
      );
    }.bind(this));
    return (
      <table className="attendance">
        <tbody>
          <tr>
            <th>#</th>
            <th>Performer</th>
            {headers}
            <th>Missed Mondays</th>
            <th>Sectionals Attended</th>
            <th>Total Missed</th>
          </tr>
          {rows}
        </tbody>
      </table>
    );
  }
});

var AttendanceTableRow = React.createClass({
  'performer': function() {
    return this.props.performer;
  },
  'rehearsals': function() {
    return this.props.rehearsals;
  },
  'records': function() {
    return this.props.records;
  },
  'render': function() {
    var missed = 0;
    var sectionals = 0;
    var records = this.rehearsals().map(function(rehearsal) {
      var record = this.records()[rehearsal.id];
      var display_class = 'unknown';
      var symbol = '?';
      if (record) {
        if (record.present) {
          display_class = 'present';
          symbol = "\u2713";
          if (rehearsal.attendance == 'optional') {
            sectionals += rehearsal.weight;
          }
        } else {
          display_class = 'absent';
          symbol = "\u2717";
          if (rehearsal.attendance == 'required') {
            missed += rehearsal.weight;
          }
        }
      }
      symbol = symbol.repeat(rehearsal.weight);
      var start_date = new Date(rehearsal.start_date);
      var title = (start_date.getMonth() + 1) + '-' + start_date.getDate();
      if (rehearsal.name) {
        title = rehearsal.name + ' (' + title + ')';
      }
      return (
        <td key={rehearsal.id}
            className={display_class + ' record'}
            title={title}>
          {symbol}
        </td>
      );
    }.bind(this));
    return (
      <tr>
        <td>{this.performer().chorus_number}</td>
        <td>{this.performer().name}</td>
        {records}
        <td>{missed}</td>
        <td>{sectionals}</td>
        <td>{missed - sectionals}</td>
      </tr>
    );
  }
});
