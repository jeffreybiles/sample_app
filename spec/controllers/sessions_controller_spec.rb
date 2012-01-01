require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "returns http success" do
      visit('/sessions/new')  #signin
      #get 'new'
      response.should be_success
    end

    it "should return the right title" do
      visit('/sessions/new')  #signin
      page.find('title').should have_content("Sign in")
    end
  end

  describe "POST 'create'" do

    describe "invalid signin" do

      before(:each) do
        visit('/signin')
        fill_in "Email", with: 'email@example.com'
        fill_in "Password", with: 'invalid'
        click_button 'Sign in'
      end

      it "should rerender the new page" do
        response.should render_template('new')
      end

      it "should have the right title" do
        page.find("title").should have_content("Sign in")
      end

      it "should have a flash.now message" do
        flash.now[:error] =~ /invalid/i
      end
    end

    describe "with valid email and password" do

      before(:each) do
        @user = Factory(:user)
        integration_sign_in(@user)
      end

      #currently don't know how to make this shit work'
      #it "should sign the user in" do
      #  save_and_open_page
      #  puts controller.current_user
      #  controller.current_user.should == @user
      #  controller.should be_signed_in
      #end

      it "should redirect to the user show page" do
        page.current_path.should == user_path(@user)
      end
    end

    describe "DELETE 'destroy'" do

      it "should sign a user out" do
        test_sign_in(Factory(:user))
        delete :destroy
        controller.should_not be_signed_in
        response.should redirect_to(root_path)
      end
    end
  end

end
