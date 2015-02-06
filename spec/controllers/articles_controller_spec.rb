require_relative '../rails_helper'

describe ArticlesController do
  login_admin

  describe "GET #index" do
    it "populates an array of articles" do
      article_version = create(:article_version)
      article = article_version.article
      get :index, params = {q: article.headline}
      expect(assigns(:articles)).to match_array([article])
    end
    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #new" do
    it "assigns a new article to @article and a new piece to @piece" do
      get :new
      expect(assigns(:article)).to be_a_new(Article)
      expect(assigns(:piece)).to be_a_new(Piece)
    end

    it "renders the :new template" do
       get :new
      expect(response).to render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested article to @article" do
      article = create(:article)
      get :edit, id: article
      expect(assigns(:article)).to eq(article)
    end

    it "renders the :edit template" do
      get :edit, id: create(:article)
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new article in the database" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})
        expect { post :create, {article: attributes_for(:article)}.merge(piece_attributes) }.to change(Article, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "doesn't save the new article in the database if article invalid" do
        issue = create(:issue)
        section = create(:section)
        piece_attributes = attributes_for(:piece).merge({issue_id: issue.id, section_id: section.id})
        expect { post :create, {article: {headline: ""}}.merge(piece_attributes) }.to_not change(Article, :count)
      end

      it "doesn't save the new article in the database if piece invalid" do
        expect { post :create, {article: attributes_for(:article)}.merge(attributes_for(:piece)) }.to_not change(Article, :count)
      end
    end
  end

  describe "PUT #update" do
    before :each do
      @article = create(:article)
      @piece = @article.piece
      @valid_params = attributes_for(:article, headline: "new headline")
      @invalid_params = attributes_for(:article, headline: "")
    end

    context "with valid attributes" do
      it "locates the requested @article" do
        put :update, id: @article, article: @valid_params, issue_id: @piece.issue.id, section_id: @piece.section.id, slug: @piece.slug
        expect(assigns(:article)).to eq(@article)
      end

      it "changes the article's attributes" do
        expect(@article.headline).to_not eq("new headline")
        put :update, id: @article, article: @valid_params, issue_id: @piece.issue.id, section_id: @piece.section.id, slug: @piece.slug
        @article.reload
        expect(@article.headline).to eq("new headline")
      end

      it "redirects to the updated article" do
        put :update, id: @article, article: @valid_params, issue_id: @piece.issue.id, section_id: @piece.section.id, slug: @piece.slug
        expect(response).to redirect_to article_article_version_path(@article, ArticleVersion.first)
      end
    end

    context "invalid attributes" do
      it "locates the requested @article" do
        put :update, id: @article, article: @invalid_params, issue_id: @piece.issue.id, section_id: @piece.section.id, slug: @piece.slug
        expect(assigns(:article)).to eq(@article)
      end

      it "does not change the article's attributes" do
        put :update, id: @article, article: @invalid_params, issue_id: @piece.issue.id, section_id: @piece.section.id, slug: @piece.slug
        @article.reload
        expect(@article.headline).to_not eq("")
      end

      it "re-renders the edit method" do
        put :update, id: @article, article: @invalid_params, issue_id: @piece.issue.id, section_id: @piece.section.id, slug: @piece.slug
        expect(response).to render_template :edit
      end
    end
  end

  describe "PATCH #update_rank" do
    it "assigns the correct article to @article" do
      article = create(:article)
      patch :update_rank, id: article, article: attributes_for(:article, rank: 51), format: :js
      expect(assigns(:article)).to eq(article)
    end

    it "updates the article's rank" do
      article = create(:article)
      expect(article.rank).to_not eq(51)
      patch :update_rank, id: article, article: attributes_for(:article, rank: 51), format: :js
      article.reload
      expect(article.rank).to eq(51)
    end

    it "renders the view" do
      article = create(:article)
      patch :update_rank, id: article, article: attributes_for(:article, rank: 51), format: :js
      expect(response).to render_template :update_rank
    end
  end

  describe "DELETE #destroy" do
    it "removes the article from the database" do
      article = create(:article)
      expect {delete :destroy, id: article}.to change(Article, :count).by(-1)
    end

    it "redirects to the articles page " do
      article = create(:article)
      delete :destroy, id: article
      expect(response).to redirect_to articles_path
    end
  end

  describe "GET #assets_list" do
    it "assigns the correct article to @article" do
      article = create(:article)
      get :assets_list, id: article, format: :js
      expect(assigns(:article)).to eq(article)
    end

    it "renders the assets_list view" do
      article = create(:article)
      get :assets_list, id: article, format: :js
      expect(response).to render_template :assets_list
    end
  end
end

