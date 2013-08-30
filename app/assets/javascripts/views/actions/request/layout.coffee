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
MCM.Views.Layouts.ActionRequest = Backbone.Marionette.Layout.extend({
  template: HandlebarsTemplates['actions/request/layout']
  
  regions: {
    headerRegion: "#requestHeaderRegion"
    formRegion: "#requestFormRegion"
    shellRegion: "#requestShellRegion"
    filterRegion: "#requestFilterRegion"
  }
  
  onShow: ->
    @form = new MCM.Views.ActionRequest(@options)
    @formRegion.show(@form)
    
    if @options.filterCollection and @options.filter == undefined
      @filterView = new MCM.Views.Layouts.ActionRequestFilter({'collection' : @options.filterCollection, remoteFilterCollection : @options.remoteFilterCollection, 'includeExecuteButton' : true })
      @filterRegion.show(@filterView)

    if MCM.remoteConfig.includeActionShell == true
      @shell = new MCM.Plugins.Shell.GenericRequestView({ agent : @options.agent, id : @options.id, filterView : @filterView })
      @shellRegion.show(@shell)
        
    @header = new MCM.Views.ActionRequestHeader(@options)
    @headerRegion.show(@header)

  events : {
    "click .action-exec-button" : "submit"
  }
  
  submit: (e) ->
    filter = @options.filter
    if filter == undefined && @filterView != undefined
      filter = @filterView.getRequestFilter()
      
    MCM.Client.submitActionForm {
      ddl : @form.ddl,
      filter : filter,
      form : $("#actionForm"),
      event : e,
      agent : @options.agent,
      action : @options.id
    }
    
    e.preventDefault()
    
  templateHelpers: ->
    return _.extend(@options, { includeShell : MCM.remoteConfig.includeActionShell == true })
})
