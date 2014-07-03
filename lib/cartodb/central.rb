# encoding: utf-8
module Cartodb
  class Central
    include HTTParty
    default_timeout 200 # Default HTTParty timeout
    format :json
    headers "Accept" => "application/json"

    def initialize
      @host = "http#{'s' if Rails.env.production? || Rails.env.staging?}://#{ Cartodb.config[:cartodb_central_api]['host'] }"
      @host << ":#{Cartodb.config[:cartodb_central_api]['port']}" if Cartodb.config[:cartodb_central_api]['port'].present?
      @auth = {
        username: Cartodb.config[:cartodb_central_api]['username'],
        password: Cartodb.config[:cartodb_central_api]['password']
      }
    end

    def get_organization_users(organization)
      options = { basic_auth: @auth, timeout: 600 }
      response = self.class.get "#{ @host }/api/organizations/#{ organization.name }/users", options

      unless response.code == 200
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
      response.parsed_response
    end # get_organization_users

    def get_organization_user(organization, user)
      response = self.class.get "#{ @host }/api/organizations/#{ organization.name }/users/#{ user.username }", { basic_auth: @auth }

      unless response.code == 200
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
      response.parsed_response
    end # get_organization_user

    def create_organization_user(organization, user)
      options = { body: { user: get_attributes_for(user) }, basic_auth: @auth }

      response = self.class.post "#{ @host }/api/organizations/#{ organization.name }/users", options

      unless response.code == 201
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end

      response.parsed_response
    end # create_organization_user

    def update_organization_user(organization, user)
      options = { body: { user: get_attributes_for(user) }, basic_auth: @auth}

      response = self.class.send :put, "#{ @host }/api/organizations/#{ organization.name }/users/#{ user.username }", options

      unless response.code == 204
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
    end # update_organization_user

    def delete_organization_user(organization, user)
      response = self.class.send :delete, "#{ @host }/api/organizations/#{ organization.name }/users/#{user_id}", { basic_auth: @auth }

      unless response.code == 204
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
    end # delete_organization_user

    ############################################################################
    # Organizations

    def get_organizations
      options = { basic_auth: @auth, timeout: 600 }
      response = self.class.get "#{ @host }/api/organizations", options
      unless response.code == 200
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
      response.parsed_response
    end # get_organizations

    def get_organization(organization)
      response = self.class.get "#{ @host }/api/organizations/#{ organization.name }", { basic_auth: @auth }
      unless response.code == 200
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
      response.parsed_response
    end # get_organization

    # Returns remote organization attributes if response code is 201
    # otherwise returns nil
    def create_organization(organization)
      options = { body: { organization: get_attributes_for(organization) }, basic_auth: @auth }

      response = self.class.send :post, "#{ @host }/api/organizations", options

      unless response.code == 201
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
      response.parsed_response
    end # create_organization

    def update_organization(organization)
      options = { body: { organization: get_attributes_for(organization) }, basic_auth: @auth}

      response = self.class.send :put, "#{ @host }/api/organizations/#{ organization.name }", options
      unless response.code == 204
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
    end # update_organization

    def delete_organization(organization)
      response = self.class.send :delete, "#{ @host }/api/organizations/#{ organization.name }", { basic_auth: @auth }
      unless response.code == 204
        raise CartoDB::CentralCommunicationFailure, "Application server responded with http #{ response.code }"
      end
    end # delete_organization

    private

    def get_attributes_for(record)
      attributes = record.api_attributes_with_values
      attributes[:remote_id] = attributes.delete(:id)
      attributes
    end

  end # AppServer
end # CartodbCentral
