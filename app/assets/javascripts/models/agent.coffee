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
MCM.Models.Agent = Backbone.Model.extend({
  urlRoot:"/mcagents"

  getActionCollection : ->
    actionCollection = new MCM.Collections.Transient
    actionCollection.add(new MCM.Models.Transient({ id : "*" }))

    for action_name, action of @attributes.ddl.actions
      actionData = _.extend({ id : action_name }, action)
      actionModel = new MCM.Models.Transient(actionData)
      actionCollection.add(actionModel)

    return actionCollection
})
