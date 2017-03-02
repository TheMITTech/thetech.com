class @EditableText extends React.Component
  @propTypes =
    text: React.PropTypes.string
    placeholder: React.PropTypes.string
    paramName: React.PropTypes.string
    onCommit: React.PropTypes.func
    readonly: React.PropTypes.bool

  constructor: (props) ->
    super(props)
    @state =
      text: props.text
      dirty: false
      busy: false
      height: 'auto'

  doSubmit: (el = null) =>
    @setState
      busy: true
      dirty: false
    params = {"#{@props.paramName}": @state.text}
    @props.onCommit params, =>
      @setState(busy: false)
      el.blur() unless el == null

  handleBlur: =>
    if @state.dirty
      if confirm("You have modified the text. Do you want to submit the change? ")
        @doSubmit()
      else
        @setState
          text: @props.text
          dirty: false

  handleChange: (e) =>
    @setState
      text: e.target.value
      dirty: true
      height: "#{e.target.scrollHeight}px"

  handleKeyDown: (e) =>
    if e.keyCode == 13
      # Enter is pressed.
      @doSubmit(e.target)
      return false
    true

  render: ->
    styles = _.clone(this.props.style) || {}
    styles.border = if @props.readonly then 'none' else '1px solid #DDD'
    styles.padding = if @props.readonly then '0' else '4px 6px'
    styles.resize = 'none'
    styles.height = @state.height

    `<textarea rows="1"
               disabled={this.props.readonly || this.state.busy}
               style={styles}
               onBlur={this.handleBlur}
               onChange={this.handleChange}
               onKeyDown={this.handleKeyDown}
               placeholder={this.props.placeholder}
               value={this.state.text} />`

    # `<p style={styles}
    #     onClick={this.handleClick}
    #     onBlur={this.handleBlur}
    #     contentEditable={this.state.editing}
    #     ref={(p) => { this.p = p; }}>{this.state.text.length > 0 ? this.state.text : this.props.placeholder}</p>`
