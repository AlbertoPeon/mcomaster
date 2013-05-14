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
window.MCM = new Backbone.Marionette.Application();

MCM.Views = {};
MCM.Views.Layouts = {};
MCM.Models = {};
MCM.Collections = {};
MCM.Routers = {};
MCM.Helpers = {};

MCM.layouts = {};

MCM.addRegions({
  mainRegion: "#mainContent"
  nodesListRegion : "#nodesList"
  agentsListRegion: "#agentsList"
  agentsToolbarRegion: "#agentsToolbar"
  collectivesListRegion: "#collectivesList"
  collectivesToolbarRegion: "#collectivesToolbar"
  loggedInBarRegion : "#loggedInBar"
});

MCM.vent.on "authentication:interactive_logged_in", (user) ->
  window.location = "/#/"
  
MCM.vent.on "authentication:logged_in", (user) ->
  MCM.loggedInBarRegion.show(new MCM.Views.LoggedInBar(model : user))
  menu = $("#menuContent")
  if !menu.is(":visible")
    $("#mainContent").removeClass("span12").addClass("span9")
    menu.slideDown()

MCM.vent.on "authentication:logged_out", ->
  MCM.loggedInBarRegion.close()
  
  if Backbone.history.fragment != "login"
    window.location = "/#/login"
  
MCM.bind "initialize:after", ->
  if MCM.remoteConfig
    if MCM.remoteConfig.refresh_interval and MCM.remoteConfig.refresh_interval > 0
      setInterval ->
        MCM.agents.fetch()
        MCM.collectives.fetch()
        MCM.nodes.fetch()
        return true
      , (MCM.remoteConfig.refresh_interval * 1000)

  if(MCM.currentUser)
    MCM.vent.trigger("authentication:logged_in", MCM.currentUser);
  else
    MCM.vent.trigger("authentication:logged_out");
    
  $(document).ajaxError (e, xhr) ->
    if MCM.currentUser == undefined or $(".disconnect-notification").length > 0
      return
      
    if xhr.status == 403
      bootbox.dialog("You have been logged out.", [{
        "label" : "Login",
        "class" : "btn-primary"
        "callback" : ->
          window.location = "/"
      }], { "classes" : "disconnect-notification" })      
    else
      bootbox.dialog('You seem to have been disconnected. <div class="reconnect"></div>', [{
        "label" : "Reconnect",
        "class" : "btn-primary"
        "callback" : ->
          $.ajax '/collectives', {
            success: (rsp, check_status) ->
              debugger;
              Backbone.history.loadUrl(Backbone.history.fragment)
              $(".disconnect-notification").modal("hide")
            fail: (rsp, check_status) ->
              debugger;
              $(".disconnect-notification .reconnect").innerHTML(check_status)
          }
          return false
      }], { "classes" : "disconnect-notification" })

$ ->
  MCM.start()
  Backbone.history.start()