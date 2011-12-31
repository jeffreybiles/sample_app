require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
    get '/'
    response.body.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
    get '/contact'
    response.body.should have_selector('title', :content => "Contact")
  end

  it "should have an About page at '/about'" do
    get '/about'
    response.body.should have_selector('title', :content => "About")
  end

  it "should have a Help page at '/help'" do
    get '/help'
    response.body.should have_selector('title', :content => "Help")
  end

  it "should have a signup page at '/signup'" do
    get '/signup'
    response.body.should have_selector('title', :content => "Sign up")
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.find('title', :text => "About")
    click_link "Help"
    page.find('title', :content => "Help")
    click_link "Contact"
    page.find('title', :content => "Contact")
    click_link "Home"
    page.find('title', :content => "Home")
    click_link "Sign up now!"
    page.find('title', :text => "Sign up")
  end
end