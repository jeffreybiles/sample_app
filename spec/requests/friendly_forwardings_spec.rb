require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after signin" do
    user = Factory(:user)
    visit edit_user_path(user)
    # The test automatically follows the redirect to the signin page.
    fill_in 'Email',    :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
    # The test follows the redirect again, this time to users/edi't.
    page.current_path.should == edit_user_path(user) #this also passes: "/users/#{user.id}/edit"
  end
end