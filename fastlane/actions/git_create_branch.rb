module Fastlane
  module Actions
    module SharedValues
      GIT_CREATE_BRANCH_CUSTOM_VALUE = :GIT_CREATE_BRANCH_CUSTOM_VALUE
    end

    class GitCreateBranchAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        branch_name = params[:branch_name]

        Action.sh("git checkout -b #{branch_name}")

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::GIT_CREATE_BRANCH_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "It creates a new branch and checkouts to it"
      end

      def self.details
        "You can use this action to create a new branch"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_GIT_CREATE_BRANCH_BRANCH_NAME", # The name of the environment variable
                                       description: "Branch name", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No API token for GitCreateBranchAction given, pass using `api_token: 'token'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['GIT_CREATE_BRANCH_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["douglasiacovelli"]
      end

      def self.is_supported?(platform) 
        true
      end
    end
  end
end
