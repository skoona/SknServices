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
  def user_bptester
    Secure::UserProfile.find_and_authenticate_user("bptester", "nobugs")
  end
  def user_bstester
    Secure::UserProfile.find_and_authenticate_user("bstester", "nobugs")
  end
  def user_bnptester
    Secure::UserProfile.find_and_authenticate_user("bnptester", "nobugs")
  end
  def user_vptester
    Secure::UserProfile.find_and_authenticate_user("vptester", "nobugs")
  end
  def user_vstester
    Secure::UserProfile.find_and_authenticate_user("vstester", "nobugs")
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
  def page_user_bptester
    Secure::UserProfile.page_user("bptester")
  end
  def page_user_bstester
    Secure::UserProfile.page_user("bstester")
  end
  def page_user_bnptester
    Secure::UserProfile.page_user("bnptester")
  end
  def user_vptester
    Secure::UserProfile.page_user("vptester")
  end
  def user_vstester
    Secure::UserProfile.page_user("vstester")
  end
end