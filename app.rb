require 'json'
require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/reloader'
require 'sinatra/json'

class EC2ProxyAPI < Sinatra::Base
  register Sinatra::Namespace

  set :server, :puma
  set :bind, ENV["HOST"] if ENV["HOST"]
  enable :logging

  configure :development do
    register Sinatra::Reloader
    require 'pry'
  end

  helpers do
    def get_instances_info
      output = `terraform output --json`
      JSON.parse(output).dig("instances", "value") unless output.empty?
    end
  end

  namespace "/api/v1" do
    before do
      content_type "application/json"
    end

    post "/apply" do
      create_params = params.select { |key, _| ["aws_instances_count", "proxy_type",
        "proxy_port", "proxy_user", "proxy_password"].include?(key) }

      command = ["terraform", "apply", "-auto-approve"]
      create_params.each do |key, value|
        command << "-var"
        command << "#{key.upcase}=#{value}"
      end

      command_status = system(*command)
      if command_status
        instances = get_instances_info
        json(status: "Ok", message: "Successfully performed apply action", data: { instances: instances })
      else
        status 500
        json(status: "Fail", message: "There is an error while trying to perform apply action, check application log")
      end
    end

    get "/instances_list" do
      instances = get_instances_info
      if instances.nil? || instances.empty?
        json(status: "Ok", message: "There are no instances created", data: {})
      else
        json(status: "Ok", message: "Running #{instances.size} instances", data: { instances: instances })
      end
    end

    post "/destroy" do
      command = ["terraform", "destroy", "-auto-approve"]

      command_status = system(*command)
      if command_status
        json(status: "Ok", message: "Successfully performed destroy action")
      else
        status 500
        json(status: "Fail", message: "There is an error while trying to perform destroy action, check application log")
      end
    end
  end
end

EC2ProxyAPI.run!

