class @Button extends React.Component
  @propTypes =
    text: React.PropTypes.string
    type: React.PropTypes.oneOf(['danger','info','warning','success'])
    onClick: React.PropTypes.func
    confirm: React.PropTypes.string

  constructor: (props) ->
    @state =
      busy: false

  handleClick: =>
    if @state.busy
      logError("Button clicked while supposedly disabled. ")
      return

    if (@props.confirm == null) || confirm(@props.confirm)
      @setState(busy: true)
      @props.onClick()

  render: ->
    `<button className={"btn btn-sm btn-" + this.props.type}
             disabled={this.state.busy}
             onClick={this.handleClick}>{this.state.busy ? <i className="fa fa-spin fa-circle-o-notch"></i> : this.props.text}</button>`
