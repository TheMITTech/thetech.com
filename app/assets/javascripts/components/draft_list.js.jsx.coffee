class @DraftList extends React.Component
  @propTypes =
    article: React.PropTypes.object
    drafts: React.PropTypes.array

  constructor: (props) ->
    @styles =
      mainContainer:
        marginTop: '50px'
      statusLabel:
        display: 'block'
        width: '100%'
      actionButtons:
        display: 'block'
        width: '100%'
        marginBottom: '5px'
      actionButtonsDimmed:
        opacity: '0.2'
      headline:
        fontSize: '30px'
        lineHeight: '30px'
        marginBottom: '0'
      subhead:
        marginTop: '0'
        fontSize: '24px'
        color: '#888'
      authors:
        fontSize: '18px'
        color: '#888'
      content:
        marginTop: '20px'
        padding: '30px 40px'
        fontSize: '16px'
        lineHeight: '25px'
        backgroundColor: '#FFF'
      contentP:
        marginBottom: '20px'
      metadata:
        padding: '10px 40px'
      changes:
        normal:
          color: 'inherit'
        added:
          backgroundColor: '#DBFFDB'
          padding: '0'
        removed:
          backgroundColor: '#FFDDDD'
          padding: '0'
      sidebar:
        padding: '10px 25px 20px'
      sidebarHeader:
        fontSize: '14px'
        fontWeight: 'bold'
        color: '#888'
        textTransform: 'uppercase'
        marginBottom: '5px'
        marginTop: '15px'
      draftButton:
        display: 'block'
        width: '100%'
        marginBottom: '5px'
      noChangeHint:
        color: '#888'
        fontSize: '14px'
        textTransform: 'uppercase'
        marginBottom: '20px'
        textAlign: 'right'
        fontWeight: 'bold'
    @state =
      drafts: props.drafts
      versionAId: props.drafts[props.drafts.length - 1].id
      versionBId: props.drafts[props.drafts.length - 1].id

  replaceDrafts: (drafts) =>
    @setState
      drafts: drafts
      versionAId: drafts[drafts.length - 1].id
      versionBId: drafts[drafts.length - 1].id

  componentDidMount: ->
    MessageBus.subscribe '/updates', (data) =>
      console.log('MessageBus update: ', data)
      if data.model == 'article' && data.id == @props.article.id
        axios.get(Routes.article_drafts_path(data.id)).then (resp) =>
          if resp.data.error
            alert(resp.data.error)
          else
            @replaceDrafts(resp.data.drafts)
        .catch (err) =>
          logError(err)
          alert("Unknown error. Please refresh the page. ")


  parseLines: (changes) ->
    changeValue = (change, newValue) ->
      result = _.clone(change)
      result.value = newValue
      result

    paragraphs = [[]]
    _.each changes, (c, p) ->
      lines = c.value.split("\n\n")
      paragraphs[paragraphs.length - 1].push(changeValue(c, lines[0]))
      _.each _.rest(lines), (l, q) ->
        paragraphs.push([changeValue(c, l)])
    paragraphs

  replaceDraft: (draft) =>
    drafts = @state.drafts.slice()
    index = _.findIndex(drafts, {id: draft.id})
    if index < 0
      return
    drafts[index] = draft
    @setState drafts: drafts

  doUpdate: (draft, params, cb) =>
    axios.patch(Routes.article_draft_path(@props.article.id, draft.id), {draft: params}).then (resp) =>
      if resp.data.error?
        alert(resp.data.error)
      else
        console.log resp.data
        @replaceDraft(resp.data.draft)
    .catch (err) =>
      alert("Unexpected error. Please refresh the page. ")
      logError(err)

  setVersions: (a, b) =>
    indexA = _.findIndex(@state.drafts, {id: a})
    indexB = _.findIndex(@state.drafts, {id: b})
    [indexA, indexB] = [indexB, indexA] if indexA > indexB
    @setState
      versionAId: @state.drafts[indexA].id
      versionBId: @state.drafts[indexB].id
      highlightAId: null
      highlightBId: null

  handleDraftMouseDown: (draft) =>
    @pendingClick = draft.id
    @setState highlightAId: draft.id, highlightBId: draft.id

  handleDraftMouseOver: (draft) =>
    @setState highlightBId: draft.id

  handleDraftMouseUp: (draft) =>
    return unless @pendingClick?
    @setVersions(@pendingClick, draft.id)

  renderDiff: (textA, textB, pStyle = {}, hint = false) =>
    rawChanges = JsDiff.diffWords(textA, textB, {newlineIsToken: true})
    changes = @parseLines(rawChanges)
    paragraphs = changes.map (paragraph, i) =>
      React.DOM.p {key: i, style: pStyle},
        paragraph.map (change, j) =>
          style = this.styles.changes.normal
          style = this.styles.changes.added if change.added
          style = this.styles.changes.removed if change.removed
          html = change.value.replace(/\n/g, "<br/>")
          `<span key={j} style={style} dangerouslySetInnerHTML={{__html: html}}/>`
    elements = paragraphs
    if hint && rawChanges.length == 1 && !rawChanges.removed && !rawChanges.added
      elements = [`<p key={-1} style={this.styles.noChangeHint}>There are no changes here. </p>`].concat(paragraphs)
    React.DOM.div null,
      elements


  renderPrintStatus: (draft) =>
    if draft.print_status == 'print_ready'
      `<StatusLabel style={this.styles.statusLabel} type='success'>Print: Ready</StatusLabel>`
    else
      `<StatusLabel style={this.styles.statusLabel} type='danger'>Print: Draft</StatusLabel>`

  renderWebStatus: (draft) =>
    if draft.web_status == 'web_published'
      `<StatusLabel style={this.styles.statusLabel} type='success'>Web: Published</StatusLabel>`
    else if draft.web_status == 'web_ready'
      `<StatusLabel style={this.styles.statusLabel} type='info'>Web: Ready</StatusLabel>`
    else
      `<StatusLabel style={this.styles.statusLabel} type='danger'>Web: Draft</StatusLabel>`

  renderButton: (type, text, handler, cond = true, confirm = null) ->
    return null if !cond
    `<Button style={this.styles.actionButtons} type={type} text={text} onClick={handler} confirm={confirm}/>`

  renderLink: (type, text, href, cond = true, confirm = null) ->
    return null if !cond
    gotoURL = (cb) ->
      window.open(href)
      cb()
    `<Button style={this.styles.actionButtons} type={type} text={text} onClick={gotoURL} confirm={confirm}/>`

  renderVersions: =>
    if @state.highlightAId?
      highlightIndexA = _.findIndex(@state.drafts, {id: @state.highlightAId})
      highlightIndexB = _.findIndex(@state.drafts, {id: @state.highlightBId})

      console.log highlightIndexA, highlightIndexB

      [highlightIndexA, highlightIndexB] = [highlightIndexB, highlightIndexA] if highlightIndexA > highlightIndexB
    else
      highlightIndexA = _.findIndex(@state.drafts, {id: @state.versionAId})
      highlightIndexB = _.findIndex(@state.drafts, {id: @state.versionBId})

    React.DOM.div null,
      @state.drafts.slice().reverse().map (draft, q) =>
        index = _.findIndex(@state.drafts, {id: draft.id})
        if draft.web_status == 'web_published'
          type = 'success'
          web_status = 'Published'
        else if draft.web_status == 'web_ready'
          type = 'info'
          web_status = 'Ready'
        else
          type = 'danger'
          web_status = 'Draft'

        buttonStyle = _.clone(this.styles.actionButtons)
        _.extend(buttonStyle, this.styles.actionButtonsDimmed) if (index < highlightIndexA || highlightIndexB < index)
        `<button className={"btn btn-sm btn-" + type}
                 style={buttonStyle}
                 key={draft.id}
                 type={type}
                 onMouseDown={this.handleDraftMouseDown.bind(this, draft)}
                 onMouseOver={this.handleDraftMouseOver.bind(this, draft)}
                 onMouseUp={this.handleDraftMouseUp.bind(this, draft)}>
          {web_status + ", " + $.timeago(draft.created_at)}
        </button>`
      , this

  render: ->
    versionA = @state.drafts[_.findIndex(@state.drafts, {id: @state.versionAId})]
    versionB = @state.drafts[_.findIndex(@state.drafts, {id: @state.versionBId})]
    `<div style={this.styles.mainContainer} className="row">
      <article className="col-sm-10">
        <div style={this.styles.metadata} className="well">
          <h1 style={this.styles.headline}>{this.renderDiff(versionA.headline, versionB.headline)}</h1>
            <h2 style={this.styles.subhead}>{this.renderDiff(versionA.subhead, versionB.subhead)}</h2>
          <div style={this.styles.authors}>{this.renderDiff(
            "Authored by " + versionA.authors_string,
            "Authored by " + versionB.authors_string
          )}</div>
        </div>
        <div style={this.styles.content} className="well">{this.renderDiff(versionA.text, versionB.text, this.styles.contentP, versionA.id != versionB.id)}</div>
      </article>
      <div style={this.styles.sidebar} className="col-sm-2 well">
        <p style={this.styles.sidebarHeader}>All Drafts</p>
        {this.renderVersions()}

        <p style={this.styles.sidebarHeader}>Draft Status</p>
        {this.renderWebStatus(versionB)}
        {this.renderPrintStatus(versionB)}

        <p style={this.styles.sidebarHeader}>Draft Actions</p>
        {this.renderButton('success', 'Mark Web Ready', this.doUpdate.bind(this, versionB, {web_status: 'web_ready'}),
                           versionB.web_status == 'web_draft' && this.props.article.can_update)}
        {this.renderButton('success', 'Mark Print Ready', this.doUpdate.bind(this, versionB, {print_status: 'print_ready'}),
                           versionB.print_status == 'print_draft' && this.props.article.can_update)}
        {this.renderLink('default', 'Edit', Routes.edit_article_path(this.props.article.id, {draft_id: versionB.id, format: 'html'}),
                         this.props.article.can_update)}
      </div>
    </div>`
