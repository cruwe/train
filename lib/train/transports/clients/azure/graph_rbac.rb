# encoding: utf-8

require 'azure_graph_rbac'

# Wrapper class for ::Azure::GraphRbac::Profiles::Latest::Client allowing custom configuration,
# for example, defining additional settings for the ::MsRestAzure::ApplicationTokenProvider.
class GraphRbac

  @auth_endpoint
  @api_endpoint

  def self.client(credentials, options)

    cloud = case options[:environment_name]
            when 'AzureChinaCloud'
              MsRestAzure::AzureEnvironments::AzureChinaCloud
            when 'AzureGermanCloud'
              MsRestAzure::AzureEnvironments::AzureGermanCloud
            when 'AzureUSGovernment'
              MsRestAzure::AzureEnvironments::AzureUSGovernment
            else
              MsRestAzure::AzureEnvironments::AzureCloud
            end

    @auth_endpoint = cloud.active_directory_endpoint_url
    @api_endpoint = cloud.active_directory_graph_resource_id

    credentials[:credentials] = ::MsRest::TokenCredentials.new(provider(credentials))
    credentials[:base_url] = @api_endpoint

    ::Azure::GraphRbac::Profiles::Latest::Client.new(credentials)
  end

  def self.provider(credentials)
    ::MsRestAzure::ApplicationTokenProvider.new(
        credentials[:tenant_id],
        credentials[:client_id],
        credentials[:client_secret],
        settings,
        )
  end

  def self.settings
    client_settings = MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
    client_settings.authentication_endpoint = @auth_endpoint
    client_settings.token_audience = @api_endpoint
    client_settings
  end

  private_class_method :provider, :settings
end
