module TestUsers

  ##
  # Valid DB User with cached enablement  - i.e. findable by warden deserialization
  def user_developer
    Secure::UserProfile.find_and_authenticate_user("developer", "developer99")
  end
  def user_eptester
    Secure::UserProfile.find_and_authenticate_user("eptester", "nobugs")
  end
  def user_estester
    Secure::UserProfile.find_and_authenticate_user("estester", "nobugs")
  end
  def user_aptester
    Secure::UserProfile.find_and_authenticate_user("aptester", "nobugs")
  end
  def user_astester
    Secure::UserProfile.find_and_authenticate_user("astester", "nobugs")
  end

  ##
  # Valid DB User without cached enablement
  def page_user_developer
    Secure::UserProfile.page_user("developer")
  end
  def page_user_eptester
    Secure::UserProfile.page_user("eptester")
  end
  def page_user_estester
    Secure::UserProfile.page_user("estester")
  end
  def page_user_aptester
    Secure::UserProfile.page_user("aptester")
  end
  def page_user_astester
    Secure::UserProfile.page_user("astester")
  end
end