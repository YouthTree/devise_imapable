require 'devise_imapable/strategy'

module Devise
  module Models
    # Authenticable Module, responsible for encrypting password and validating
    # authenticity of a user while signing in.
    #
    # Examples:
    #
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module ImapAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :password
      end

      # Verifies whether an incoming_password (ie from sign in) is the user password.
      def valid_password?(incoming_password)
        valid = Devise::ImapAdapter.valid_credentials?(self.email, incoming_password)
        if valid # Create this record if valid.
           resource.new_record? ? create(conditions) : resource
        end
        return valid
      end

      # Set password to nil
      def clean_up_passwords
        self.password = nil
      end

      def after_imap_authentication
      end

    protected

      module ClassMethods
        def find_for_imap_authentication(conditions)
          unless conditions[:email] && conditions[:email].include?('@') && Devise.default_email_suffix
            conditions[:email] = "#{conditions[:email]}@#{Devise.default_email_suffix}"
          end
          
          # Find or create
          find_for_authentication(conditions) || new(conditions)
        end
      end
    end
  end
end