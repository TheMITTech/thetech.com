class @EditableText extends React.Component
  @propTypes =
    text: React.PropTypes.string
    placeholder: React.PropTypes.string
    paramName: React.PropTypes.string
    onCommit: React.PropTypes.func
    readonly: React.PropTypes.bool

  componentDidMount: ->
    @doResize()

  constructor: (props) ->
    super(props)
    @state =
      text: props.text
      editing: false
      dirty: false
      busy: false
      hover: false

  doResize: =>
    @textarea.style.height = 'auto'
    @textarea.style.height = "#{@textarea.scrollHeight + 2}px"

  doSubmit: (el = null) =>
    @setState
      busy: true
      dirty: false
    params = {"#{@props.paramName}": @state.text}
    @props.onCommit params, =>
      @setState
        busy: false
        editing: false
      el.blur() unless el == null

  handleBlur: =>
    if @state.dirty
      if confirm("You have modified the text. Do you want to submit the change? ")
        @doSubmit()
      else
        @setState
          text: @props.text
          dirty: false
          editing: false

  handleChange: (e) =>
    @setState
      text: e.target.value
      dirty: true
      editing: true
    @doResize()

  handleKeyDown: (e) =>
    if e.keyCode == 13
      # Enter is pressed.
      @doSubmit(e.target)
      return false
    true

  handleMouseEnter: =>
    @setState(hover: true)

  handleMouseLeave: =>
    @setState(hover: false)

  shouldShowBorder: =>
    return false if @props.readonly
    @state.hover || @state.editing

  render: ->
    styles = _.clone(this.props.style) || {}
    styles.border = if @shouldShowBorder() then '1px solid #DDD' else '1px solid rgba(0, 0, 0, 0)'
    styles.padding = if @props.readonly then '0' else '3px 6px'
    styles.resize = 'none'
    styles.display = 'block'

    `<textarea rows="1"
               disabled={this.props.readonly || this.state.busy}
               style={styles}
               ref={(textarea) => {this.textarea = textarea}}
               onBlur={this.handleBlur}
               onChange={this.handleChange}
               onKeyDown={this.handleKeyDown}
               onMouseEnter={this.handleMouseEnter}
               onMouseLeave={this.handleMouseLeave}
               placeholder={this.props.placeholder}
               value={this.state.text} />`

    # `<p style={styles}
    #     onClick={this.handleClick}
    #     onBlur={this.handleBlur}
    #     contentEditable={this.state.editing}
    #     ref={(p) => { this.p = p; }}>{this.state.text.length > 0 ? this.state.text : this.props.placeholder}</p>`
