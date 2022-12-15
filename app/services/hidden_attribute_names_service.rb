class HiddenAttributeNamesService
  def self.call
    User.all.each do |user|
      next unless user.projects.count > 0

      user.projects.each do |project|
        roles = user.admin ? Role.all : user.roles_for_project(project)

        result = []
        unless roles.empty?
          workflow_permissions = WorkflowPermission.where(:tracker_id => project.trackers.map(&:id), :old_status_id => IssueStatus.all.map(&:id), :role_id => roles.map(&:id), :rule => 'hidden').all
          if workflow_permissions.any?
            workflow_rules = workflow_permissions.inject({}) do |hash, permission|
              hash[permission.field_name] ||= []
              hash[permission.field_name] << permission.rule
              hash
            end
            issue_statuses_count = IssueStatus.all.size
            workflow_rules.each do |attr, rules|
              result << attr if rules.size >= (roles.size * project.trackers.size * issue_statuses_count)
            end
          end
        end

        result += Tracker.disabled_core_fields(project.trackers)
        result += IssueCustomField.
            sorted.
            where("is_for_all = ? AND id NOT IN (SELECT DISTINCT cfp.custom_field_id" +
            " FROM #{project.table_name_prefix}custom_fields_projects#{project.table_name_suffix} cfp" +
            " WHERE cfp.project_id = ?)", false, project.id).pluck(:id).map(&:to_s)

        HiddenAttributeNamesForUser.find_or_create_by(user_id: user.id, project_id: project.id) { |h| h.name = result.join(';') }
      end
    end
  end
end
