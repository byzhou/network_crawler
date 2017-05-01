from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import os

chromedriver = "/home/bobzhou/2017_spring/chromedriver/chromedriver"
os.environ["webdriver.chrome.driver"] = chromedriver
#driver = webdriver.Firefox()
driver = webdriver.Chrome(chromedriver)
driver.get("http://www.python.org")
assert "Python" in driver.title
elem = driver.find_element_by_name("q")
elem.clear()
elem.send_keys("pycon")
elem.send_keys(Keys.RETURN)
assert "No results found." not in driver.page_source
driver.close()
