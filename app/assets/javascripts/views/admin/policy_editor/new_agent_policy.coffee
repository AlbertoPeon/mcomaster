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
MCM.Views.NewAgentPolicy = Backbone.Marionette.LayoutView.extend({
  template: HandlebarsTemplates['admin/policy_editor/new_agent_policy']

  regions : {
    policyDropdownRegion : ".policy-dropdown-container"
    agentDropdownRegion : ".agent-dropdown-container"
    actionDropdownRegion : ".action-dropdown-container"
    usersDropdownRegion : ".users-dropdown-container"
  }

  initialize: (options) ->
    @collection = options.collection
    @model = new MCM.Models.Policy
    @model.set('policy', 'allow')

  events : {
    "click .policy-dropdown-container ul.dropdown-menu a" : "policySelected"
    "click .policy-submit-button" : "submitPolicy"
    "click .policy-cancel-button" : "cancelPolicy"
  }

  cancelPolicy: (e) ->
    $(@el).find(".modal").modal("hide")
    e.preventDefault()

  submitPolicy: (e) ->
    model = @model
    collection = @collection

    model.save model.attributes,
      success: ->
        agentPolicy = collection.get(model.attributes.agent)

        if agentPolicy
          agentPolicy.policies.add(model)
        else
          agentPolicy = new MCM.Models.AgentPolicy({ id : model.attributes.agent })
          agentPolicy.policies.add(model)

        collection.add(agentPolicy)

    $(@el).find(".modal").modal("hide")
    e.preventDefault()

  validateSubmit: ->
    if @model.attributes.agent and @model.attributes.action_name and @model.attributes.callerid
      $(@el).find(".btn-primary").removeAttr("disabled")

  userSelected: (value) ->
    @model.set('callerid', value)
    @validateSubmit()

  actionSelected: (value) ->
    @model.set('action_name', value)
    @validateSubmit()

  policySelected: (value) ->
    @model.set('policy', value)

  agentSelected: (value) ->
    @model.set('agent', value)
    agentModel = MCM.agents.get(value)
    @validateSubmit()

    actionCollection = agentModel.getActionCollection()

    view = new MCM.Views.AdminDropdown({ collection : actionCollection, label : "Action", initialValue : "Select an action" })
    @listenTo(view, "changed", @actionSelected)
    @actionDropdownRegion.show(view)

  onRender: ->
    view = new MCM.Views.AdminDropdown({ collection : MCM.agents, label : "Agent", initialValue : "Select an agent" })
    @listenTo(view, "changed", @agentSelected)
    @agentDropdownRegion.show(view)

    view = new MCM.Views.AdminDropdown({ collection : MCM.users, label : "Users", initialValue : "Select a user", idColumn : "name", displayColumn : "name" })
    @listenTo(view, "changed", @userSelected)
    @usersDropdownRegion.show(view)

    policyCollection = new MCM.Collections.Transient
    policyCollection.add(new MCM.Models.Transient({ id : "allow" }))
    policyCollection.add(new MCM.Models.Transient({ id : "deny" }))
    view  = new MCM.Views.AdminDropdown({ collection : policyCollection, label : "Policy", initialValue : "allow" })
    @listenTo(view, "changed", @policySelected)
    @policyDropdownRegion.show(view)
})
