module RedmineWorkflowHiddenFields
	module  ProjectPatch
    def self.included(base)
      base.class_eval do
				has_many :hidden_attribute_names_for_users, dependent: :destroy
      end
    end

		# Returns list of attributes that are hidden on all statuses of all trackers for +user+ or the current user.
		def completely_hidden_attribute_names(user=User.current)
			HiddenAttributeNamesForUser.where(user_id: user.id, project_id: id).pluck(:name).map{ |r| r.split(';')}.flatten.uniq
		end
	end
end
