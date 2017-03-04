D = React.DOM

class @ImageList extends React.Component
  @propTypes =
    images: React.PropTypes.array
    authors: React.PropTypes.array
    articles: React.PropTypes.array
    infiniteScroll: React.PropTypes.bool

  appendImages: (images) =>
    @setState
      page: @state.page + 1
      images: @state.images.concat(images)

  loadNextPage: =>
    @setState loading: true
    axios.get(Routes.images_path(page: @state.page)).then (resp) =>
      if resp.data.error
        alert(resp.data.error)
      else
        @setState loading: false
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

    @loadNextPage() if @props.infiniteScroll

    $(@refs.infiniteScrollTrigger).appear()
    $(@refs.infiniteScrollTrigger).on 'appear', =>
      return if @state.loading
      @loadNextPage()

  constructor: (props) ->
    super(props)
    @state =
      images: @props.images
      page: 1
      loading: false
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

  render: ->
    `<table className="table">
      <thead>
        <tr>
          <th className="center">Status</th>
          <th>Image</th>
          <th></th>
          <th className="center image-thumbnail-header">Thumbnail</th>
        </tr>
      </thead>
      <tbody>
        {
          this.state.images.map(function(image, i) {
            return <Image image={image} authors={this.props.authors} articles={this.props.articles} key={image.id} onAction={this.handleAction.bind(this, image)}></Image>;
          }, this)
        }
        <tr style={this.styles.infiniteScrollTriggerRow} ref="infiniteScrollTrigger">
          <td colSpan="4">{this.state.loading ? <i className="fa fa-spin fa-circle-o-notch"></i> : null }</td>
        </tr>
      </tbody>
    </table>`
