class @StatusLabel extends React.Component
  @propTypes =
    type: React.PropTypes.oneOf(['danger','info','warning','success','default'])

  render: ->
    styles =
      display: 'inline-block'
      width: '110px'
      lineHeight: '18px'
      paddingTop: '3px'
      paddingBottom: '3px'
      marginBottom: '5px'

    `<span style={_.extend(styles, this.props.style)} className={"label label-" + this.props.type}>{this.props.children}</span>`
