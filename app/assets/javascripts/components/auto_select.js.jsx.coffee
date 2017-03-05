class @AutoSelect extends React.Component
  @propTypes =
    onChange: React.PropTypes.func
    confirm: React.PropTypes.string
    titles: React.PropTypes.array
    ids: React.PropTypes.array
    prompt: React.PropTypes.string
    initial: React.PropTypes.number

  # TODO: Investigate, is this the right way for things?
  componentWillReceiveProps: (nextProps) ->
    @setState value: nextProps.initial || -1

  constructor: (props) ->
    @state =
      busy: false
      value: props.initial || -1

  handleChange: (e) =>
    @setState value: e.target.value
    return if e.target.value < 0

    if !@props.confirm? || confirm(@props.confirm)
      @setState(busy: true)
      @props.onChange e.target.value, =>
        @setState(busy: false)

  render: ->
    styles = this.props.style || {}
    styles.WebkitAppearance = 'none'
    styles.backgroundImage = 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAAJCAYAAAA/33wPAAAAvklEQVQoFY2QMQqEMBBFv7ERa/EMXkGw11K8QbDXzuN4BHv7QO6ifUgj7v4UAdlVM8Uwf+b9YZJISnlqrfEUZVlinucnBGKaJgghbiHOyLyFKIoCbdvecpyReYvo/Ma2bajrGtbaC58kCdZ1RZ7nl/4/4d5EsO/7nzl7IUtodBexMMagaRrs+06JLMvcNWmaOv2W/C/TMAyD58dxROgSmvxFFMdxoOs6lliWBXEcuzokXRbRoJRyvqqqQvye+QDMDz1D6yuj9wAAAABJRU5ErkJggg==)'
    styles.backgroundPosition = 'right center';
    styles.backgroundRepeat = 'no-repeat';
    styles.padding = '2px 10px';
    styles.borderRadius = '0';
    styles.border = '1px solid #DDD'

    `<select value={this.props.initial} style={styles} onChange={this.handleChange} disabled={this.state.busy}>
      {
        this.props.propmt != null && this.props.prompt != undefined &&
          <option key="-1" value="-1">{this.props.prompt}</option>
      }
      {
        this.props.titles.map(function(title, i) {
          return <option key={this.props.ids[i]} value={this.props.ids[i]}>{title}</option>
        }, this)
      }
    </select>`
