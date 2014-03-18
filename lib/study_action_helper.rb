module StudyActionHelper
  # Responds to request with no content if study is inactive or locked
  # TODO: forbidden should be replaced with redirection to an error page
  def check_study_status
    if get_study.inactive_or_locked?
      return head :forbidden          
    end
  end
  
  def get_study(study_id = nil)
    @study ||= begin
      study = Study.get(study_id || params[:study_uuid])
      if AuthorizationAggregate.get(:all, params: {client_division_uuid: study.client_division_uuid,
        user_uuid: Thread.current[:current_user_uuid]}).empty?
        # TODO: Allow users with study environment level access as well in R2
        Log.warn("User: #{Thread.current[:current_user_uuid]} blocked from accessing study #{study.uuid}",
          "No client division level role assignment found")
        raise Exceptions::AuthorizationError.new("Unauthorized")
      else
        study
      end
    end
  end
end
