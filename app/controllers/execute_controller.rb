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
class ExecuteController < ApplicationController
  require 'mcomaster/mcclient'
  require 'mcomaster/restmqclient'
  
  include Mcomaster::McClient
  include Mcomaster::RestMQ
  
  before_filter :authenticate_user!
  
  def execute
    agent = params[:agent]
    action = params[:mcaction]
    mc = mcm_rpcclient(agent)
    json = request.raw_post.empty? ? {} : JSON.parse(request.raw_post)
    
    args = {}
    if json.has_key?('args')
      json['args'].each do |key, value|
        args[key.to_sym] = value
      end
    end

    if json.has_key?('filter') && json['filter'].is_a?(Hash)
      mc.filter = convert_filter(json['filter'])
    end
    
    txid = rmq_uuid()
    
    rmq_send(txid, { :begin => true, :action => action, :agent => agent })
    
    t = Thread.new(txid) { |ttxid|
      begin
        stat = mc.method_missing(action, args) { |noderesponse|
          rmq_send(ttxid, { :node => noderesponse })
        }
        rmq_send(ttxid, { :end => 1, :stats => stat })
      rescue => ex
        rmq_send(ttxid, { :end => 1, :error => ex.message })
      end
    }

    render json: { :txid => txid }.jsonize
  end
end
