require 'spec_helper'

describe "Users" do
  #describe "GET /users" do
  #  it "works! (now write some real specs)" do
  #    # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
  #    get users_index_path
  #    response.status.should be(200)
  #  end
  #end

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit '/signup'
          fill_in "Name", with: ""
          fill_in "Email", with: ""
          fill_in "Password", with: ''
          fill_in "Confirmation", with: ''
          click_button "Sign up"
          current_path.should == users_path
          page.find("div#error_explanation").should have_content('were')  #yea!
        end.should_not change(User, :count)
      end
    end

    describe "success" do

      it "should make a new user" do
        lambda do
          visit '/signup'
          fill_in "Name", with: "Jeffrey Biles"
          fill_in "Email", with: "jeffrey@example.com"
          fill_in "Password", with: 'foobar'
          fill_in "Confirmation", with: 'foobar'
          click_button "Sign up"
          page.current_url =~ /\/users\/new/
          page.should have_selector('div.flash.success', content: 'Welcome')
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "sign in/out" do

    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in 'Email',    :with => ""
        fill_in 'Password', :with => ""
        click_button 'Sign in'
        page.find("div.flash.error").should have_content("Invalid")
      end
    end

    describe "success" do
      it "should sign a user in and out" do
        user = Factory(:user)
        integration_sign_in(user)
        find_link('Sign out').visible?
        click_link "Sign out"
        find_link('Sign in').visible?
      end
    end
  end

end
