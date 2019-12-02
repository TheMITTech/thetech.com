class @Article extends React.Component
  @propTypes =
    article: React.PropTypes.object
    authors: React.PropTypes.array
    articles: React.PropTypes.array
    rankSelect: React.PropTypes.bool
    from_issues_page: React.PropTypes.integer

  constructor: (props) ->
    super(props)
    @state = {}
    @styles =
      statusCol:
        width: '120px'
        textAlign: 'center'
        padding: '8px 0'
      mainCol:
        padding: '8px 6px'
      actionsCol:
        width: '120px'
        textAlign: 'center'
        paddingBottom: '2px'
      label:
        marginRight: '4px'
      slug:
        fontWeight: 'bold'
        marginLeft: '3px'
        marginRight: '4px'
      headline:
        marginLeft: '4px'
      publishTime:
        marginRight: '4px'
      authors:
        marginLeft: '4px'
      secondaryLine:
        color: '#888'
      rankSelect:
        width: '60px'

  ################################################################################
  # Handlers
  ################################################################################

  handlePublish: (cb) =>
    @props.onAction('post', Routes.publish_article_draft_path(@props.article, @props.article.pending_draft.id), {}, cb)

  handleUnpublish: (cb) =>
    @props.onAction('post', Routes.unpublish_article_path(@props.article), {}, cb)

  handleDelete: (cb) =>
    @props.onAction('delete', Routes.article_path(@props.article), {}, cb)

  handleRankSelect: (rank, cb) =>
    @props.onAction('patch', Routes.update_rank_article_path(@props.article), {article: {rank: rank}}, cb)
    cb()

  ################################################################################
  # Renderers
  ################################################################################

  renderButton: (type, text, handler, cond = true, confirm = null) ->
    return null if !cond
    `<Button type={type} text={text} onClick={handler} confirm={confirm}/>`

  renderLink: (type, text, href, cond = true, confirm = null) ->
    return null if !cond
    gotoURL = (cb) ->
      window.location.href = href
      cb()
    `<Button type={type} text={text} onClick={gotoURL} confirm={confirm}/>`

  renderWebStatus: ->
    if @props.article.has_web_published_draft
      if @props.article.has_pending_draft
        `<StatusLabel type="info">Web: Has Update</StatusLabel>`
      else
        `<StatusLabel type="success">Web: Published</StatusLabel>`
    else if @props.article.has_web_ready_draft
      `<StatusLabel type="info">Web: Ready</StatusLabel>`
    else
      `<StatusLabel type="danger">Web: Draft</StatusLabel>`

  renderPrintStatus: ->
    if @props.article.has_print_ready_draft
      `<StatusLabel type="success">Print: Ready</StatusLabel>`
    else
      `<StatusLabel type="danger">Print: Draft</StatusLabel>`

  renderCopyStatus: ->
    if @props.article.has_copy_ready_draft
      `<StatusLabel type="success">Copy: Ready</StatusLabel>`
    else
      `<StatusLabel type="danger">Copy: Unedited</StatusLabel>`

  renderActions: ->
    `<td style={this.styles.actionsCol}>
      {this.renderButton('success', 'Publish', this.handlePublish, (this.props.article.has_pending_draft &&
                                                                   !this.props.article.has_web_published_draft &&
                                                                    this.props.article.can_publish))}
      {this.renderButton('success', 'Publish Update', this.handlePublish, (this.props.article.has_pending_draft &&
                                                                           this.props.article.has_web_published_draft &&
                                                                           this.props.article.can_publish))}
      {this.renderButton('danger', 'Delete', this.handleDelete, (!this.props.article.has_web_published_draft &&
                                                                  this.props.article.can_destroy),
                         'Are you sure that you want to delete this article? This will delete all drafts. ')}
      {this.renderButton('danger', 'Unpublish', this.handleUnpublish, (this.props.article.has_web_published_draft &&
                                                                       this.props.article.can_unpublish),
                         'Are you sure that you want to unpublish this article? The publish time would change if you ' +
                         'later publish it again. ')}
      {this.renderLink('default', 'View Drafts', Routes.article_drafts_path(this.props.article, {format: 'html'}))}
    </td>`

  render: ->
    `<tr>
      <td style={this.styles.statusCol}>
        {this.renderWebStatus()}
        {this.renderPrintStatus()}
        {this.renderCopyStatus()}
        { this.props.rankSelect && this.props.article.can_update_rank &&
          <AutoSelect style={this.styles.rankSelect}
                      titles={[99].concat(range(1, 20))}
                      ids={[99].concat(range(1, 20))}
                      initial={this.props.article.rank}
                      onChange={this.handleRankSelect}/>
        }
      </td>
      <td style={this.styles.mainCol}>
        <p>
          <span style={this.styles.label} className="label label-default">{this.props.article.issue.short_name}</span>
          <span style={this.styles.label} className="label label-default">{this.props.article.section.name.toUpperCase()}</span>
          <span style={this.styles.label} className="label label-default">{this.props.article.newest_draft.primary_tag.toUpperCase()}</span>
          {
            (this.props.from_issues_page)
            ? <a style={this.styles.slug} href={Routes.article_drafts_path(this.props.article, {format: 'html'})+"?issue="+String(this.props.from_issues_page)}>{this.props.article.slug}</a>
            : <a style={this.styles.slug} href={Routes.article_drafts_path(this.props.article, {format: 'html'})}>{this.props.article.slug}</a>
          }
          •
          <span style={this.styles.headline}>{this.props.article.newest_draft.headline}</span>
        </p>
        <p style={this.styles.secondaryLine}>
          {
            (this.props.article.oldest_web_published_draft != null &&
            this.props.article.oldest_web_published_draft != undefined)
              ? <span style={this.styles.publishTime}>Published online {$.timeago(Date.parse(this.props.article.oldest_web_published_draft.published_at))}</span>
              : <span style={this.styles.publishTime}>Not published online yet</span>
          }
          •
          <span style={this.styles.authors}>Authored by {this.props.article.newest_draft.authors_string}</span>
        </p>
      </td>
      {this.renderActions()}
    </tr>`
