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
MCM.Views.Layouts.Routes = Backbone.Marionette.LayoutView.extend({
  template: HandlebarsTemplates['nodes/routes']
  
  regions : {
    headerRegion : "#nodeRoutesHeader"
    applicationsRegion : "#nodeApplicationItemContainer"
    agentsRegion : "#nodeAgentItemContainer"
  }
  
  onShow: ->
    headerView = new MCM.Views.NodeRoutesHeader(nodemodel : @options.nodemodel)
    @headerRegion.show(headerView)
    agentsView = new MCM.Views.NodeActions(collection : @options.agentsCollection, nodemodel : @options.nodemodel)
    @agentsRegion.show(agentsView)
    applicationsView = new MCM.Views.NodeApplications(collection : @options.applicationsCollection, nodemodel : @options.nodemodel)
    @applicationsRegion.show(applicationsView)
})