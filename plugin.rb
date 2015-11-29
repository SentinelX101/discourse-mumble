# name: Mumble
# about: Displays channel and user information from a Mumble server
# version: 0.2.4
# authors: Nuno Freitas (nunofreitas@gmail.com)
# minor-edit-maker: Sam Moore (smoore.mr@gmail.com)
# url: https://github.com/smoore-mr/discourse-mumble

register_asset "javascripts/mumble.js"
register_asset "stylesheets/mumble.scss"

enabled_site_setting :mumble_enabled

MUMBLE_PLUGIN_NAME ||= "mumble".freeze

after_initialize do
    module ::Mumble
        class Engine < ::Rails::Engine
            engine_name MUMBLE_PLUGIN_NAME
            isolate_namespace Mumble
        end
    end
    
    Mumble::Engine.routes.draw do
        get  "/list"    => "mumble#list"
    end
    
    Discourse::Application.routes.append do
        mount ::Mumble::Engine, at: "/mumble"
    end
    
    require_dependency "application_controller"
    
    class ::Mumble::MumbleController < ::ApplicationController
        requires_plugin MUMBLE_PLUGIN_NAME
        
        rescue_from 'StandardError' do |e| render_json_error e.message end
        
        def list
            if SiteSetting.mumble_cvp.to_s == ''
                result = {}
            else
                response = Net::HTTP.get_response(URI.parse(SiteSetting.mumble_cvp))
                result = JSON.parse(response.body)
            end
            
            render json: result
        end
    end
end
