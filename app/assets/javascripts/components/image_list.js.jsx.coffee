D = React.DOM

class @ImageList extends React.Component
  @propTypes =
    images: React.PropTypes.array
    authors: React.PropTypes.array

  constructor: (props) ->
    super(props)
    @state = _.pick(props, 'images')

  replaceImage: (image) ->
    images = @state.images.slice()
    index = _.findIndex(images, {id: image.id})
    if index < 0
      logError("Received update for non-existing image " + image)
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
      cb()
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
            return <Image image={image} authors={this.props.authors} key={image.id} onAction={this.handleAction.bind(this, image)}></Image>;
          }, this)
        }
      </tbody>
    </table>`
