class @LinkButton extends React.Component
  @propTypes =
    onClick: React.PropTypes.func
    confirm: React.PropTypes.string

  constructor: (props) ->
    @state =
      busy: false

  handleClick: =>
    if @state.busy
      logError("LinkButton clicked while supposedly disabled. ")
      return

    if (!@props.confirm?) || confirm(@props.confirm)
      @setState(busy: true)
      @props.onClick =>
        @setState(busy: false)

  render: ->
    `<a style={this.props.style}
        disabled={this.state.busy}
        onClick={this.handleClick}>{this.state.busy ? <i className="fa fa-spin fa-circle-o-notch"></i> : this.props.children}</a>`
