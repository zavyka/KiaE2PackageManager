# KiaE2PackageManager

**Universal Package Manager for Enigma2 Satellite Receivers**

A powerful, all-in-one tool for managing plugins, skins, firmware images, and packages on Enigma2-based satellite receivers (Dreambox, VU+, GigaBlue, OpenATV, OpenPLi, DreamOS, and more).

🇺🇸 [English](#-english) | ☀️ [کوردی سۆرانی](#kurdish) | 🇮🇷 [فارسی](#-فارسی) | 🇸🇦 [العربية](#-العربية)

---

## 🇺🇸 English

### Features

- **Build & Recompile Packages** — Create `.deb` and `.ipk` packages from your plugin/skin projects
- **Extract & Unpack Packages** — Extract `.deb` and `.ipk` files with full structure preservation
- **Firmware Image Management** — Unpack and pack firmware images (`.nfi`, `.tar.xz`, `.tar.gz`, `.tar.bz2`)
- **Archive Operations** — Create compressed archives in multiple formats (`.zip`, `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`)
- **Auto-Detection** — Automatically detects receiver architecture (ARM, ARM64, MIPS, x86/x64)
- **Universal Compatibility** — Works with Python 2.7+ and Python 3.x
- **No Dependencies** — Uses only standard system tools, no external packages required
- **Package Validation** — Built-in validation to verify package integrity before installation

### Supported Receivers

| Brand | Models |
|-------|--------|
| Dreambox | DM800, DM8000, DM900, DM920, DM520, DM500HD |
| VU+ | Duo, Duo2, Duo4K, Solo, Solo2, Solo4K, Ultimo, Ultimo4K |
| GigaBlue | All Enigma2-based models |
| Other | Any receiver running Enigma2 (OpenATV, OpenPLi, DreamOS, etc.) |

### Supported Package Formats

| Format | Description | Usage |
|--------|-------------|-------|
| `.deb` | Debian package | Dreambox / DreamOS receivers |
| `.ipk` | IPK package | OpenATV / OpenPLi / OE2.0 receivers |
| `.tar.xz` | Compressed tar archive | General firmware/software |
| `.tar.gz` | Gzip compressed tar | General firmware/software |
| `.tar.bz2` | Bzip2 compressed tar | General firmware/software |
| `.nfi` | NFI firmware image | Dreambox firmware updates |
| `.zip` | ZIP archive | General file compression |

### Installation & Usage

#### Method 1: Direct Download on Receiver
```bash
wget -O /tmp/KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x /tmp/KiaE2PackageManager
/tmp/KiaE2PackageManager
```

#### Method 2: Transfer from PC via SSH/Telnet
```bash
ssh root@<receiver_ip>
cd /tmp
wget -O KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

#### Method 3: Offline Transfer (Putty + FileZilla / WinSCP)

**Step 1: Transfer the file to your receiver**

You can use any of these tools to copy `KiaE2PackageManager` to the `/tmp/` folder on your receiver:

| Tool | Protocol | Instructions |
|------|----------|-------------|
| **FileZilla** | FTP | Connect to `<receiver_ip>:21` → Navigate to `/tmp/` → Drag & drop the file |
| **WinSCP** | SCP/SFTP | Connect to `<receiver_ip>` (port 22) → Navigate to `/tmp/` → Drag & drop the file |
| **Putty (PSCP)** | SCP | Run: `pscp KiaE2PackageManager root@<receiver_ip>:/tmp/` |
| **Total Commander** | FTP/SCP | Use FTP or SCP plugin → Navigate to `/tmp/` → Upload file |

**Step 2: Connect via SSH and run**

Open **Putty** (or any SSH client) and connect to your receiver:

```
Host Name: <receiver_ip>
Port: 22
Connection Type: SSH
```

Login with:
```
Username: root
Password: dreambox
```

Then run these commands:

```bash
cd /tmp
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

> **Tip:** You can also use Putty's built-in SCP feature to transfer files directly.

### Usage Guide

#### Main Menu

When you run the tool, you'll see the main menu:

```
==========================================
   KiaE2PackageManager Universal v1.2.2
   (Plugins, Skins & Images Utility)
==========================================

Select Main Section:
  1) Plugins & Skins Manager (.ipk / .deb - /tmp based)
  2) Firmware & Images Manager (.nfi, .tar.xz, .tar.gz - Storage based)
  3) Exit Program
```

#### Option 1: Plugins & Skins Manager

**Building a Package:**

1. Select `1` from the main menu
2. Select `1` (Build / Recompile Package)
3. Choose your output format:
   - `1` — `.deb` (for Dreambox / DreamOS)
   - `2` — `.ipk` (for OpenATV / OpenPLi / OE2.0)
   - `3` — Both formats
4. The tool will scan `/tmp/` for project folders containing `usr` directory
5. Select your project folder or enter a custom path
6. Edit the control file if needed (package name, version, architecture, etc.)
7. Choose filename mode (original name or standard naming)
8. Wait for the build to complete
9. Optionally run validation test

**Extracting a Package:**

1. Select `1` from the main menu
2. Select `2` (Unpack / Extract Package)
3. The tool will scan `/tmp/` for `.deb` and `.ipk` files
4. Select your package or enter a custom path
5. The extracted files will be saved in `/tmp/<package_name>_extracted/`

#### Option 2: Firmware & Images Manager

**Unpacking a Firmware Image:**

1. Select `2` from the main menu
2. Select `1` (Unpack Image / Archive)
3. The tool will scan storage for supported image files
4. Select your image file or enter a custom path
5. Choose extraction destination
6. Wait for extraction to complete

**Creating an Archive:**

1. Select `2` from the main menu
2. Select `2` (Pack / Compress Folder)
3. Select the folder you want to compress
4. Choose output format (`.zip`, `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`)
5. Wait for compression to complete

### Project Structure (for Building Packages)

When building `.deb` or `.ipk` packages, your project folder should have this structure:

```
your_project/
├── DEBIAN/           # or CONTROL/
│   └── control       # Package metadata
├── usr/
│   ├── bin/          # Executables
│   ├── lib/          # Libraries
│   ├── share/        # Data files
│   └── ...
└── ...
```

Example `control` file:
```
Package: enigma2-plugin-skins-myskin
Version: 1.0
Architecture: all
Section: base
Priority: optional
Maintainer: Your Name <your@email.com>
Description: My Awesome Skin for Enigma2
 This is a beautiful skin for Enigma2 receivers.
Depends: enigma2
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| "Python not found" | Install Python: `opkg install python` or `apt-get install python3` |
| "Permission denied" | Run `chmod +x KiaE2PackageManager` |
| Package build fails | Check that your project folder has correct structure with `DEBIAN/control` |
| Validation fails | Ensure your package contains `control.tar` and `data.tar` |
| Archive extraction fails | Check if the file is corrupted or in unsupported format |
| Cannot connect via SSH | Make sure SSH server is running on receiver (install: `opkg install openssh`) |

### Developer Information

- **Developer:** KiaKu_1982
- **GitHub:** [github.com/zavyka](https://github.com/zavyka)
- **Telegram:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **Channel:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### 🌟 Support & Star

If you found this tool helpful, please:

- ⭐ **Star** the project on [GitHub](https://github.com/zavyka)
- 📢 **Share** it on:
  - [Telegram](https://t.me/Rayan_Ku)
  - [Facebook](https://www.facebook.com/)
  - [X (Twitter)](https://x.com/)
  - Enigma2 Forums
  - Satellite Receiver Groups
  - Any other platform
- 🐛 **Report issues** if you find any bugs at [Issues](https://github.com/zavyka/KiaE2PackageManager/issues)

By sharing this tool, you help other Enigma2 users discover it!

### License

MIT License

---

## <a id="kurdish"></a> ☀️ کوردی سۆرانی

### تایبەتمەندیەکان

- **دروستکردن و دوبارە دروستکردنی پاکێج** — دروستکردنی فایلەکانی `.deb` و `.ipk` لە پڕۆژەکانی پلاگین/سکینەکانت
- **دەرکردن و کردنەوەی پاکێج** — دەرکردنی فایلەکانی `.deb` و `.ipk` بە پاراستنی تەواوی شێواز
- **بەڕێوەبردنی فەرمویر** — کردنەوە و داگرتنی وێنەکانی فەرمویر (`.nfi`, `.tar.xz`, `.tar.gz`, `.tar.bz2`)
- **کردارەکانی ئارکیڤ** — دروستکردنی ئارکیڤە فشارکراوەکان بە فۆرمتە جیاوازەکان (`.zip`, `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`)
- **دەسنانی خۆکار** — دەسنانی خۆکاری ئارکیتەکچۆری رێسیڤێر (ARM, ARM64, MIPS, x86/x64)
- **گشتی** — کار لەگەڵ Python 2.7+ و Python 3.x
- **بێ پەیوەندی** — تەنها ئامرازەکانی ستانداردی سیستەم بەکاردێنێت
- **پشکنینی پاکێج** — پشکنینی ناوەخۆ بۆ سەلمێنانی گونجاویی پاکێج پێش دابەشکردن

### رێسیڤێرە پشتیوانیکراوەکان

| براند | مۆدێلەکان |
|-------|-----------|
| Dreambox | DM800, DM8000, DM900, DM920, DM520, DM500HD |
| VU+ | Duo, Duo2, Duo4K, Solo, Solo2, Solo4K, Ultimo, Ultimo4K |
| GigaBlue | هەموو مۆدێلەکانی پشتیوانیکراوی Enigma2 |
| هەندێک | هەر رێسیڤێرێک بە سیستەمی Enigma2 (OpenATV, OpenPLi, DreamOS و هتد.) |

### فۆرماتەکانی پاکێجی پشتیوانیکراوەکان

| فۆرمت | وەسف | بەکارهێنان |
|-------|------|-----------|
| `.deb` | پاکێجی دێبین | رێسیڤێرەکانی Dreambox / DreamOS |
| `.ipk` | پاکێجی IPK | رێسیڤێرەکانی OpenATV / OpenPLi / OE2.0 |
| `.tar.xz` | ئارکیڤی tarی فشارکراو | فەرمویر/نەرمەلەوەری گشتی |
| `.tar.gz` | tarی فشارکراو بە gzip | فەرمویر/نەرمەلەوەری گشتی |
| `.tar.bz2` | tarی فشارکراو بە bzip2 | فەرمویر/نەرمەلەوەری گشتی |
| `.nfi` | وێنەی فەرمویری NFI | نوێکردنەوەی فەرمویری Dreambox |
| `.zip` | ئارکیڤی ZIP | فشارکردنی فایلی گشتی |

### دامەزراندن و بەکارهێنان

#### شێوەی ١: داگرتنی ڕاستەوخۆ لەسەر رێسیڤێر
```bash
wget -O /tmp/KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x /tmp/KiaE2PackageManager
/tmp/KiaE2PackageManager
```

#### شێوەی ٢: گواستنەوە لە PC بە SSH/Telnet
```bash
ssh root@<receiver_ip>
cd /tmp
wget -O KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

#### شێوەی ٣: گواستنەوەی ئۆفلاین (Putty + FileZilla / WinSCP)

**هەنگاوی ١: گواستنەوەی فایل بۆ رێسیڤێرەکە**

دەتوانیت هەر یەکێک لەم ئامرازانە بەکاربهێنیت بۆ گواستنەوەی `KiaE2PackageManager` بۆ پوشەی `/tmp/` لە رێسیڤێرەکە:

| ئامراز | پرۆتۆکۆل | ئاراستەکان |
|--------|----------|-----------|
| **FileZilla** | FTP | پەیوەندی بکە بە `<receiver_ip>:21` → بچۆ بۆ `/tmp/` → فایلەکە بکەوە |
| **WinSCP** | SCP/SFTP | پەیوەندی بکە بە `<receiver_ip>` (پۆرت 22) → بچۆ بۆ `/tmp/` → فایلەکە بکەوە |
| **Putty (PSCP)** | SCP | فەرمان جێبەجێ بکە: `pscp KiaE2PackageManager root@<receiver_ip>:/tmp/` |
| **Total Commander** | FTP/SCP | بەکارهێنانی FTP یان SCP plugin → بچۆ بۆ `/tmp/` → فایلەکە بکەوە |

**هەنگاوی ٢: پەیوەندیکردن بە SSH و جێبەجێکردن**

**Putty** (یان هەر کلایێntێکی SSH) بیکەوە و پەیوەندی بکە بە رێسیڤێرەکە:

```
Host Name: <receiver_ip>
Port: 22
Connection Type: SSH
```

چوونەوە بکە بە:
```
Username: root
Password: dreambox
```

پاشان ئەم فەرمانانە جێبەجێ بکە:

```bash
cd /tmp
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

> **ئامار:** دەتوانیت تایبەتمەندی SCPی Putty بەکاربهێنیت بۆ گواستنەوەی فایلەکان بە ڕاستەوخۆ.

### رێنمای بەکارهێنان

#### مینیوی سەرەکی

```
==========================================
   KiaE2PackageManager Universal v1.2.2
   (ئامرازی بەڕێوەبردنی پلاگینەکان، سکینەکان و وێنەکان)
==========================================

هەڵبژاردنی بەشی سەرەکی:
  1) بەڕێوەبەری پلاگینەکان و سکینەکان (.ipk / .deb)
  2) بەڕێوەبەری فەرمویر و وێنەکان (.nfi, .tar.xz, .tar.gz)
  3) دەرچوون لە برنامە
```

#### هەڵبژاردنی ١: بەڕێوەبەری پلاگینەکان و سکینەکان

**دروستکردنی پاکێج:**
1. هەڵبژاردنی `1` لە مینیوی سەرەکی
2. هەڵبژاردنی `1` (دروستکردن / دوبارە دروستکردنی پاکێج)
3. فۆرمتی دەرەوە هەڵبژێرە
4. پشکنین بکە و چاوەڕوانی بکە

**دەرکردنی پاکێج:**
1. هەڵبژاردنی `1` لە مینیوی سەرەکی
2. هەڵبژاردنی `2` (کردنەوە / دەرکردنی پاکێج)
3. فایلی پاکێج هەڵبژێرە
4. فایلەکانی دەرکراو تۆمار دەکرێن

#### هەڵبژاردنی ٢: بەڕێوەبەری فەرمویر و وێنەکان

**کردنەوەی وێنەی فەرمویر:**
1. هەڵبژاردنی `2` لە مینیوی سەرەکی
2. هەڵبژاردنی `1` (کردنەوەی وێنە / ئارکیڤ)
3. فایلی وێنە هەڵبژێرە
4. ئاراستەی دەرکردن هەڵبژێرە

**دروستکردنی ئارکیڤ:**
1. هەڵبژاردنی `2` لە مینیوی سەرەکی
2. هەڵبژاردنی `2` (پاککردنەوە / فشارکردنی پوشە)
3. پوشەی مەوردەیت هەڵبژێرە
4. فۆرمتی دەرەوە هەڵبژێرە

### ڕاستکردنەوەی هەڵە

| کێشە | چارەسەر |
|------|---------|
| "Python not found" | پایتۆن دابەزێنە: `opkg install python` |
| "Permission denied" | فەرمانی `chmod +x KiaE2PackageManager` جێبەجێ بکە |
| هەڵە لە دروستکردنی پاکێج | شێوازی پوشهی پڕۆژەکە پشکنین بکە |
| هەڵە لە پشکنین | دڵنیا بە لەوانەی پاکێجەکەت تێدەگرێت `control.tar` و `data.tar` |
| پەیوەندی SSH سەر نەکرا | دڵنیا بە لەوەی ڕاژەی SSH کاردەکات لەسەر رێسیڤێر (دامەزراندن: `opkg install openssh`) |

### زانیاری دەveloper

- **دەveloper:** KiaKu_1982
- **GitHub:** [github.com/zavyka](https://github.com/zavyka)
- **Telegram:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **Channel:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### 🌟 پشتیبانی و ستارە دان

ئەگەر ئەم ئامرازە بەردەست بوویت و یارمەتیت دا، تکایە:

- ⭐ **ستارە بکە** بۆ پڕۆژەکە لە [GitHub](https://github.com/zavyka)
- 📢 **هاوبەش بکە** لە:
  - [تێلێگرام](https://t.me/Rayan_Ku)
  - [فەیسبووک](https://www.facebook.com/)
  - [X (تێیتەر)](https://x.com/)
  - فۆرووەکانی Enigma2
  - گرووپەکانی رێسیڤێری ماهوارە
  - هەر پلەتڤۆرماوتراکێک
- 🐛 **هەڵەی تۆمار بکە** ئەگەر کێشەیەکت بینی لە [Issues](https://github.com/zavyka/KiaE2PackageManager/issues)

بە هاوبەشکردنی ئەم ئامرازە، یارمەتی بەکارهێنەرانی تری Enigma2 دەدەیت بۆ دۆزینەوەی ئەم ئامرازە!

### مۆڵەت

مۆڵەتی MIT

---

## 🇮🇷 فارسی

### ویژگی‌ها

- **ساخت و بازسازی پکیج** — ایجاد فایل‌های `.deb` و `.ipk` از پروژه‌های پلاگین/اسکین شما
- **استخراج و بازکردن پکیج** — استخراج فایل‌های `.deb` و `.ipk` با حفظ ساختار کامل
- **مدیریت فریمور** — بازکردن و بسته تصاویر فریمور (`.nfi`, `.tar.xz`, `.tar.gz`, `.tar.bz2`)
- **عملیات آرشیو** — ایجاد آرشیوهای فشرده در فرمت‌های مختلف (`.zip`, `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`)
- **تشخیص خودکار** — تشخیص خودکار معماری گیرنده (ARM, ARM64, MIPS, x86/x64)
- **سازگاری جهانی** — کار با Python 2.7+ و Python 3.x
- **بدون وابستگی** — فقط از ابزارهای استاندارد سیستم استفاده می‌کند
- **اعتبارسنجی پکیج** — اعتبارسنجی داخلی برای بررسی صحت پکیج قبل از نصب

### گیرنده‌های پشتیبانی شده

| برند | مدل‌ها |
|------|--------|
| Dreambox | DM800, DM8000, DM900, DM920, DM520, DM500HD |
| VU+ | Duo, Duo2, Duo4K, Solo, Solo2, Solo4K, Ultimo, Ultimo4K |
| GigaBlue | تمام مدل‌های مبتنی بر Enigma2 |
| سایر | هر گیرنده‌ای با سیستم‌عامل Enigma2 (OpenATV, OpenPLi, DreamOS و غیره) |

### فرمت‌های پکیج پشتیبانی شده

| فرمت | توضیح | کاربرد |
|------|-------|--------|
| `.deb` | پکیج دبیان | گیرنده‌های Dreambox / DreamOS |
| `.ipk` | پکیج IPK | گیرنده‌های OpenATV / OpenPLi / OE2.0 |
| `.tar.xz` | آرشیو فشرده tar | فریمور/نرم‌افزار عمومی |
| `.tar.gz` | tar فشرده با gzip | فریمور/نرم‌افزار عمومی |
| `.tar.bz2` | tar فشرده با bzip2 | فریمور/نرم‌افزار عمومی |
| `.nfi` | تصویر فریمور NFI | بروزرسانی فریمور Dreambox |
| `.zip` | آرشیو ZIP | فشرده‌سازی فایل عمومی |

### نصب و استفاده

#### روش ۱: دانلود مستقیم روی گیرنده
```bash
wget -O /tmp/KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x /tmp/KiaE2PackageManager
/tmp/KiaE2PackageManager
```

#### روش ۲: انتقال از کامپیوتر از طریق SSH/Telnet
```bash
ssh root@<receiver_ip>
cd /tmp
wget -O KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

#### روش ۳: انتقال آفلاین (Putty + FileZilla / WinSCP)

**مرحله ۱: انتقال فایل به گیرنده**

از هر کدام از این نرم‌افزارها می‌توانید برای کپی کردن `KiaE2PackageManager` در پوشه `/tmp/` روی گیرنده استفاده کنید:

| نرم‌افزار | پروتکل | راهنما |
|----------|--------|-------|
| **FileZilla** | FTP | اتصال به `<receiver_ip>:21` → رفتن به `/tmp/` → کشیدن و رها کردن فایل |
| **WinSCP** | SCP/SFTP | اتصال به `<receiver_ip>` (پورت 22) → رفتن به `/tmp/` → کشیدن و رها کردن فایل |
| **Putty (PSCP)** | SCP | اجرای دستور: `pscp KiaE2PackageManager root@<receiver_ip>:/tmp/` |
| **Total Commander** | FTP/SCP | استفاده از افزونه FTP یا SCP → رفتن به `/tmp/` → آپلود فایل |

**مرحله ۲: اتصال از طریق SSH و اجرا**

**Putty** (یا هر کلاینت SSH دیگر) را باز کنید و به گیرنده متصل شوید:

```
Host Name: <receiver_ip>
Port: 22
Connection Type: SSH
```

ورود با:
```
Username: root
Password: dreambox
```

سپس دستورات زیر را اجرا کنید:

```bash
cd /tmp
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

> **نکته:** همچنین می‌توانید از قابلیت SCP داخلی Putty برای انتقال مستقیم فایل‌ها استفاده کنید.

### راهنمای استفاده

#### منوی اصلی

```
==========================================
   KiaE2PackageManager Universal v1.2.2
   (ابزار مدیریت پلاگین‌ها، اسکین‌ها و تصاویر)
==========================================

انتخاب بخش اصلی:
  1) مدیریت پلاگین‌ها و اسکین‌ها (.ipk / .deb)
  2) مدیریت فریمور و تصاویر (.nfi, .tar.xz, .tar.gz)
  3) خروج از برنامه
```

#### گزینه ۱: مدیریت پلاگین‌ها و اسکین‌ها

**ساخت پکیج:**
1. گزینه `1` را از منوی اصلی انتخاب کنید
2. گزینه `1` (ساخت / بازسازی پکیج) را انتخاب کنید
3. فرمت خروجی را انتخاب کنید:
   - `1` — `.deb` (برای Dreambox / DreamOS)
   - `2` — `.ipk` (برای OpenATV / OpenPLi / OE2.0)
   - `3` — هر دو فرمت
4. ابزار پوشه‌های پروژه در `/tmp/` را اسکن می‌کند
5. پوشه پروژه خود را انتخاب کنید
6. فایل کنترل را در صورت نیاز ویرایش کنید
7. منتظر اتمام ساخت باشید

**استخراج پکیج:**
1. گزینه `1` را از منوی اصلی انتخاب کنید
2. گزینه `2` (بازکردن / استخراج پکیج) را انتخاب کنید
3. فایل پکیج را انتخاب کنید
4. فایل‌های استخراج شده در `/tmp/<نام_پکیج>_extracted/` ذخیره می‌شوند

#### گزینه ۲: مدیریت فریمور و تصاویر

**بازکردن تصویر فریمور:**
1. گزینه `2` را از منوی اصلی انتخاب کنید
2. گزینه `1` (بازکردن تصویر / آرشیو) را انتخاب کنید
3. فایل تصویر را انتخاب کنید
4. مقصد استخراج را انتخاب کنید

**ایجاد آرشیو:**
1. گزینه `2` را از منوی اصلی انتخاب کنید
2. گزینه `2` (بسته‌بندی / فشرده‌سازی پوشه) را انتخاب کنید
3. پوشه مورد نظر را انتخاب کنید
4. فرمت خروجی را انتخاب کنید

### عیب‌یابی

| مشکل | راه‌حل |
|------|--------|
| "Python not found" | پایتون را نصب کنید: `opkg install python` |
| "Permission denied" | دستور `chmod +x KiaE2PackageManager` را اجرا کنید |
| خطا در ساخت پکیج | ساختار پوشه پروژه را بررسی کنید |
| خطا در اعتبارسنجی | مطمئن شوید پکیج شامل `control.tar` و `data.tar` است |
| عدم اتصال SSH | مطمئن شوید سرور SSH روی گیرنده فعال است (نصب: `opkg install openssh`) |

### اطلاعات توسعه‌دهنده

- **توسعه‌دهنده:** KiaKu_1982
- **گیت‌هاب:** [github.com/zavyka](https://github.com/zavyka)
- **تلگرام:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **کانال:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### 🌟 حمایت و ستاره دان

اگر این ابزار برایتان مفید بود، لطفاً:

- ⭐ **ستاره بدهید** به پروژه در [GitHub](https://github.com/zavyka)
- 📢 **اشتراک بگذارید** در:
  - [تلگرام](https://t.me/Rayan_Ku)
  - [فیسبوک](https://www.facebook.com/)
  - [X (توییتر)](https://x.com/)
  - انجمن‌های Enigma2
  - گروه‌های گیرنده ماهواره
  - هر پلتفرم دیگری
- 🐛 **مشکلات را گزارش کنید** اگر باگی پیدا کردید در [Issues](https://github.com/zavyka/KiaE2PackageManager/issues)

با اشتراک‌گذاری این ابزار، به کاربران دیگر Enigma2 کمک کنید تا آن را پیدا کنند!

### مجوز

مجوز MIT

---

## 🇸🇦 العربية

### الميزات

- **بناء وإعادة بناء الحزم** — إنشاء ملفات `.deb` و `.ipk` من مشاريع الإضافات والأ skins
- **استخراج وفك الحزم** — استخراج ملفات `.deb` و `.ipk` مع الحفظ الكامل للبنية
- **إدارة البرامج الثابتة** — فك وضغط صور البرامج الثابتة (`.nfi`, `.tar.xz`, `.tar.gz`, `.tar.bz2`)
- **عمليات الأرشيف** — إنشاء أرشيفات مضغوطة بتنسيقات متعددة (`.zip`, `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`)
- **كشف تلقائي** — كشف تلقائي لهيكل المستقبل (ARM, ARM64, MIPS, x86/x64)
- **توافق عالمي** — يعمل مع Python 2.7+ و Python 3.x
- **بدون تبعيات** — يستخدم فقط أدوات النظام الأساسية
- **التحقق من الحزم** — تحقق مدمج للتحقق من سلامة الحزم قبل التثبيت

### أجهزة الاستقبال المدعومة

| العلامات التجارية | الطرازات |
|-----------------|----------|
| Dreambox | DM800, DM8000, DM900, DM920, DM520, DM500HD |
| VU+ | Duo, Duo2, Duo4K, Solo, Solo2, Solo4K, Ultimo, Ultimo4K |
| GigaBlue | جميع الطرازات المبنية على Enigma2 |
| أخرى | أي جهاز استقبال يعمل بنظام Enigma2 (OpenATV, OpenPLi, DreamOS) |

### تنسيقات الحزم المدعومة

| التنسيق | الوصف | الاستخدام |
|---------|-------|----------|
| `.deb` | حزمة ديبيان | أجهزة Dreambox / DreamOS |
| `.ipk` | حزمة IPK | أجهزة OpenATV / OpenPLi / OE2.0 |
| `.tar.xz` | أرشيف tar مضغوط | البرامج الثابتة العامة |
| `.tar.gz` | tar مضغوط بـ gzip | البرامج الثابتة العامة |
| `.tar.bz2` | tar مضغوط بـ bzip2 | البرامج الثابتة العامة |
| `.nfi` | صورة برنامج ثابت NFI | تحديثات برنامج Dreambox |
| `.zip` | أرشيف ZIP | ضغط الملفات العامة |

### التثبيت والاستخدام

#### الطريقة 1: التحميل المباشر على جهاز الاستقبال
```bash
wget -O /tmp/KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x /tmp/KiaE2PackageManager
/tmp/KiaE2PackageManager
```

#### الطريقة 2: النقل من الكمبيوتر عبر SSH/Telnet
```bash
ssh root@<receiver_ip>
cd /tmp
wget -O KiaE2PackageManager https://raw.githubusercontent.com/zavyka/KiaE2PackageManager/main/KiaE2PackageManager
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

#### الطريقة 3: النقل دون اتصال (Putty + FileZilla / WinSCP)

**الخطوة 1: نقل الملف إلى جهاز الاستقبال**

يمكنك استخدام أي من هذه الأدوات لنسخ `KiaE2PackageManager` إلى المجلد `/tmp/` على جهاز الاستقبال:

| الأداة | البروتوكول | التعليمات |
|--------|-----------|----------|
| **FileZilla** | FTP | الاتصال بـ `<receiver_ip>:21` → الانتقال إلى `/tmp/` → سحب وإفلات الملف |
| **WinSCP** | SCP/SFTP | الاتصال بـ `<receiver_ip>` (منفذ 22) → الانتقال إلى `/tmp/` → سحب وإفلات الملف |
| **Putty (PSCP)** | SCP | تنفيذ الأمر: `pscp KiaE2PackageManager root@<receiver_ip>:/tmp/` |
| **Total Commander** | FTP/SCP | استخدام إضافة FTP أو SCP → الانتقال إلى `/tmp/` → رفع الملف |

**الخطوة 2: الاتصال عبر SSH والتشغيل**

افتح **Putty** (أي عميل SSH آخر) واتصل بجهاز الاستقبال:

```
Host Name: <receiver_ip>
Port: 22
Connection Type: SSH
```

تسجيل الدخول بـ:
```
Username: root
Password: dreambox
```

ثم نفذ الأوامر التالية:

```bash
cd /tmp
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

> **نصيحة:** يمكنك أيضًا استخدام ميزة SCP المدمجة في Putty لنقل الملفات مباشرة.

### دليل الاستخدام

#### القائمة الرئيسية

```
==========================================
   KiaE2PackageManager Universal v1.2.2
   (أداة إدارة الإضافات والأ skins والصور)
==========================================

اختر القسم الرئيسي:
  1) مدير الإضافات والأ skins (.ipk / .deb)
  2) مدير البرامج الثابتة والصور (.nfi, .tar.xz, .tar.gz)
  3) خروج من البرنامج
```

#### الخيار 1: مدير الإضافات والأ skins

**بناء حزمة:**
1. اختر `1` من القائمة الرئيسية
2. اختر `1` (بناء / إعادة بناء الحزمة)
3. اختر صيغة الإخراج
4. انتظر اكتمال البناء

**استخراج حزمة:**
1. اختر `1` من القائمة الرئيسية
2. اختر `2` (فك / استخراج الحزمة)
3. اختر ملف الحزمة
4. يتم حفظ الملفات المستخرجة في `/tmp/<اسم_الحزمة>_extracted/`

#### الخيار 2: مدير البرامج الثابتة والصور

**فك صورة برنامج ثابت:**
1. اختر `2` من القائمة الرئيسية
2. اختر `1` (فك صورة / أرشيف)
3. اختر ملف الصورة
4. اختر وجهة الاستخراج

**إنشاء أرشيف:**
1. اختر `2` من القائمة الرئيسية
2. اختر `2` (ضغط / حزم مجلد)
3. اختر المجلد المطلوب
4. اختر صيغة الإخراج

### استكشاف الأخطاء وإصلاحها

| المشكلة | الحل |
|---------|------|
| "Python not found" | ثبّت Python: `opkg install python` |
| "Permission denied" | نفّذ `chmod +x KiaE2PackageManager` |
| فشل بناء الحزمة | تحقق من بنية مجلد المشروع |
| فشل التحقق | تأكد من وجود `control.tar` و `data.tar` |
| فشل الاتصال بـ SSH | تأكد من تشغيل خادم SSH على جهاز الاستقبال (التثبيت: `opkg install openssh`) |

### معلومات المطور

- **المطور:** KiaKu_1982
- **GitHub:** [github.com/zavyka](https://github.com/zavyka)
- **Telegram:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **القناة:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### 🌟 الدعم والتقييم

إذا وجدت هذه الأداة مفيدة، يرجى:

- ⭐ **تقييم** المشروع على [GitHub](https://github.com/zavyka)
- 📢 **مشاركة** الأداة على:
  - [تيليجرام](https://t.me/Rayan_Ku)
  - [فيسبوك](https://www.facebook.com/)
  - [X (تويتر)](https://x.com/)
  - منتديات Enigma2
  - مجموعات أجهزة الاستقبال الفضائية
  - أي منصة أخرى
- 🐛 **الإبلاغ عن المشاكل** إذا وجدت أي أخطاء في [Issues](https://github.com/zavyka/KiaE2PackageManager/issues)

بمشاركة هذه الأداة، تساعد مستخدمي Enigma2 الآخرين في اكتشافها!

### الترخيص

رخصة MIT
