class @Image extends React.Component
  @propTypes =
    image: React.PropTypes.object

  constructor: (props) ->
    super(props)
    @state = {}

  ################################################################################
  # Handlers
  ################################################################################

  handlePublish: ->
    @props.onAction('post', Routes.publish_image_path(@props.image))

  handleUnpublish: ->
    @props.onAction('post', Routes.unpublish_image_path(@props.image))

  handleUpdate: (params) ->
    @props.onAction('patch', Routes.image_path(@props.image), params)

  handleDelete: ->
    @props.onAction('delete', Routes.image_path(@props.image))

  ################################################################################
  # Renderers
  ################################################################################

  renderButton: (type, text, handler, cond = true, confirm = null) ->
    return null if !cond
    `<button className={"btn btn-" + type + " btn-sm"} onClick={handler} data-confirm={confirm}>{text}</button>`

  renderLink: (type, text, href, cond = true) ->
    return null if !cond
    `<a href={href} className={"btn btn-" + type + " btn-sm"} target="_blank">{text}</a>`

  renderWebStatus: ->
    switch @props.image.web_status
      when "web_published"
        `<span className="label label-success">Web: Published</span>`
      when "web_ready"
        `<span className="label label-info">Web: Ready</span>`
      when "web_draft"
        `<span className="label label-warning">Web: Draft</span>`
      else
        logError("Unexpected web_status for image: " + @props.image.web_status)

  renderPrintStatus: ->
    switch @props.image.print_status
      when "print_ready"
        `<span className="label label-success">Print: Ready</span>`
      when "print_draft"
        `<span className="label label-warning">Print: Draft</span>`
      else
        logError("Unexpected print_status for image: " + @props.image.print_status)

  renderAttribution: ->
    # if @props.image.attribution_text.length == 0
    # else


  renderActions: ->
    `<td className="actions">
      {this.renderButton('success', 'Web Ready', this.handleUpdate.bind(this, {web_status: 'web_ready'}),
        (this.props.image.web_status == "web_draft" && this.props.image.can_update))}
      {this.renderButton('success', 'Publish', this.handlePublish.bind(this),
        (this.props.image.web_status == "web_ready" && this.props.image.can_publish))}
      {this.renderButton('danger', 'Unpublish', this.handleUnpublish.bind(this),
        (this.props.image.web_status == "web_published" && this.props.image.can_unpublish))}
      {this.renderButton('success', 'Print Ready', this.handleUpdate.bind(this, {print_status: 'print_ready'}),
        (this.props.image.print_status == "print_draft" && this.props.image.can_update))}
      {this.renderButton('danger', 'Delete', this.handleDelete.bind(this),
        (this.props.image.web_status != "web_published" && this.props.image.can_destroy),
        'Are you sure that you want to delete this image? ')}
      {this.renderLink('default', 'Edit', Routes.edit_image_path(this.props.image))}
      {this.renderLink('default', 'Show', Routes.image_path(this.props.image))}
    </td>`

  render: ->
    `<tr>
      <td className="statuses">
        {this.renderWebStatus()}
        {this.renderPrintStatus()}
      </td>
      <td>
        <p>{this.props.image.caption || "Uncaptioned Image"}</p>
        {this.renderAttribution()}
      </td>
      {this.renderActions()}
      <td className="thumb">
        <img className="image-thumbnail" src={this.props.image.web_photo_thumbnail_url}/>
      </td>
    </tr>`
