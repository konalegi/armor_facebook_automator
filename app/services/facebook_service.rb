require 'capybara/dsl'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

class FacebookService
  attr_reader :login, :password, :employer, :location, :story, :start_date

  Capybara.default_driver = :selenium
  Capybara.run_server = false
  Capybara.default_selector = :xpath

  include Capybara::DSL

  def self.perform(task_id, params)
    fork do
      begin
        new(params).perform
        Task.asynk_task_completed(task_id, true)
      rescue Exception => ex
        Task.asynk_task_completed(task_id, false, ex.message)
        raise
      end
    end
  end

  def initialize(params = {})
    @login = params[:login]
    @password = params[:password]
    @employer = params[:employer]
    @location = params[:location]
    @story = params[:story]
    @start_date = params[:start_date]

    # Capybara.app_host = 'https://www.facebook.com'
  end

  # h791135@mvrht.com
  # 123123Abc
  def perform
    visit('https://www.facebook.com/')

    set_login(login)
    set_password(password)
    click_login

    click_to_profile
    click_to_life_event
    click_to_job_and_edu
    click_to_new_job

    # set i currently work there /html/body/div[20]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[4]/td[2]/div/div[1]/input

    div_index = find_valid_index{ |i| "/html/body/div[#{i}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[1]/td[2]/div/div/div/input" }

    set_employer(div_index, employer)
    set_location(div_index, location)
    set_story(div_index, story)

    set_month(div_index, start_date.month)
    set_day(div_index, start_date.day)
    set_year(div_index, start_date.year)
    click_save(div_index)

    page.driver.browser.close
  end

  def click_to_life_event
    '//*[@id="js_a0"]/span/span[1]'
    find('/html/body/div[1]/div[2]/div[1]/div/div[2]/div[2]/div[2]/div/div[2]/div[2]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/li/div/div/div/div/div/div/div[2]/div[1]/div/div[1]/div/div[1]/div/a[3]/span/span[1]').click
  end

  def click_to_job_and_edu
    find('/html/body/div[1]/div[2]/div[1]/div/div[2]/div[2]/div[2]/div/div[2]/div[2]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/li/div/div/div/div/div/div/div[2]/div[1]/div/div[2]/div/ul[1]/li[1]/a/span[2]').click
  end

  def click_to_new_job
    find('/html/body/div[1]/div[2]/div[1]/div/div[2]/div[2]/div[2]/div/div[2]/div[2]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/li/div/div/div/div/div/div/div[2]/div[1]/div/div[2]/div/ul[2]/li[1]/a/span').click
  end

  def click_to_profile()
    find('/html/body/div[1]/div[1]/div/div[1]/div/div/div/div[2]/div[1]/div[1]/div/a').click
  end

  def set_login(login)
    find('/html/body/div/div[1]/div/div/div/div/div[2]/form/table/tbody/tr[2]/td[1]/input').set(login)
  end

  def set_password(password)
    find('/html/body/div/div[1]/div/div/div/div/div[2]/form/table/tbody/tr[2]/td[2]/input').set(password)
  end

  def click_login
    find('/html/body/div/div[1]/div/div/div/div/div[2]/form/table/tbody/tr[2]/td[3]/label/input').click
  end

  def click_save(div_index)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[2]/table/tbody/tr/td[4]/button").click
  end

  def set_story(div_index, story)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[5]/td[2]/div/textarea").set(story)
  end

  def set_location(div_index, location)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[3]/td[2]/div/div[1]/div/input").set(location)
  end

  def set_employer(div_index, employer)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[1]/td[2]/div/div/div/input").set(employer)
  end

  def set_month(div_index, month)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[4]/td[2]/div/div[3]/span[2]/select/option[@value='#{month}']").click
  end

  def set_day(div_index, day)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[4]/td[2]/div/div[3]/span[3]/select/option[@value='#{day}']").click
  end

  def set_year(div_index, year)
    find("/html/body/div[#{div_index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[4]/td[2]/div/div[3]/span[1]/select/option[@value='#{year}']").click
  end

  def find_valid_index &block
    found_index = nil
    (16..30).each do |index|
      begin
        # elem = find("/html/body/div[#{index}]/div[2]/div/div/div/div[2]/div/div[2]/form/div[1]/table/tbody/tr[1]/td[2]/div/div/div/input")
        find(yield(index))
        found_index = index
        break
      rescue Capybara::ElementNotFound => ex
        p "div at index #{index} not found"
      end
    end
    raise(RuntimeError.new('Element not found')) if found_index.nil?
    found_index
  end

end