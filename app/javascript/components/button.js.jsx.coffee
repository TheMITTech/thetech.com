class @Button extends React.Component
  @propTypes =
    text: React.PropTypes.string
    type: React.PropTypes.oneOf(['danger','info','warning','success','default'])
    onClick: React.PropTypes.func
    confirm: React.PropTypes.string
    highlighed: React.PropTypes.bool

  constructor: (props) ->
    @state =
      busy: false

  handleClick: =>
    if @state.busy
      logError("Button clicked while supposedly disabled. ")
      return

    if (!@props.confirm?) || confirm(@props.confirm)
      @setState(busy: true)
      @props.onClick =>
        @setState(busy: false)

  render: ->
    styles =
      display: 'block'
      marginBottom: '6px'
      width: '110px'

    activeClass = if @props.highlighted then " active" else ""

    `<button style={_.extend(styles, this.props.style)}
             className={"btn btn-sm btn-" + this.props.type + activeClass}
             disabled={this.state.busy}
             onClick={this.handleClick}>{this.state.busy ? <i className="fa fa-spin fa-circle-o-notch"></i> : this.props.text}</button>`
