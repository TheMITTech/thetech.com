D = React.DOM

class @ImageList extends React.Component
  @propTypes =
    images: React.PropTypes.array
    authors: React.PropTypes.array
    articles: React.PropTypes.array
    fetch: React.PropTypes.string

  appendImages: (images) =>
    @setState
      page: @state.page + 1
      images: @state.images.concat(images)

  loadNextPage: =>
    @setState loading: true
    axios.get(@nextPage).then (resp) =>
      if resp.data.error
        alert(resp.data.error)
      else
        @nextPage = resp.data.nextPage
        @setState
          loading: false
        @appendImages(resp.data.images)
    .catch (err) =>
      logError(err)
      alert("Unknown error. Please refresh the page. ")

  componentDidMount: ->
    MessageBus.subscribe '/updates', (data) =>
      if data.model == 'image'
        axios.get(Routes.image_path(data.id)).then (resp) =>
          if resp.data.error
            alert(resp.data.error)
          else
            @replaceImage(resp.data.image)
        .catch (err) =>
          logError(err)
          alert("Unknown error. Please refresh the page. ")

    if @props.fetch?
      @nextPage = @props.fetch
      @loadNextPage()

    $(@refs.infiniteScrollTrigger).appear()
    $(@refs.infiniteScrollTrigger).on 'appear', =>
      return if @state.loading
      return unless @nextPage?
      @loadNextPage()

  constructor: (props) ->
    super(props)
    @state =
      images: @props.images
      loading: true
    @styles =
      infiniteScrollTriggerRow:
        textAlign: 'center'
        fontSize: '40px'

  replaceImage: (image) ->
    images = @state.images.slice()
    index = _.findIndex(images, {id: image.id})
    if index < 0
      return
    if image.destroyed
      images.splice(index, 1)
    else
      images[index] = image
    @setState(images: images)

  handleAction: (image, method, path, params, cb) ->
    axios
      method: method,
      url: path,
      data: params
    .then (resp) =>
      cb() if cb?
      if resp.data.error
        alert(resp.data.error)
      else
        @replaceImage(resp.data.image)
    .catch (err) =>
      logError(err)
      alert("Cannot complete the action. Please refresh the page and try again. ")

  handleSearchKeyDown: (e) =>
    if e.keyCode == 13
      @setState images: []
      @nextPage = Routes.images_path(q: e.target.value)
      @loadNextPage()

  render: ->
    `<table className="table">
      <thead>
        <tr>
          <th className="center">Status</th>
          <th>Image</th>
          <th></th>
          <th className="center image-thumbnail-header">Thumbnail</th>
        </tr>
        <tr>
          <td colSpan="4">
            <input className="form-control" onKeyDown={this.handleSearchKeyDown} placeholder='Search for images by volume (e.g. "V134 N7") or by text. Press ENTER to search. '/>
          </td>
        </tr>
      </thead>
      <tbody>
        {
          this.state.images.map(function(image, i) {
            return <Image image={image} authors={this.props.authors} articles={this.props.articles} key={image.id} onAction={this.handleAction.bind(this, image)}></Image>;
          }, this)
        }
        <tr style={this.styles.infiniteScrollTriggerRow} data-appear-top-offset="400" ref="infiniteScrollTrigger">
          <td colSpan="4">{this.state.loading ? <i className="fa fa-spin fa-circle-o-notch"></i> : null }</td>
        </tr>
      </tbody>
    </table>`
