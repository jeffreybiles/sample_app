require 'spec_helper'

describe "Microposts" do

  before(:each) do
    @user = Factory(:user)
    integration_sign_in(@user)
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new micropost" do
        lambda do
          save_and_open_page
          make_micropost('')
          find_button('Submit').visible?
          page.find("div#error_explanation").should have_content("Content can't be blank")
        end.should_not change(Micropost, :count)
      end
    end

    describe "success" do

      it "should make a new micropost" do
        content = "Lorem ipsum dolor sit amet"
        lambda do
          make_micropost(content)
          page.find("span.content", :content => content)
        end.should change(Micropost, :count).by(1)
      end

      it "should update the micropost count" do
        content = "Lorem ipsum dolor sit amet"
        make_micropost(content)
        page.find('#micropost_count').should have_content(@user.microposts.count)
        page.find('#micropost_count').should_not have_content(@user.microposts.count + 1)
      end
    end
  end

  describe "destruction" do

    before(:each) do
      @user = Factory(:user, email: Factory.next(:email))
      @user2 = Factory(:user, email: Factory.next(:email))
      integration_sign_in(@user)
      make_micropost('terfitude')
    end

    describe "failure" do

      it "should not have a link to destroy another user's micropost'" do
        click_link 'Sign out'
        integration_sign_in(@user2)
        save_and_open_page
        click_link 'Users'
        click_link @user.name
        click_button 'Follow'
        click_link 'Home'
        save_and_open_page
        page.find('.feed_item').should have_content('terfitude')
        page.should_not have_content('delete')
      end
    end

    describe "success" do

      it "should have a link to destroying your own micropost that works" do
        page.should have_content('terfitude')
        find_link('delete').visible?
      end
    end
  end
end
