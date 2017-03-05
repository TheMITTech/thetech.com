class @ArticleList extends React.Component
  @propTypes =
    articles: React.PropTypes.array
    fetch: React.PropTypes.string

  appendArticles: (articles) =>
    @setState
      page: @state.page + 1
      articles: @state.articles.concat(articles)

  loadNextPage: =>
    @setState loading: true
    axios.get(@nextPage).then (resp) =>
      if resp.data.error
        alert(resp.data.error)
      else
        @nextPage = resp.data.nextPage
        @setState
          loading: false
        @appendArticles(resp.data.articles)
    .catch (err) =>
      logError(err)
      alert("Unknown error. Please refresh the page. ")

  componentDidMount: ->
    MessageBus.subscribe '/updates', (data) =>
      console.log('MessageBus update: ', data)
      if data.model == 'article'
        axios.get(Routes.article_path(data.id)).then (resp) =>
          if resp.data.error
            alert(resp.data.error)
          else
            @replaceArticle(resp.data.article)
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
      articles: @props.articles
      loading: true
    @styles =
      infiniteScrollTriggerRow:
        textAlign: 'center'
        fontSize: '40px'

  replaceArticle: (article) ->
    articles = @state.articles.slice()
    index = _.findIndex(articles, {id: article.id})
    if index < 0
      return
    if article.destroyed
      articles.splice(index, 1)
    else
      articles[index] = article
    @setState(articles: articles)

  handleAction: (article, method, path, params, cb) ->
    axios
      method: method,
      url: path,
      data: params
    .then (resp) =>
      cb() if cb?
      if resp.data.error
        alert(resp.data.error)
      else
        @replaceArticle(resp.data.article)
    .catch (err) =>
      logError(err)
      alert("Cannot complete the action. Please refresh the page and try again. ")

  handleSearchKeyDown: (e) =>
    if e.keyCode == 13
      @setState articles: []
      @nextPage = Routes.articles_path(q: e.target.value)
      @loadNextPage()

  render: ->
    `<table className="table">
      <thead>
        <tr>
          <td colSpan="3">
            <input className="form-control" onKeyDown={this.handleSearchKeyDown} placeholder='Search for articles by volume (e.g. "V134 N7") or by text. Press ENTER to search. '/>
          </td>
        </tr>
      </thead>
      <tbody>
        {
          this.state.articles.map(function(article, i) {
            return <Article article={article} authors={this.props.authors} articles={this.props.articles} key={article.id} onAction={this.handleAction.bind(this, article)}></Article>;
          }, this)
        }
        <tr style={this.styles.infiniteScrollTriggerRow} data-appear-top-offset="1000" ref="infiniteScrollTrigger">
          <td colSpan="3">{this.state.loading ? <i className="fa fa-spin fa-circle-o-notch"></i> : null }</td>
        </tr>
      </tbody>
    </table>`
