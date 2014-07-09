# Copyright 2013 ajf http://github.com/ajf8
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class Mcagent
  require 'mcomaster/mcclient'
  require 'mcomaster/actionpolicy'
  
  include Mcomaster::McClient
  extend Mcomaster::McClient
  
  include Comparable
  
  attr_accessor :id, :actions, :ddl, :meta, :permissioned
  
  def self.all(user)
    agents = Array.new
    results = $redis.keys("mcollective::agent::*")
    for e in results
      Rails.logger.debug("found agent #{e}")
      e.gsub!(/^mcollective\:\:agent\:\:/, "")
      begin
        # without :verbose => true, put minimal information in
        agents.push(Mcagent.new(:id => e, :user => user))
      rescue => ex
        # some agents like discovery don't have DDLs, so discard exceptions
        unless ex.message =~ /Can't find DDL for agent plugin/
          Rails.logger.debug(ex.message+"\n"+ex.backtrace.join("\n"))
        end
      end
    end
    return agents.sort
  end

  def <=>(other)
    @id <=> other.id
  end
  
  def self.find(id, user)
    if $redis.exists("mcollective::agent::#{id}")
      return Mcagent.new(:id => id, :user => user)
    end
    nil
  end
  
  def initialize(args)
    @id = args[:id]
    username = args[:user].name if args[:user]
    
    @ddl = get_ddl(@id)
    @ddl[:actions].each_pair{ |k,v|
      if Mcomaster::ActionPolicy.is_enabled?
        begin
          v[:permission] = Mcomaster::ActionPolicy.authorize(Mcomaster::Request.new(@id, username, k))
        rescue => ex
          #warn ex
          v[:permission] = false
        end
      else
        v[:permission] = true
      end
    }

##    if args[:verbose] == true
#      @ddl = ddl
#    else
#      @actions = Hash.new
      # added metadata so it's available to applications deciding
      # if they show or not
#      @meta = ddl[:meta]
      # already have this in 'id'
#      @meta.delete("name")
#    end
  end
end
