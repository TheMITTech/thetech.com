class @Image extends React.Component
  @propTypes =
    image: React.PropTypes.object

  constructor: (props) ->
    super(props)
    @state = {}
    @styles =
      statusLabel:
        display: 'inline-block'
        width: '110px'
        lineHeight: '18px'
        paddingTop: '3px'
        paddingBottom: '3px'
        marginBottom: '5px'
      statusCol:
        width: '120px'
        textAlign: 'center'
      actionsCol:
        width: '120px'
        textAlign: 'center'
      thumbnailCol:
        width: '150px'
      caption:
        width: '100%'
        color: '#000'
        margin: 0
      attribution:
        width: '100%'
        color: '#888'
        margin: 0

  ################################################################################
  # Handlers
  ################################################################################

  handlePublish: (cb) ->
    @props.onAction('post', Routes.publish_image_path(@props.image), {}, cb)

  handleUnpublish: (cb) ->
    @props.onAction('post', Routes.unpublish_image_path(@props.image), {}, cb)

  handleUpdate: (params, cb) ->
    @props.onAction('patch', Routes.image_path(@props.image), params, cb)

  handleDelete: (cb) ->
    @props.onAction('delete', Routes.image_path(@props.image), {}, cb)

  ################################################################################
  # Renderers
  ################################################################################

  renderButton: (type, text, handler, cond = true, confirm = null) ->
    return null if !cond
    `<Button type={type} text={text} onClick={handler} confirm={confirm}/>`

  renderLink: (type, text, href, cond = true, confirm = null) ->
    return null if !cond
    gotoURL = (cb) ->
      window.open(href)
      cb()
    `<Button type={type} text={text} onClick={gotoURL} confirm={confirm}/>`

  renderWebStatus: ->
    switch @props.image.web_status
      when "web_published"
        `<span style={this.styles.statusLabel} className="label label-success">Web: Published</span>`
      when "web_ready"
        `<span style={this.styles.statusLabel} className="label label-info">Web: Ready</span>`
      when "web_draft"
        `<span style={this.styles.statusLabel} className="label label-warning">Web: Draft</span>`
      else
        logError("Unexpected web_status for image: " + @props.image.web_status)

  renderPrintStatus: ->
    switch @props.image.print_status
      when "print_ready"
        `<span style={this.styles.statusLabel} className="label label-success">Print: Ready</span>`
      when "print_draft"
        `<span style={this.styles.statusLabel} className="label label-warning">Print: Draft</span>`
      else
        logError("Unexpected print_status for image: " + @props.image.print_status)

  renderAttribution: ->
    # if @props.image.attribution_text.length == 0
    # else


  renderActions: ->
    `<td style={this.styles.actionsCol}>
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
      {this.renderLink('default', 'Edit', Routes.edit_image_path(this.props.image, {format: 'html'}))}
      {this.renderLink('default', 'Show', Routes.image_path(this.props.image, {format: 'html'}))}
    </td>`

  testHandleCommit: (params) =>
    console.log(params)

  render: ->
    `<tr>
      <td style={this.styles.statusCol}>
        {this.renderWebStatus()}
        {this.renderPrintStatus()}
      </td>
      <td>
        <EditableText multiline
                      readonly={!this.props.image.can_update}
                      style={this.styles.caption}
                      text={this.props.image.caption}
                      paramName="caption"
                      onCommit={this.handleUpdate.bind(this)}
                      placeholder="Add caption to this image"/>
        <EditableText readonly={!this.props.image.can_update}
                      style={this.styles.attribution}
                      text={this.props.image.attribution_text.toUpperCase()}
                      paramName="attribution"
                      onCommit={this.handleUpdate.bind(this)}
                      placeholder="Add attribution to this image"/>
      </td>
      {this.renderActions()}
      <td style={this.styles.thumbnailCol}>
        <img className="image-thumbnail"
             src={this.props.image.web_photo_thumbnail_url}/>
      </td>
    </tr>`
