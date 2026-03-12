from time import sleep
from dotenv import load_dotenv
from os import environ
from sys import exit

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
from selenium.common.exceptions import NoSuchElementException

environ.clear()

load_dotenv()
username = environ.get("USERNAME")
password = environ.get("PASSWORD")
base_uri = environ.get("BASEURL")

if not username or not password or not base_uri:
    exit("env vars not loading")

if __name__ == "__main__":
    opts = Options()
    opts.add_argument("-headless")

    driver = webdriver.Firefox(options=opts)

    try:
        driver.get(f"{base_uri}/login")
        sleep(2)
        try:
            username_field = driver.find_element(By.ID, "username")
            password_field = driver.find_element(By.ID, "userpassword")
            username_field.send_keys(username)
            password_field.send_keys(password)
            driver.find_element(By.ID, "loginBtn").click()

            sleep(5)

            if "/login" in driver.current_url:
                exit("login attempt failed")

        except NoSuchElementException:
            print("Login form not found, asuming already logged in")
        
        driver.get(f"{base_uri}/Reboot")
        sleep(2)
        driver.find_element(By.ID, "reboot_btn").click()

    except Exception as e:
        print(e)
        print("Something went wrong")

    finally:
        driver.quit()

