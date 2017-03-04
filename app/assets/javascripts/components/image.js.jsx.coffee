class @Image extends React.Component
  @propTypes =
    image: React.PropTypes.object
    authors: React.PropTypes.array
    articles: React.PropTypes.array

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
        padding: '8px 0'
      mainCol:
        padding: '8px 3px'
      actionsCol:
        width: '120px'
        textAlign: 'center'
        paddingBottom: '2px'
      thumbnailCol:
        width: '150px'
      caption:
        width: '100%'
        color: '#000'
        backgroundColor: 'rgba(0, 0, 0, 0)'
        margin: 0
      attribution:
        width: '100%'
        color: '#888'
        margin: 0
        marginTop: '-5px'
        backgroundColor: 'rgba(0, 0, 0, 0)'
      articlesContainer:
        margin: '7px 5px 4px 50px'
        padding: '10px 15px'
        backgroundColor: '#eee'
      removeArticleButton:
        marginLeft: '6px'
      addArticleSelect:
        width: '100%'
        color: '#888'
      articleP:
        marginLeft: '0px'

  ################################################################################
  # Handlers
  ################################################################################

  handlePublish: (cb) ->
    @props.onAction('post', Routes.publish_image_path(@props.image), {}, cb)

  handleUnpublish: (cb) ->
    @props.onAction('post', Routes.unpublish_image_path(@props.image), {}, cb)

  handleUpdate: (params, cb) ->
    @props.onAction('patch', Routes.image_path(@props.image), params, cb)

  handleAttributionUpdate: (params, cb) ->
    if params.attribution?
      @handleUpdate({author_id: null, attribution: params.attribution}, cb)
    else
      logError("Unexpected fields in params. ")

  handleAuthorUpdate: (params, cb) ->
    if params.attribution?
      @handleUpdate({author_id: params.attribution.id, attribution: ''}, cb)
    else
      logError("Unexpected fields in params. ")

  handleRemoveArticle: (article) ->
    @props.onAction('patch', Routes.remove_article_image_path(@props.image), {article_id: article.id})

  handleDelete: (cb) ->
    @props.onAction('delete', Routes.image_path(@props.image), {}, cb)

  handleAddArticle: (article_id, cb) =>
    @props.onAction('patch', Routes.add_article_image_path(@props.image), {article_id: article_id}, cb)

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

  renderArticles: ->
    `<div style={this.styles.articlesContainer}>
      <p>Appearing with the following {pluralize(this.props.image.articles.length, 'article')}: </p>
      {
        this.props.image.articles.map(function(article, i) {
          var path = Routes.article_draft_path(article.id, article.newest_draft.id, {format: 'html'});
          return <p style={this.styles.articleP} key={article.id}>
            <a target='_blank' href={path}>{article.newest_draft.headline}</a>
            <LinkButton style={this.styles.removeArticleButton} onClick={this.handleRemoveArticle.bind(this, article)}><span className='fa fa-trash'></span></LinkButton>
          </p>
        }, this)
      }
      <AutoSelect style={this.styles.addArticleSelect}
                  titles={_.pluck(_.pluck(this.props.articles, 'newest_draft'), 'headline')}
                  ids={_.pluck(this.props.articles, 'id')}
                  prompt="Select to add an article"
                  onChange={this.handleAddArticle}/>
    </div>`

  render: ->
    `<tr>
      <td style={this.styles.statusCol}>
        {this.renderWebStatus()}
        {this.renderPrintStatus()}
      </td>
      <td style={this.styles.mainCol}>
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
                      onCommit={this.handleAttributionUpdate.bind(this)}
                      onAutocompleteCommit={this.handleAuthorUpdate.bind(this)}
                      placeholder="Add attribution to this image"
                      autoCompleteDictionary={this.props.authors}/>
        {this.renderArticles()}
      </td>
      {this.renderActions()}
      <td style={this.styles.thumbnailCol}>
        <img className="image-thumbnail"
             src={this.props.image.web_photo_thumbnail_url}/>
      </td>
    </tr>`
