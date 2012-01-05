require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, id: @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, id: @user
      assigns(:user).should.eql?(@user)
    end

    it "should have the right title" do
      get :show, id: @user
      response.body.should have_selector("title", content: @user.name)
    end

    it "should include the user's name" do
      get :show, id: @user
      response.body.should have_selector("h1", content: @user.name)
    end

    it "should have a profile image" do
      get :show, id: @user
      response.body.should have_selector('h1 img', :class => 'gravatar')
    end

    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
      get :show, :id => @user
      response.body.should have_selector("span.content", :content => mp1.content)
      response.body.should have_selector("span.content", :content => mp2.content)
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get "new"
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.body.should have_selector("title", :content => "Sign up")
    end

    it "should have a name field" do
      get :new
      response.body.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an email field" do
      get :new
      response.body.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a password field" do
      get :new
      response.body.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a password confirmation field" do
      get :new
      response.body.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
  end

  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = {name: "", email: "", password: "", password_confirmation: ""}
      end

      it "should not create a user" do
        lambda do
          post :create, user: @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, user: @attr
        response.body.should have_selector('title', :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, user: @attr
        response.body.should render_template('new')
      end
    end

    describe "success" do

      before(:each) do
        @attr = {name: "Jeffrey Biles", email:"jeffreyb@example.com",
                 password: "foobar", password_confirmation: "foobar"}
      end

      it "should create a user" do
        lambda do
          post :create, user: @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user page" do
        post :create, user: @attr
        response.body.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, user: @attr
        flash[:success].should =~ /Welcome to the sample app/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
      click_link 'Settings'
    end

    it "should be successful" do
      response.should be_success
    end

    it "should have the right title" do
      page.find("title").should have_content("Edit user")
    end

    it "should have a link to change the Gravatar" do
      gravatar_url = "http://gravatar.com/emails"
      find_link("change")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
      click_link 'Settings'
    end

    describe "failure" do

      before(:each) do
        fill_in 'Email', with: ''
        fill_in 'Name', with: ''
        fill_in 'Password', with: ''
        fill_in 'Confirmation', with: ''
        click_button 'Update'
      end

      it "should render the 'edit' page" do
        response.should render_template('edit')
      end

      it "should have the right title" do
        page.find("title").should have_content("Edit user")
      end
    end

    describe "success" do

      before(:each) do
        fill_in 'Name', with: "New Name"
        fill_in 'Email', with: "user@example.org"
        fill_in 'Password', with: "barbaz"
        fill_in 'Confirmation', with: "barbaz"
        click_button 'Update'
      end

      it "should change the user's attributes" do
        @user.reload
        @user.name.should.eql?('New Name')
        @user.email.should == 'user@example.org'
      end

      it "should redirect to the user show page" do
        page.current_path.should == user_path(@user)
      end

      it "should have a flash message" do
        page.find('div').should have_content('updated')
      end
    end
  end

  describe 'authentication of edit/update pages' do

    before(:each) do
      @user = Factory(:user)
    end

    it "should deny access to to 'edit'" do
      get :edit, :id => @user
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'update'" do
      put :update, :id => @user, :user => {}
      response.should redirect_to(signin_path)
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice] =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = Factory(:user)
        integration_sign_in(@user)
        second = Factory(:user, :name => "Bob", :email => "another@example.com")
        third  = Factory(:user, :name => "Ben", :email => "another@example.net")
        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :name => Factory.next(:name),
                            :email => Factory.next(:email))
          end
        visit(users_path)
      end

      it "should be successful" do
        response.should be_success
      end

      it "should have the right title" do
        page.find('title').should have_content('All users')
      end

      it "should have an element for each user" do
        @users[0..4].each do |user|
          page.find('ul.users', :alt => user.name)
        end
      end

      it "should paginate users" do
        page.find("div.pagination")
        page.find("span.disabled").should have_content("Previous")
        page.find("a", :content => "Next")
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user) #test_sign_in seems tobe good when there is no link_clicking
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end

      it "should not show the delete link" do
        integration_sign_in(@user)
        page.should have_no_content('delete')
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
      end

      it "should destroy the user" do
        test_sign_in(@admin)
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        test_sign_in(@admin)
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end

      it "should not show the delete link" do
        integration_sign_in(@admin)
        click_link 'Users'
        save_and_open_page
        page.should have_content('delete')
      end
    end
  end
end