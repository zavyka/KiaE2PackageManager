# KiaE2PackageManager

**Universal Package Manager for Enigma2 Satellite Receivers**

A powerful, all-in-one tool for managing plugins, skins, firmware images, and packages on Enigma2-based satellite receivers (Dreambox, VU+, GigaBlue, OpenATV, OpenPLi, DreamOS, and more).

[English](#english) | [فارسی](#فارسی) | [کوردی سورانی](#کوردی-سورانی) | [العربية](#العربية)

---

## English

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
| `.nfi` | NFI firmware image | Dreambox firmware updates |
| `.tar.xz` | Compressed tar archive | General firmware/software |
| `.tar.gz` | Gzip compressed tar | General firmware/software |
| `.tar.bz2` | Bzip2 compressed tar | General firmware/software |
| `.zip` | ZIP archive | General file compression |

### Installation

#### On Receiver (Direct Download)
```bash
# Download the tool
wget -O /tmp/KiaE2PackageManager <YOUR_DOWNLOAD_URL>

# Make it executable
chmod +x /tmp/KiaE2PackageManager

# Run it
/tmp/KiaE2PackageManager
```

#### Via Telnet/SSH
```bash
# Connect to your receiver
telnet <receiver_ip>
# or
ssh root@<receiver_ip>

# Download and run
cd /tmp
wget -O KiaE2PackageManager <YOUR_DOWNLOAD_URL>
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

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

### Developer Information

- **Developer:** KiaKu_1982
- **GitHub:** [github.com/zavyka](https://github.com/zavyka)
- **Telegram:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **Channel:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### License

MIT License

---

## فارسی

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
| `.nfi` | تصویر فریمور NFI | بروزرسانی فریمور Dreambox |
| `.tar.xz` | آرشیو فشرده tar | فریمور/نرم‌افزار عمومی |
| `.tar.gz` | tar فشرده با gzip | فریمور/نرم‌افزار عمومی |
| `.tar.bz2` | tar فشرده با bzip2 | فریمور/نرم‌افزار عمومی |
| `.zip` | آرشیو ZIP | فشرده‌سازی فایل عمومی |

### نصب

#### روی گیرنده (دانلود مستقیم)
```bash
# دانلود ابزار
wget -O /tmp/KiaE2PackageManager <YOUR_DOWNLOAD_URL>

# دادن مجوز اجرا
chmod +x /tmp/KiaE2PackageManager

# اجرا
/tmp/KiaE2PackageManager
```

#### از طریق Telnet/SSH
```bash
# اتصال به گیرنده
telnet <receiver_ip>
# یا
ssh root@<receiver_ip>

# دانلود و اجرا
cd /tmp
wget -O KiaE2PackageManager <YOUR_DOWNLOAD_URL>
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

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

### اطلاعات توسعه‌دهنده

- **توسعه‌دهنده:** KiaKu_1982
- **گیت‌هاب:** [github.com/zavyka](https://github.com/zavyka)
- **تلگرام:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **کانال:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### مجوز

مجوز MIT

---

## کوردی سورانی

### تایبەتمەندیەکان

- **دروستکردن و دوبارە دروستکردنی پاکێج** — دروستکردنی فایلەکانی `.deb` و `.ipk` لە پڕۆژەکانی پلاگین/سکینەکانت
- **دەرکردن و کردنەوەی پاکێج** — دەرکردنی فایلەکانی `.deb` و `.ipk` بە پاراستنی تەواوی شێواز
- **بەڕێوەبردنی فەرمویر** — کردنەوە و داگرتنی وێنەکانی فەرمویر (`.nfi`, `.tar.xz`, `.tar.gz`, `.tar.bz2`)
- **کردارەکانی ئارکیڤ** — دروستکردنی ئارکیڤە فشارکراوەکان بە فۆرمتە جیاوازەکان (`.zip`, `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`)
- **دەسنانی خۆکار** — دەسنانی خۆکاری ئارکیتەکچۆری گیرانە (ARM, ARM64, MIPS, x86/x64)
- **گشتی** — کار لەگەڵ Python 2.7+ و Python 3.x
- **بێ پەیوەندی** — تەنها ئامرازەکانی ستانداردی سیستەم بەکاردێنێت
- **پشکنینی پاکێج** — پشکنینی ناوەخۆ بۆ سەلمێنانی گونجاویی پاکێج پێش دابەشکردن

### گیرانە پشتیوانیکراوەکان

| براند | مۆدێلەکان |
|-------|-----------|
| Dreambox | DM800, DM8000, DM900, DM920, DM520, DM500HD |
| VU+ | Duo, Duo2, Duo4K, Solo, Solo2, Solo4K, Ultimo, Ultimo4K |
| GigaBlue | هەموو مۆدێلەکانی پشتیوانیکراوی Enigma2 |
| هەندێک | هەر گیرانەیەک بە سیستەمی Enigma2 (OpenATV, OpenPLi, DreamOS و هتد.) |

### فۆرماتەکانی پاکێجی پشتیوانیکراوەکان

| فۆرمت | وەسف | بەکارهێنان |
|-------|------|-----------|
| `.deb` | پاکێجی دێبین | گیرانەکانی Dreambox / DreamOS |
| `.ipk` | پاکێجی IPK | گیرانەکانی OpenATV / OpenPLi / OE2.0 |
| `.nfi` | وێنەی فەرمویری NFI | نوێکردنەوەی فەرمویری Dreambox |
| `.tar.xz` | ئارکیڤی tarی فشارکراو | فەرمویر/نەرمەلەوەری گشتی |
| `.tar.gz` | tarی فشارکراو بە gzip | فەرمویر/نەرمەلەوەری گشتی |
| `.tar.bz2` | tarی فشارکراو بە bzip2 | فەرمویر/نەرمەلەوەری گشتی |
| `.zip` | ئارکیڤی ZIP | فشارکردنی فایلی گشتی |

### دامەزراندن

#### لەسەر گیرانە (داگرتنی ڕاستەوخۆ)
```bash
# داگرتنی ئامرازەکە
wget -O /tmp/KiaE2PackageManager <YOUR_DOWNLOAD_URL>

# دانانی مۆڵەتی جێبەجێکردن
chmod +x /tmp/KiaE2PackageManager

# جێبەجێکردن
/tmp/KiaE2PackageManager
```

#### لە طریقەی Telnet/SSH
```bash
# پەیوەندیکردن بە گیرانەکە
telnet <receiver_ip>
# یان
ssh root@<receiver_ip>

# داگرتن و جێبەجێکردن
cd /tmp
wget -O KiaE2PackageManager <YOUR_DOWNLOAD_URL>
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

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

### ڕاستکردنەوەی هەڵە

| کێشە | چارەسەر |
|------|---------|
| "Python not found" | پایتۆن دابەزێنە: `opkg install python` |
| "Permission denied" | فەرمانی `chmod +x KiaE2PackageManager` جێبەجێ بکە |
| هەڵە لە دروستکردنی پاکێج | شێوازی پوشهی پڕۆژەکە پشکنین بکە |

### زانیاری دەveloper

- **دەveloper:** KiaKu_1982
- **GitHub:** [github.com/zavyka](https://github.com/zavyka)
- **Telegram:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **Channel:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### مۆڵەت

مۆڵەتی MIT

---

## العربية

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
| `.nfi` | صورة برنامج ثابت NFI | تحديثات برنامج Dreambox |
| `.tar.xz` | أرشيف tar مضغوط | البرامج الثابتة العامة |
| `.tar.gz` | tar مضغوط بـ gzip | البرامج الثابتة العامة |
| `.tar.bz2` | tar مضغوط بـ bzip2 | البرامج الثابتة العامة |
| `.zip` | أرشيف ZIP | ضغط الملفات العامة |

### التثبيت

#### على جهاز الاستقبال (تحميل مباشر)
```bash
# تحميل الأداة
wget -O /tmp/KiaE2PackageManager <YOUR_DOWNLOAD_URL>

# إعطاء صلاحية التنفيذ
chmod +x /tmp/KiaE2PackageManager

# التشغيل
/tmp/KiaE2PackageManager
```

#### عبر Telnet/SSH
```bash
# الاتصال بجهاز الاستقبال
telnet <receiver_ip>
# أو
ssh root@<receiver_ip>

# التحميل والتشغيل
cd /tmp
wget -O KiaE2PackageManager <YOUR_DOWNLOAD_URL>
chmod +x KiaE2PackageManager
./KiaE2PackageManager
```

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

### معلومات المطور

- **المطور:** KiaKu_1982
- **GitHub:** [github.com/zavyka](https://github.com/zavyka)
- **Telegram:** [@Rayan_Ku](https://t.me/Rayan_Ku)
- **القناة:** [@Enigma2_Tutorials](https://t.me/Enigma2_Tutorials)

### الترخيص

رخصة MIT
