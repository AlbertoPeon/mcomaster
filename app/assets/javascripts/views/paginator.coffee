###
 Copyright 2013 ajf http://github.com/ajf8

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###
MCM.Views.Paginator = Backbone.Marionette.ItemView.extend({
  template: HandlebarsTemplates['pagination']
  className: "pagination"

  events : {
    "click a" : "pageSelected"
  }

  pageSelected: (e) ->
    page = $(e.target).data("page")

    if page != undefined
      @options.collection.setPage(page)
      @render()

    e.preventDefault()

    return false

  newPage: (idx) ->
    @pages.push({ idx : idx, display : idx+1, isCurrent : idx == @options.collection.page })
    @render()

  changePage: (idx) ->
    for p in @pages
      p.isCurrent = p.idx == idx
    @render()

  onSync: ->
    @pages = []
    n_pages = @options.collection.getPages()
    i = 0
    while (i < n_pages)
      @newPage(i++)
    @render()

  initialize: ->
    @pages = []
    @newPage(0)
    @listenTo @options.collection, "paginator:newPage", ->
      @newPage()
      @render()
    @listenTo @options.collection, "paginator:changePage", @changePage
    @listenTo @options.collection, "sync", @onSync

  templateHelpers: ->
    ctx = { pages : @pages }
    collection = @options.collection
    i = 0

    num_pages = collection.getPages()

    if collection.page > 0
      ctx.hasPrevPage = true
      ctx.prevPage = collection.page
      ctx.prevPageIdx = collection.page-1

    if collection.page+1 < num_pages
      ctx.hasNextPage = true
      ctx.nextPageIdx = collection.page+1
      ctx.nextPage = ctx.nextPageIdx+1

    return ctx
})
