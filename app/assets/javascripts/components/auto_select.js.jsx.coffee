class @AutoSelect extends React.Component
  @propTypes =
    onChange: React.PropTypes.func
    confirm: React.PropTypes.string
    titles: React.PropTypes.array
    ids: React.PropTypes.array
    prompt: React.PropTypes.string

  constructor: (props) ->
    @state =
      busy: false

  handleChange: (e) =>
    return if e.target.value < 0

    if !@props.confirm? || confirm(@props.confirm)
      @setState(busy: true)
      @props.onChange e.target.value, =>
        @setState(busy: false)

  render: ->
    styles = this.props.style
    `<select style={styles} onChange={this.handleChange} disabled={this.state.busy}>
      <option key="-1" value="-1">{this.props.prompt}</option>
      {
        this.props.titles.map(function(title, i) {
          return <option key={this.props.ids[i]} value={this.props.ids[i]}>{title}</option>
        }, this)
      }
    </select>`
