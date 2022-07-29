class @EditableText extends React.Component
  @propTypes =
    text: React.PropTypes.string
    placeholder: React.PropTypes.string
    paramName: React.PropTypes.string
    onCommit: React.PropTypes.func
    onAutocompleteCommit: React.PropTypes.func
    readonly: React.PropTypes.bool
    multiline: React.PropTypes.bool
    autoCompleteDictionary: React.PropTypes.array

  componentDidMount: ->
    @doResize()

    if !@props.multiline && @props.autoCompleteDictionary?
      bloodhound = new Bloodhound
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        local: @props.autoCompleteDictionary
      @typeahead = $(@input).typeahead {hint: true, highlight: true, minLength: 1},
        {name: 'data', displayKey: 'name', source: bloodhound.ttAdapter()}
      $(@input).parents('.twitter-typeahead').css(width: @props.style.width)

      @typeahead.on 'typeahead:select typeahead:autocomplete', (_, obj) =>
        @preventSubmit = true
        @doAutocompleteSubmit(obj)
        @typeahead.typeahead('close')

  componentDidUpdate: (prevProps, prevState) ->
    @doResize()

  # TODO: Investigate, is this the right way for things?
  componentWillReceiveProps: (nextProps) ->
    if nextProps.text != @state.text
      @setState(text: nextProps.text)

  constructor: (props) ->
    super(props)
    @state =
      text: props.text
      editing: false
      busy: false
      hover: false
    @dirty = false

  doResize: =>
    return unless @props.multiline
    @textarea.style.height = 'auto'
    @textarea.style.height = "#{@textarea.scrollHeight + 2}px"

  doAutocompleteSubmit: (obj) =>
    @dirty = false
    @setState
      busy: true
    params = {"#{@props.paramName}": obj}
    @props.onAutocompleteCommit params, =>
      @setState
        busy: false
        editing: false
      @preventSubmit = false
    $(@input).blur()

  doSubmit: (el = null) =>
    @dirty = false
    @setState
      busy: true
    params = {"#{@props.paramName}": @state.text}
    @props.onCommit params, =>
      @setState
        busy: false
        editing: false
    el.blur() unless el == null

  handleBlur: =>
    if @dirty
      if confirm("You have modified the text. Do you want to submit the change? ")
        @doSubmit()
      else
        @setState
          text: @props.text
          editing: false
        @dirty = false

  handleClick: =>
    $(@input || @textarea).select()

  handleChange: (e) =>
    @setState
      text: e.target.value
      editing: true
    @dirty = true unless @preventSubmit
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

    if @props.multiline
      `<textarea rows="1"
                 disabled={this.props.readonly || this.state.busy}
                 style={styles}
                 ref={(textarea) => {this.textarea = textarea}}
                 onBlur={this.handleBlur}
                 onClick={this.handleClick}
                 onChange={this.handleChange}
                 onKeyDown={this.handleKeyDown}
                 onMouseEnter={this.handleMouseEnter}
                 onMouseLeave={this.handleMouseLeave}
                 placeholder={this.props.placeholder}
                 value={this.state.text} />`
    else
      `<input disabled={this.props.readonly || this.state.busy}
              style={styles}
              ref={(input) => {this.input = input}}
              onBlur={this.handleBlur}
              onClick={this.handleClick}
              onChange={this.handleChange}
              onKeyDown={this.handleKeyDown}
              onMouseEnter={this.handleMouseEnter}
              onMouseLeave={this.handleMouseLeave}
              placeholder={this.props.placeholder}
              value={this.state.text} />`
