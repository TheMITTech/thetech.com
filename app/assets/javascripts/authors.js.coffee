# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#authors_show').length > 0
    window.update_article_list = (articles) ->
      $scope = angular.element('#articles_table').scope()
      $scope.$apply ->
        $scope.articles = articles

    window.update_article_list(gon.articles)
$(ready)

