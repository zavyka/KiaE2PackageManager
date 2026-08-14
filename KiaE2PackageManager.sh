#!/bin/bash

APP_NAME="KiaE2PackageManager Universal"
APP_VERSION="1.2.3"
DEVELOPER="KiaKu_1982"
GITHUB="github.com/zavyka"
TELEGRAM_ID="@Rayan_Ku"
TELEGRAM_CHANNEL="@Enigma2_Tutorials"

Y='\033[1;33m'
G='\033[1;32m'
C='\033[1;36m'
B='\033[1;34m'
R='\033[1;31m'
NC='\033[0m'

create_ar_archive() {
    local OUT_FILE="$1"
    shift
    local IN_FILES=("$@")

    PYTHON_BIN=$(command -v python3 || command -v python || command -v python2)
    if [ -n "$PYTHON_BIN" ]; then
        $PYTHON_BIN -c "
import sys, os

out_path = '${OUT_FILE}'
in_files = [$(printf "'%s', " "${IN_FILES[@]}")]

with open(out_path, 'wb') as ar:
    ar.write(b'!<arch>\n')
    for fpath in in_files:
        if not os.path.exists(fpath): continue
        fname = os.path.basename(fpath)
        fsize = os.path.getsize(fpath)
        hdr = ('%-16s%-12s%-6s%-6s%-8s%-10s\x60\n' % (fname, '0', '0', '0', '100644', str(fsize))).encode('latin1')
        ar.write(hdr)
        with open(fpath, 'rb') as f:
            ar.write(f.read())
        if fsize % 2 == 1:
            ar.write(b'\n')
" 2>/dev/null
        if [ -f "$OUT_FILE" ] && [ -s "$OUT_FILE" ]; then
            return 0
        fi
    fi

    ar -cr "$OUT_FILE" "${IN_FILES[@]}" 2>/dev/null
}

get_ar_members_python() {
    local PKG_PATH="$1"
    PYTHON_BIN=$(command -v python3 || command -v python || command -v python2)
    if [ -n "$PYTHON_BIN" ]; then
        $PYTHON_BIN -c "
import sys, os
target = '$PKG_PATH'
try:
    with open(target, 'rb') as f:
        magic = f.read(8)
        if magic == b'!<arch>\n':
            while True:
                hdr = f.read(60)
                if len(hdr) < 60: break
                raw_name = hdr[:16].decode('latin1', 'ignore').strip()
                fname = raw_name.rstrip('/')
                try:
                    fsize = int(hdr[48:58].decode('latin1', 'ignore').strip())
                except:
                    break
                f.seek(fsize, 1)
                if fsize % 2 == 1: f.seek(1, 1)
                if fname: print(fname)
except Exception: pass
" 2>/dev/null
    fi
}

extract_ar_container_python() {
    local PKG_PATH="$1"
    local WORK_DIR="$2"
    PYTHON_BIN=$(command -v python3 || command -v python || command -v python2)
    if [ -n "$PYTHON_BIN" ]; then
        $PYTHON_BIN -c "
import os, sys

target = '$PKG_PATH'
work_dir = '$WORK_DIR'

try:
    with open(target, 'rb') as f:
        magic = f.read(8)
        if magic == b'!<arch>\n':
            while True:
                hdr = f.read(60)
                if len(hdr) < 60: break
                raw_name = hdr[:16].decode('latin1', 'ignore').strip()
                fname = raw_name.rstrip('/')
                if fname.startswith('/') or '..' in fname or '\\\\' in fname:
                    fname = os.path.basename(fname)

                try:
                    fsize = int(hdr[48:58].decode('latin1', 'ignore').strip())
                except:
                    break
                fdata = f.read(fsize)
                if fsize % 2 == 1: f.read(1)

                if fname:
                    wpath = os.path.join(work_dir, fname)
                    with open(wpath, 'wb') as wo:
                        wo.write(fdata)
except Exception: pass
" 2>/dev/null
    fi
}

extract_sub_archive() {
    local ARCHIVE_PATH="$1"
    local DEST_DIR="$2"

    mkdir -p "$DEST_DIR"
    case "$ARCHIVE_PATH" in
        *.gz)  tar --no-same-owner --no-same-permissions -xzf "$ARCHIVE_PATH" -C "$DEST_DIR" 2>/dev/null ;;
        *.xz)  tar --no-same-owner --no-same-permissions -xJf "$ARCHIVE_PATH" -C "$DEST_DIR" 2>/dev/null ;;
        *.zst)
            if command -v zstd >/dev/null 2>&1; then
                zstd -d -c "$ARCHIVE_PATH" 2>/dev/null | tar --no-same-owner --no-same-permissions -xf - -C "$DEST_DIR" 2>/dev/null
            else
                echo -e "${R}[WARNING] zstd is missing on system! Skipping .zst extraction.${NC}"
                return 1
            fi
            ;;
        *.bz2) tar --no-same-owner --no-same-permissions -xjf "$ARCHIVE_PATH" -C "$DEST_DIR" 2>/dev/null ;;
        *)     tar --no-same-owner --no-same-permissions -xf "$ARCHIVE_PATH" -C "$DEST_DIR" 2>/dev/null ;;
    esac
}

scan_project_type() {
    local P_DIR="$1"
    local CURR_ARCH="$2"

    echo -e "\n${C}--- Analyzing Project Compatibility ---${NC}"
    local DETECTED_TYPE="Unknown/Generic"

    if find "$P_DIR" -type d -path "*/usr/lib/enigma2/python/Plugins*" 2>/dev/null | grep -q .; then
        DETECTED_TYPE="Enigma2 Plugin"
    elif find "$P_DIR" -type d -path "*/usr/share/enigma2*" 2>/dev/null | grep -q .; then
        DETECTED_TYPE="Enigma2 Skin"
    elif find "$P_DIR" -type f -name "*.ko" 2>/dev/null | grep -q .; then
        DETECTED_TYPE="Kernel Driver / Module"
    elif echo "$P_DIR" | grep -qi "secondstage"; then
        DETECTED_TYPE="Bootloader / System Binary"
    fi

    echo -e "${G}Detected Package Type: ${Y}${DETECTED_TYPE}${NC}"

    if [[ "$DETECTED_TYPE" == "Enigma2 Plugin" || "$DETECTED_TYPE" == "Enigma2 Skin" ]]; then
        if [ "$CURR_ARCH" != "all" ]; then
            echo -e "${Y}[ADVISORY] This project is identified as a ${DETECTED_TYPE}.${NC}"
            echo -e "${Y}           Setting Architecture to 'all' allows universal installation on all STB architectures.${NC}"
        fi
    fi
}

validate_package() {
    local PKG_PATH="$1"
    local PKG_TYPE="$2"

    echo -e "\n${C}==========================================${NC}"
    echo -e "${Y}      Running Package Validation Test     ${NC}"
    echo -e "${C}==========================================${NC}"
    
    if [ ! -f "$PKG_PATH" ]; then
        echo -e "${R}[CRITICAL FAIL] Package file not found!${NC}"
        return 1
    fi

    local TEST_DIR="/tmp/.pkg_val_test"
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"

    echo -e "${B}[1/4] Checking Archive Container Structure ($PKG_TYPE)...${NC}"
    local AR_LIST
    AR_LIST=$(get_ar_members_python "$PKG_PATH")
    
    if [ -z "$AR_LIST" ]; then
        AR_LIST=$(ar t "$PKG_PATH" 2>/dev/null)
    fi

    if [ -z "$AR_LIST" ]; then
        echo -e "${R}[CRITICAL FAIL] Invalid 'ar' container format or corrupted package!${NC}"
        sync
        rm -rf "$TEST_DIR"
        return 1
    fi

    local VALID=1
    echo "$AR_LIST" | grep -q "control.tar" && echo -e "  ${G}✓ control.tar found (Mandatory)${NC}" || { echo -e "  ${R}✗ control.tar missing!${NC}"; VALID=0; }
    echo "$AR_LIST" | grep -q "data.tar" && echo -e "  ${G}✓ data.tar found (Mandatory)${NC}" || { echo -e "  ${R}✗ data.tar missing!${NC}"; VALID=0; }
    
    if [ "$PKG_TYPE" == "deb" ]; then
        echo "$AR_LIST" | grep -q "debian-binary" && echo -e "  ${G}✓ debian-binary found (Mandatory for DEB)${NC}" || { echo -e "  ${R}✗ debian-binary missing for DEB package!${NC}"; VALID=0; }
    else
        if echo "$AR_LIST" | grep -q "debian-binary"; then
            echo -e "  ${G}✓ debian-binary found (Compatible IPK format)${NC}"
        else
            echo -e "  ${Y}! debian-binary missing (OE native format)${NC}"
        fi
    fi

    if [ "$VALID" -eq 0 ]; then
        echo -e "${R}[CRITICAL FAIL] Package Structure Invalid! Aborting validation.${NC}"
        sync
        rm -rf "$TEST_DIR"
        return 1
    fi

    echo -e "${B}[2/4] Testing Container Extraction...${NC}"
    extract_ar_container_python "$PKG_PATH" "$TEST_DIR"

    local CTRL_FILE=$(find "$TEST_DIR" -maxdepth 1 -name "control.tar*" 2>/dev/null | head -n1)
    local DATA_FILE=$(find "$TEST_DIR" -maxdepth 1 -name "data.tar*" 2>/dev/null | head -n1)

    echo -e "${B}[3/4] Validating Control Metadata...${NC}"
    if [ -n "$CTRL_FILE" ] && [ -f "$CTRL_FILE" ]; then
        extract_sub_archive "$CTRL_FILE" "$TEST_DIR/DEBIAN"
        local CTRL_PATH="$TEST_DIR/DEBIAN/control"
        if [ ! -f "$CTRL_PATH" ]; then
            CTRL_PATH="$TEST_DIR/DEBIAN/CONTROL/control"
        fi

        if [ -f "$CTRL_PATH" ]; then
            local CONTROL_OK=1
            grep -q "^Package:" "$CTRL_PATH" || CONTROL_OK=0
            grep -q "^Version:" "$CTRL_PATH" || CONTROL_OK=0
            grep -q "^Architecture:" "$CTRL_PATH" || CONTROL_OK=0

            if [ "$CONTROL_OK" -eq 1 ]; then
                local P_NAME=$(grep -i "^Package:" "$CTRL_PATH" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//')
                local P_VER=$(grep -i "^Version:" "$CTRL_PATH" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//')
                local P_ARCH=$(grep -i "^Architecture:" "$CTRL_PATH" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//')
                echo -e "  ${G}✓ Control Metadata Valid! (Package: $P_NAME | Version: $P_VER | Arch: $P_ARCH)${NC}"
            else
                echo -e "  ${R}[CRITICAL FAIL] Missing mandatory fields (Package, Version, Architecture) in control file!${NC}"
                cd /tmp || true
                sync
                rm -rf "$TEST_DIR"
                return 1
            fi
        else
            echo -e "  ${R}[CRITICAL FAIL] control file extraction failed!${NC}"
            cd /tmp || true
            sync
            rm -rf "$TEST_DIR"
            return 1
        fi
    else
        echo -e "  ${R}[CRITICAL FAIL] control.tar sub-archive missing or corrupted!${NC}"
        cd /tmp || true
        sync
        rm -rf "$TEST_DIR"
        return 1
    fi

    echo -e "${B}[4/4] Validating Payload Data Integrity...${NC}"
    if [ -n "$DATA_FILE" ] && [ -f "$DATA_FILE" ]; then
        extract_sub_archive "$DATA_FILE" "$TEST_DIR/ROOTFS"
        if [ "$(ls -A "$TEST_DIR/ROOTFS" 2>/dev/null)" ]; then
            echo -e "  ${G}✓ Payload Data Extracted Successfully!${NC}"
        else
            echo -e "  ${R}[CRITICAL FAIL] Payload Data Archive is empty!${NC}"
            cd /tmp || true
            sync
            rm -rf "$TEST_DIR"
            return 1
        fi
    else
        echo -e "  ${R}[CRITICAL FAIL] data.tar sub-archive missing or corrupted!${NC}"
        cd /tmp || true
        sync
        rm -rf "$TEST_DIR"
        return 1
    fi

    cd /tmp || return 1
    sync
    rm -rf "$TEST_DIR"
    echo -e "${G}==========================================${NC}"
    echo -e "${G} RESULT: Package Passed Validation Test!  ${NC}"
    echo -e "${G}==========================================${NC}"
    return 0
}

while true; do
    clear
    echo -e "${C}==========================================${NC}"
    echo -e "${Y}   ${APP_NAME} v${APP_VERSION}      ${NC}"
    echo -e "${Y}   (Plugins, Skins & Images Utility)      ${NC}"
    echo -e "${Y}   Developed by: ${DEVELOPER}               ${NC}"
    echo -e "${Y}   GitHub:      ${GITHUB}         ${NC}"
    echo -e "${Y}   Telegram ID: ${TELEGRAM_ID}                 ${NC}"
    echo -e "${Y}   Telegram Channel: ${TELEGRAM_CHANNEL}   ${NC}"
    echo -e "${C}==========================================${NC}"
    echo ""

    while true; do
        echo -e "${B}Select Main Section:${NC}"
        echo -e "${B}  1) Plugins & Skins Manager (.ipk / .deb - /tmp based)${NC}"
        echo -e "${B}  2) Firmware & Images Manager (.nfi, .tar.xz, .tar.gz - Storage based)${NC}"
        echo -e "${B}  3) Exit Program${NC}"
        echo -e -n "${Y}Enter choice (1, 2 or 3): ${NC}"
        read RAW_INPUT
        SECTION_CHOICE=$(echo "$RAW_INPUT" | tr -d '\r\n ')

        if [[ "$SECTION_CHOICE" =~ ^[1-3]$ ]]; then
            break
        else
            echo -e "${R}[ERROR] Invalid input! Please enter only 1, 2 or 3.${NC}\n"
        fi
    done

    if [[ "$SECTION_CHOICE" == "1" ]]; then
        BACK_TO_MAIN=0
        while true; do
            echo -e "\n${B}Plugin & Skin Operations:${NC}"
            echo -e "${B}  1) Build / Recompile Package (.deb / .ipk)${NC}"
            echo -e "${B}  2) Unpack / Extract Package (.deb / .ipk)${NC}"
            echo -e "${B}  b) Back to Main Menu${NC}"
            echo -e -n "${Y}Select action (1, 2 or 'b'): ${NC}"
            read RAW_INPUT
            PKG_ACTION=$(echo "$RAW_INPUT" | tr -d '\r\n ')

            if [[ "$PKG_ACTION" =~ ^[1-2]$ ]]; then
                break
            elif [[ "$PKG_ACTION" =~ ^[bB]$ ]]; then
                BACK_TO_MAIN=1
                break
            else
                echo -e "${R}[ERROR] Invalid input! Enter 1, 2 or 'b'.${NC}"
            fi
        done

        [ "$BACK_TO_MAIN" -eq 1 ] && continue

        if [[ "$PKG_ACTION" == "1" ]]; then
            while true; do
                echo -e "\n${B}Select the output package format:${NC}"
                echo -e "${B}  1) .deb (For Dreambox / DreamOS)${NC}"
                echo -e "${B}  2) .ipk (For OpenATV / OpenPLi / OE2.0)${NC}"
                echo -e "${B}  3) Both (.deb and .ipk)${NC}"
                echo -e "${B}  b) Back to Main Menu${NC}"
                echo -e -n "${Y}Enter choice (1, 2, 3 or 'b'): ${NC}"
                read RAW_INPUT
                FORMAT_CHOICE=$(echo "$RAW_INPUT" | tr -d '\r\n ')

                if [[ "$FORMAT_CHOICE" =~ ^[1-3]$ ]]; then
                    break
                elif [[ "$FORMAT_CHOICE" =~ ^[bB]$ ]]; then
                    BACK_TO_MAIN=1
                    break
                else
                    echo -e "${R}[ERROR] Invalid input! Enter 1, 2, 3 or 'b'.${NC}"
                fi
            done

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            echo -e "\n${Y}Scanning /tmp/ for project root folders containing 'usr'...${NC}"
            PROJ_DIRS=()
            while IFS= read -r -d '' usr_path; do
                PARENT_DIR=$(dirname "$usr_path")
                if [ "$PARENT_DIR" != "/tmp" ]; then
                    if [[ ! " ${PROJ_DIRS[*]} " =~ " ${PARENT_DIR} " ]]; then
                        PROJ_DIRS+=("$PARENT_DIR")
                    fi
                fi
            done < <(find /tmp -type d -name "usr" -print0 2>/dev/null)

            PROJECT_DIR=""
            if [ ${#PROJ_DIRS[@]} -gt 0 ]; then
                while true; do
                    echo -e "${B}Found project folders:${NC}"
                    for idx in "${!PROJ_DIRS[@]}"; do
                        echo -e "  ${C}$((idx+1)))${NC} ${PROJ_DIRS[$idx]}"
                    done
                    echo -e "  ${C}m)${NC} Custom path"
                    echo -e "  ${C}b)${NC} Back to Main Menu"
                    echo -e -n "${Y}Select number, 'm' or 'b': ${NC}"
                    read RAW_INPUT
                    P_DIR_SEL=$(echo "$RAW_INPUT" | tr -d '\r\n ')

                    if [[ "$P_DIR_SEL" =~ ^[0-9]+$ ]] && [ "$P_DIR_SEL" -ge 1 ] && [ "$P_DIR_SEL" -le "${#PROJ_DIRS[@]}" ]; then
                        PROJECT_DIR="${PROJ_DIRS[$((P_DIR_SEL-1))]}"
                        break
                    elif [[ "$P_DIR_SEL" =~ ^[mM]$ ]]; then
                        echo -e -n "${Y}Where is your complete project folder path? (or 'b' to back): ${NC}"
                        read PROJECT_DIR
                        if [[ "$PROJECT_DIR" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                        if [ -d "$PROJECT_DIR" ]; then break; else echo -e "${R}[ERROR] Directory does not exist! Try again.${NC}"; fi
                    elif [[ "$P_DIR_SEL" =~ ^[bB]$ ]]; then
                        BACK_TO_MAIN=1
                        break
                    else
                        echo -e "${R}[ERROR] Invalid selection! Try again.${NC}\n"
                    fi
                done
            else
                while true; do
                    echo -e -n "${Y}Where is your complete project folder path? (or 'b' to back): ${NC}"
                    read PROJECT_DIR
                    if [[ "$PROJECT_DIR" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                    if [ -d "$PROJECT_DIR" ]; then break; else echo -e "${R}[ERROR] Directory does not exist! Try again.${NC}"; fi
                done
            fi

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            CONTROL_FILE=""
            if [ -f "$PROJECT_DIR/DEBIAN/control" ]; then
                CONTROL_FILE="$PROJECT_DIR/DEBIAN/control"
            elif [ -f "$PROJECT_DIR/CONTROL/control" ]; then
                CONTROL_FILE="$PROJECT_DIR/CONTROL/control"
            else
                CONTROL_FILE="$PROJECT_DIR/DEBIAN/control"
            fi

            if [ ! -f "$CONTROL_FILE" ]; then
                echo -e "${Y}control file not found. Creating a new one...${NC}"
                mkdir -p "$PROJECT_DIR/DEBIAN"
                echo -e -n "${Y}Package name (e.g. enigma2-skin-myawesome): ${NC}"
                read RAW_PKG_NAME
                PKG_NAME=$(echo "$RAW_PKG_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9+.-]//g')
                
                echo -e -n "${Y}Version (e.g. 1.5): ${NC}"
                read VERSION
                echo -e -n "${Y}Architecture [all]: ${NC}"
                read ARCH
                [ -z "$ARCH" ] && ARCH="all"

                echo -e -n "${Y}Section [base]: ${NC}"
                read SECTION
                [ -z "$SECTION" ] && SECTION="base"

                echo -e -n "${Y}Priority [optional]: ${NC}"
                read PRIORITY
                [ -z "$PRIORITY" ] && PRIORITY="optional"

                echo -e -n "${Y}Maintainer: ${NC}"
                read MAINTAINER
                echo -e -n "${Y}Description: ${NC}"
                read DESCRIPTION
                echo -e -n "${Y}Depends (Optional dependencies): ${NC}"
                read DEPENDS
                
                {
                    echo "Package: $PKG_NAME"
                    echo "Version: $VERSION"
                    echo "Section: $SECTION"
                    echo "Priority: $PRIORITY"
                    echo "Architecture: $ARCH"
                    echo "Maintainer: $MAINTAINER"
                    echo "Description: $DESCRIPTION"
                    [ -n "$DEPENDS" ] && echo "Depends: $DEPENDS"
                } > "$CONTROL_FILE"
            else
                sed -i 's/\r$//' "$CONTROL_FILE"
                
                CURR_PKG=$(grep -i "^Package:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr -d '\r')
                CURR_VER=$(grep -i "^Version:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr -d '\r')
                CURR_ARCH=$(grep -i "^Architecture:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr -d '\r')
                CURR_SEC=$(grep -i "^Section:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr -d '\r')
                CURR_PRIO=$(grep -i "^Priority:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr -d '\r')
                CURR_MAINT=$(grep -i "^Maintainer:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//')
                CURR_DESC=$(grep -i "^Description:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//')
                CURR_DEP=$(grep -i "^Depends:" "$CONTROL_FILE" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//')

                scan_project_type "$PROJECT_DIR" "$CURR_ARCH"

                echo -e "${Y}Control file found.${NC}"
                while true; do
                    echo -e -n "${B}Do you want to edit the control file? (y/n): ${NC}"
                    read RAW_INPUT
                    EDIT_CTRL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$EDIT_CTRL" =~ ^[yYnN]$ ]]; then break; else echo -e "${R}[ERROR] Type 'y' or 'n'.${NC}"; fi
                done

                if [[ "$EDIT_CTRL" =~ ^[yY]$ ]]; then
                    echo -e "\n${C}Press Enter to keep current value shown in brackets.${NC}"
                    
                    echo -e -n "${Y}Package Name [${CURR_PKG}]: ${NC}"
                    read NEW_PKG
                    if [ -z "$NEW_PKG" ]; then
                        PKG_NAME="$CURR_PKG"
                    else
                        PKG_NAME=$(echo "$NEW_PKG" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9+.-]//g')
                    fi

                    echo -e -n "${Y}Version [${CURR_VER}]: ${NC}"
                    read NEW_VER
                    [ -z "$NEW_VER" ] && VERSION="$CURR_VER" || VERSION="$NEW_VER"

                    echo -e -n "${Y}Architecture [${CURR_ARCH:-all}]: ${NC}"
                    read NEW_ARCH
                    [ -z "$NEW_ARCH" ] && ARCH="${CURR_ARCH:-all}" || ARCH="$NEW_ARCH"

                    echo -e -n "${Y}Section [${CURR_SEC:-base}]: ${NC}"
                    read NEW_SEC
                    [ -z "$NEW_SEC" ] && SECTION="${CURR_SEC:-base}" || SECTION="$NEW_SEC"

                    echo -e -n "${Y}Priority [${CURR_PRIO:-optional}]: ${NC}"
                    read NEW_PRIO
                    [ -z "$NEW_PRIO" ] && PRIORITY="${CURR_PRIO:-optional}" || PRIORITY="$NEW_PRIO"

                    echo -e -n "${Y}Maintainer [${CURR_MAINT}]: ${NC}"
                    read NEW_MAINT
                    [ -z "$NEW_MAINT" ] && MAINTAINER="$CURR_MAINT" || MAINTAINER="$NEW_MAINT"

                    echo -e -n "${Y}Description [${CURR_DESC}]: ${NC}"
                    read NEW_DESC
                    [ -z "$NEW_DESC" ] && DESCRIPTION="$CURR_DESC" || DESCRIPTION="$NEW_DESC"

                    echo -e -n "${Y}Depends [${CURR_DEP}]: ${NC}"
                    read NEW_DEP
                    [ -z "$NEW_DEP" ] && DEPENDS="$CURR_DEP" || DEPENDS="$NEW_DEP"

                    {
                        echo "Package: $PKG_NAME"
                        echo "Version: $VERSION"
                        echo "Section: $SECTION"
                        echo "Priority: $PRIORITY"
                        echo "Architecture: $ARCH"
                        echo "Maintainer: $MAINTAINER"
                        echo "Description: $DESCRIPTION"
                        [ -n "$DEPENDS" ] && echo "Depends: $DEPENDS"
                    } > "$CONTROL_FILE"
                    
                    echo -e "${G}Control file updated with all fields intact!${NC}"
                else
                    PKG_NAME="$CURR_PKG"
                    VERSION="$CURR_VER"
                    ARCH="$CURR_ARCH"
                fi
            fi

            [ -z "$ARCH" ] && ARCH="all"

            echo -e "\n${B}Select Output Filename Mode:${NC}"
            echo -e "${B}  1) Preserve Original Project Folder Name (Recommended for Enigma2 Repack)${NC}"
            echo -e "${B}  2) Standard Debian Convention (package_version_arch)${NC}"
            echo -e -n "${Y}Select choice [1]: ${NC}"
            read RAW_INPUT
            NAMING_MODE=$(echo "$RAW_INPUT" | tr -d '\r\n ')
            [ -z "$NAMING_MODE" ] && NAMING_MODE="1"

            FOLDER_BASE_NAME=$(basename "$PROJECT_DIR")
            CLEAN_ORIG_NAME="${FOLDER_BASE_NAME%_extracted}"

            if [ "$NAMING_MODE" == "1" ]; then
                DEST_DEB="/tmp/${CLEAN_ORIG_NAME}.deb"
                DEST_IPK="/tmp/${CLEAN_ORIG_NAME}.ipk"
            else
                DEST_DEB="/tmp/${PKG_NAME}_${VERSION}_${ARCH}.deb"
                DEST_IPK="/tmp/${PKG_NAME}_${VERSION}_${ARCH}.ipk"
            fi

            while true; do
                echo -e -n "\n${B}Do you want to clean up compiled Python files (.pyc / .pyo)? (y/n) [n]: ${NC}"
                read RAW_INPUT
                CLEAN_PY=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                [ -z "$CLEAN_PY" ] && CLEAN_PY="n"
                if [[ "$CLEAN_PY" =~ ^[yYnN]$ ]]; then break; else echo -e "${R}[ERROR] Type 'y' or 'n'.${NC}"; fi
            done

            if [[ "$CLEAN_PY" =~ ^[yY]$ ]]; then
                echo -e "${Y}Cleaning up .pyc and .pyo files from the project source...${NC}"
                find "$PROJECT_DIR" -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete 2>/dev/null
            else
                echo -e "${G}Preserving all .pyc and .pyo compiled files intact.${NC}"
            fi

            echo -e "${Y}Setting up standard permissions...${NC}"
            find "$PROJECT_DIR" -type d -exec chmod 755 {} +
            if [ -d "$PROJECT_DIR/DEBIAN" ]; then chmod -R 755 "$PROJECT_DIR/DEBIAN"; fi
            if [ -d "$PROJECT_DIR/CONTROL" ]; then chmod -R 755 "$PROJECT_DIR/CONTROL"; fi

            echo -e "${C}------------------------------------------${NC}"

            if [[ "$FORMAT_CHOICE" == "1" || "$FORMAT_CHOICE" == "3" ]]; then
                echo -e "${Y}Building DEB package ($(basename "$DEST_DEB"))...${NC}"
                if command -v dpkg-deb >/dev/null 2>&1; then
                    dpkg-deb --build "$PROJECT_DIR" "$DEST_DEB" >/dev/null 2>&1
                else
                    DEB_BUILD_DIR="/tmp/.deb_build_kia"
                    rm -rf "$DEB_BUILD_DIR"
                    mkdir -p "$DEB_BUILD_DIR/data" "$DEB_BUILD_DIR/control_tmp"
                    echo "2.0" > "$DEB_BUILD_DIR/debian-binary"
                    
                    if [ -d "$PROJECT_DIR/DEBIAN" ]; then
                        cp -a "$PROJECT_DIR/DEBIAN"/. "$DEB_BUILD_DIR/control_tmp/" 2>/dev/null
                    elif [ -d "$PROJECT_DIR/CONTROL" ]; then
                        cp -a "$PROJECT_DIR/CONTROL"/. "$DEB_BUILD_DIR/control_tmp/" 2>/dev/null
                    fi

                    tar --owner=0 --group=0 --numeric-owner -czf "$DEB_BUILD_DIR/control.tar.gz" -C "$DEB_BUILD_DIR/control_tmp" . || { echo -e "${R}[ERROR] Tar control creation failed!${NC}"; continue; }
                    
                    cp -a "$PROJECT_DIR"/. "$DEB_BUILD_DIR/data/" 2>/dev/null
                    rm -rf "$DEB_BUILD_DIR/data/DEBIAN" "$DEB_BUILD_DIR/data/CONTROL"
                    
                    tar --owner=0 --group=0 --numeric-owner -czf "$DEB_BUILD_DIR/data.tar.gz" -C "$DEB_BUILD_DIR/data" . || { echo -e "${R}[ERROR] Tar data creation failed!${NC}"; continue; }
                    
                    cd "$DEB_BUILD_DIR" || continue
                    create_ar_archive "$DEST_DEB" debian-binary control.tar.gz data.tar.gz
                    cd - > /dev/null
                    sync
                    rm -rf "$DEB_BUILD_DIR"
                fi
                
                if [ -f "$DEST_DEB" ]; then
                    echo -e "${G}[SUCCESS] DEB Package saved: $DEST_DEB${NC}"
                    
                    echo -e -n "${B}Do you want to run Package Validation Test on DEB? (y/n): ${NC}"
                    read RAW_INPUT
                    RUN_VAL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$RUN_VAL" =~ ^[yY]$ ]]; then
                        validate_package "$DEST_DEB" "deb"
                    fi
                else
                    echo -e "${R}[ERROR] Failed to build DEB!${NC}"
                fi
            fi

            if [[ "$FORMAT_CHOICE" == "2" || "$FORMAT_CHOICE" == "3" ]]; then
                echo -e "${Y}Building IPK package ($(basename "$DEST_IPK"))...${NC}"
                IPK_BUILD_DIR="/tmp/.ipk_build_kia"
                rm -rf "$IPK_BUILD_DIR"
                mkdir -p "$IPK_BUILD_DIR/data" "$IPK_BUILD_DIR/control_tmp"
                
                echo "2.0" > "$IPK_BUILD_DIR/debian-binary"

                if [ -d "$PROJECT_DIR/DEBIAN" ]; then
                    cp -a "$PROJECT_DIR/DEBIAN"/. "$IPK_BUILD_DIR/control_tmp/" 2>/dev/null
                elif [ -d "$PROJECT_DIR/CONTROL" ]; then
                    cp -a "$PROJECT_DIR/CONTROL"/. "$IPK_BUILD_DIR/control_tmp/" 2>/dev/null
                fi

                tar --owner=0 --group=0 --numeric-owner -czf "$IPK_BUILD_DIR/control.tar.gz" -C "$IPK_BUILD_DIR/control_tmp" . || { echo -e "${R}[ERROR] Tar control creation failed!${NC}"; continue; }
                
                cp -a "$PROJECT_DIR"/. "$IPK_BUILD_DIR/data/" 2>/dev/null
                rm -rf "$IPK_BUILD_DIR/data/DEBIAN" "$IPK_BUILD_DIR/data/CONTROL"
                
                tar --owner=0 --group=0 --numeric-owner -czf "$IPK_BUILD_DIR/data.tar.gz" -C "$IPK_BUILD_DIR/data" . || { echo -e "${R}[ERROR] Tar data creation failed!${NC}"; continue; }
                
                cd "$IPK_BUILD_DIR" || continue
                create_ar_archive "$DEST_IPK" debian-binary control.tar.gz data.tar.gz
                cd - > /dev/null
                sync
                rm -rf "$IPK_BUILD_DIR"
                
                if [ -f "$DEST_IPK" ]; then
                    echo -e "${G}[SUCCESS] IPK Package saved: $DEST_IPK${NC}"

                    echo -e -n "${B}Do you want to run Package Validation Test on IPK? (y/n): ${NC}"
                    read RAW_INPUT
                    RUN_VAL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$RUN_VAL" =~ ^[yY]$ ]]; then
                        validate_package "$DEST_IPK" "ipk"
                    fi
                else
                    echo -e "${R}[ERROR] Failed to build IPK!${NC}"
                fi
            fi

        elif [[ "$PKG_ACTION" == "2" ]]; then
            echo -e "\n${Y}Scanning /tmp/ for .deb and .ipk packages...${NC}"
            PKGS=()
            while IFS= read -r -d '' f; do PKGS+=("$f"); done < <(find /tmp -type f \( -name "*.ipk" -o -name "*.deb" \) -print0 2>/dev/null)

            if [ ${#PKGS[@]} -gt 0 ]; then
                while true; do
                    echo -e "${B}Found packages:${NC}"
                    for idx in "${!PKGS[@]}"; do echo -e "  ${C}$((idx+1)))${NC} ${PKGS[$idx]}"; done
                    echo -e "  ${C}m)${NC} Custom path"
                    echo -e "  ${C}b)${NC} Back to Main Menu"
                    echo -e -n "${Y}Select number, 'm' or 'b': ${NC}"
                    read RAW_INPUT
                    P_SEL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$P_SEL" =~ ^[0-9]+$ ]] && [ "$P_SEL" -ge 1 ] && [ "$P_SEL" -le "${#PKGS[@]}" ]; then
                        TARGET_PKG="${PKGS[$((P_SEL-1))]}"
                        break
                    elif [[ "$P_SEL" =~ ^[mM]$ ]]; then
                        echo -e -n "${Y}Enter package path (or 'b' to back): ${NC}"
                        read TARGET_PKG
                        if [[ "$TARGET_PKG" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                        if [ -f "$TARGET_PKG" ]; then break; else echo -e "${R}[ERROR] File not found!${NC}"; fi
                    elif [[ "$P_SEL" =~ ^[bB]$ ]]; then
                        BACK_TO_MAIN=1
                        break
                    else
                        echo -e "${R}[ERROR] Invalid input! Try again.${NC}\n"
                    fi
                done
            else
                while true; do
                    echo -e -n "${Y}Enter package path (or 'b' to back): ${NC}"
                    read TARGET_PKG
                    if [[ "$TARGET_PKG" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                    if [ -f "$TARGET_PKG" ]; then break; else echo -e "${R}[ERROR] File not found! Try again.${NC}"; fi
                done
            fi

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            P_DIR=$(dirname "$TARGET_PKG")
            F_NAME=$(basename "$TARGET_PKG")
            OUT_P_DIR="${P_DIR}/${F_NAME%.*}_extracted"
            rm -rf "$OUT_P_DIR"
            mkdir -p "$OUT_P_DIR"

            echo -e "${Y}Extracting $F_NAME...${NC}"
            WORK_DIR="/tmp/.unpack_work_kia"
            rm -rf "$WORK_DIR"
            mkdir -p "$WORK_DIR"

            extract_ar_container_python "$TARGET_PKG" "$WORK_DIR"

            if [ ! "$(ls -A "$WORK_DIR" 2>/dev/null)" ]; then
                cd "$WORK_DIR" || true
                ar x "$TARGET_PKG" 2>/dev/null || ar -x "$TARGET_PKG" 2>/dev/null || tar --no-same-owner --no-same-permissions -xzf "$TARGET_PKG" 2>/dev/null || tar --no-same-owner --no-same-permissions -xf "$TARGET_PKG" 2>/dev/null
                cd /tmp || true
            fi

            for f_item in "$WORK_DIR"/*; do
                [ -f "$f_item" ] || continue
                b_item=$(basename "$f_item")
                c_item=$(echo "$b_item" | sed 's/\/*$//')

                if [[ "$c_item" == control.tar* ]]; then
                    extract_sub_archive "$f_item" "$OUT_P_DIR/DEBIAN"
                elif [[ "$c_item" == data.tar* ]]; then
                    extract_sub_archive "$f_item" "$OUT_P_DIR"
                else
                    cp -f "$f_item" "$OUT_P_DIR/$c_item" 2>/dev/null
                fi
            done

            sync
            rm -rf "$WORK_DIR"

            if [ -d "$OUT_P_DIR/DEBIAN" ] && [ ! "$(ls -A "$OUT_P_DIR/DEBIAN" 2>/dev/null)" ]; then
                rm -rf "$OUT_P_DIR/DEBIAN"
            fi

            if [ -d "$OUT_P_DIR" ] && [ "$(ls -A "$OUT_P_DIR")" ]; then
                echo -e "${G}[SUCCESS] Package extracted to: $OUT_P_DIR${NC}"
            else
                echo -e "${R}[ERROR] Extraction failed!${NC}"
            fi
        fi

    elif [[ "$SECTION_CHOICE" == "2" ]]; then
        BACK_TO_MAIN=0
        while true; do
            echo -e "\n${B}Image & Heavy Archive Operations:${NC}"
            echo -e "${B}  1) Unpack Image / Archive (.nfi, .tar.xz, .tar.gz, .tar.bz2)${NC}"
            echo -e "${B}  2) Pack / Compress Folder (.zip, .tar, .tar.gz, .tar.xz, .tar.bz2)${NC}"
            echo -e "${B}  b) Back to Main Menu${NC}"
            echo -e -n "${Y}Select action (1, 2 or 'b'): ${NC}"
            read RAW_INPUT
            IMG_ACTION=$(echo "$RAW_INPUT" | tr -d '\r\n ')

            if [[ "$IMG_ACTION" =~ ^[1-2]$ ]]; then
                break
            elif [[ "$IMG_ACTION" =~ ^[bB]$ ]]; then
                BACK_TO_MAIN=1
                break
            else
                echo -e "${R}[ERROR] Enter 1, 2 or 'b'.${NC}"
            fi
        done

        [ "$BACK_TO_MAIN" -eq 1 ] && continue

        if [[ "$IMG_ACTION" == "1" ]]; then
            echo -e "\n${Y}Scanning /tmp/ and storage locations for images/archives...${NC}"
            IMG_FILES=()
            while IFS= read -r -d '' f; do IMG_FILES+=("$f"); done < <(find /tmp /media -type f \( -name "*.nfi" -o -name "*.tar.xz" -o -name "*.tar.gz" -o -name "*.tar.bz2" -o -name "*.tar" \) -print0 2>/dev/null)

            if [ ${#IMG_FILES[@]} -gt 0 ]; then
                while true; do
                    echo -e "${B}Found image archives:${NC}"
                    for idx in "${!IMG_FILES[@]}"; do echo -e "  ${C}$((idx+1)))${NC} ${IMG_FILES[$idx]}"; done
                    echo -e "  ${C}m)${NC} Custom path"
                    echo -e "  ${C}b)${NC} Back to Main Menu"
                    echo -e -n "${Y}Select number, 'm' or 'b': ${NC}"
                    read RAW_INPUT
                    I_SEL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$I_SEL" =~ ^[0-9]+$ ]] && [ "$I_SEL" -ge 1 ] && [ "$I_SEL" -le "${#IMG_FILES[@]}" ]; then
                        TARGET_IMG="${IMG_FILES[$((I_SEL-1))]}"
                        break
                    elif [[ "$I_SEL" =~ ^[mM]$ ]]; then
                        echo -e -n "${Y}Enter file path (or 'b' to back): ${NC}"
                        read TARGET_IMG
                        if [[ "$TARGET_IMG" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                        if [ -f "$TARGET_IMG" ]; then break; else echo -e "${R}[ERROR] File not found!${NC}"; fi
                    elif [[ "$I_SEL" =~ ^[bB]$ ]]; then
                        BACK_TO_MAIN=1
                        break
                    else
                        echo -e "${R}[ERROR] Invalid input! Try again.${NC}\n"
                    fi
                done
            else
                while true; do
                    echo -e -n "${Y}Enter file path (or 'b' to back): ${NC}"
                    read TARGET_IMG
                    if [[ "$TARGET_IMG" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                    if [ -f "$TARGET_IMG" ]; then break; else echo -e "${R}[ERROR] File not found! Try again.${NC}"; fi
                done
            fi

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            echo -e "\n${Y}Select destination storage for unpacking:${NC}"
            STORAGES=()
            for candidate in /media/hdd /media/usb /media/sdcard /media/mmc /media/* /tmp; do
                if [ -d "$candidate" ] && [ "$candidate" != "/media/autofs" ]; then
                    if [[ ! " ${STORAGES[*]} " =~ " ${candidate} " ]]; then STORAGES+=("$candidate"); fi
                fi
            done

            TARGET_BASE=$(dirname "$TARGET_IMG")
            if [ ${#STORAGES[@]} -gt 0 ]; then
                while true; do
                    for idx in "${!STORAGES[@]}"; do echo -e "  ${C}$((idx+1)))${NC} ${STORAGES[$idx]}"; done
                    echo -e "  ${C}c)${NC} Custom path"
                    echo -e "  ${C}b)${NC} Back to Main Menu"
                    echo -e -n "${Y}Select storage choice: ${NC}"
                    read RAW_INPUT
                    ST_C=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$ST_C" =~ ^[0-9]+$ ]] && [ "$ST_C" -ge 1 ] && [ "$ST_C" -le "${#STORAGES[@]}" ]; then
                        TARGET_BASE="${STORAGES[$((ST_C-1))]}"
                        break
                    elif [[ "$ST_C" =~ ^[cC]$ ]]; then
                        echo -e -n "${Y}Enter path (or 'b' to back): ${NC}"
                        read CUSTOM_PATH
                        if [[ "$CUSTOM_PATH" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                        if [ -n "$CUSTOM_PATH" ]; then mkdir -p "$CUSTOM_PATH"; TARGET_BASE="$CUSTOM_PATH"; break; fi
                    elif [[ "$ST_C" =~ ^[bB]$ ]]; then
                        BACK_TO_MAIN=1
                        break
                    else
                        echo -e "${R}[ERROR] Invalid choice! Try again.${NC}\n"
                    fi
                done
            fi

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            IMG_NAME=$(basename "$TARGET_IMG")
            CLEAN_BASE_NAME="${IMG_NAME%.*}"
            CLEAN_BASE_NAME="${CLEAN_BASE_NAME%.tar}"

            OUT_IMG_DIR="${TARGET_BASE}/${CLEAN_BASE_NAME}_extracted"
            rm -rf "$OUT_IMG_DIR"
            mkdir -p "$OUT_IMG_DIR"

            echo -e "${Y}Extracting $IMG_NAME to $OUT_IMG_DIR...${NC}"

            case "$IMG_NAME" in
                *.tar.xz)
                    if command -v unxz >/dev/null 2>&1; then
                        unxz -c "$TARGET_IMG" | tar --no-same-owner --no-same-permissions -xf - -C "$OUT_IMG_DIR" 2>/dev/null
                    else
                        nice -n 19 tar --no-same-owner --no-same-permissions -xJf "$TARGET_IMG" -C "$OUT_IMG_DIR" 2>/dev/null
                    fi
                    ;;
                *.tar.gz|*.tgz) tar --no-same-owner --no-same-permissions -xzf "$TARGET_IMG" -C "$OUT_IMG_DIR" 2>/dev/null ;;
                *.tar.bz2) tar --no-same-owner --no-same-permissions -xjf "$TARGET_IMG" -C "$OUT_IMG_DIR" 2>/dev/null ;;
                *.tar) tar --no-same-owner --no-same-permissions -xf "$TARGET_IMG" -C "$OUT_IMG_DIR" 2>/dev/null ;;
                *.nfi)
                    if command -v nfidump >/dev/null 2>&1; then
                        nice -n 19 nfidump "$TARGET_IMG" "$OUT_IMG_DIR" >/dev/null 2>&1
                    else
                        echo -e "${R}[ERROR] 'nfidump' tool missing on receiver!${NC}"
                    fi
                    ;;
            esac

            if [ -d "$OUT_IMG_DIR" ] && [ "$(ls -A "$OUT_IMG_DIR")" ]; then
                echo -e "${G}[SUCCESS] Image extracted to: $OUT_IMG_DIR${NC}"

                while true; do
                    echo -e -n "\n${B}Do you want to compress the extracted folder into a .zip archive now? (y/n): ${NC}"
                    read RAW_INPUT
                    DO_ZIP=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$DO_ZIP" =~ ^[yYnN]$ ]]; then break; else echo -e "${R}[ERROR] Type 'y' or 'n'.${NC}"; fi
                done

                if [[ "$DO_ZIP" =~ ^[yY]$ ]]; then
                    if command -v zip >/dev/null 2>&1; then
                        while true; do
                            echo -e "\n${Y}Select destination storage to save the .zip file:${NC}"
                            ZIP_DEST_BASE=$(dirname "$OUT_IMG_DIR")
                            if [ ${#STORAGES[@]} -gt 0 ]; then
                                for idx in "${!STORAGES[@]}"; do echo -e "  ${C}$((idx+1)))${NC} ${STORAGES[$idx]}"; done
                                echo -e "  ${C}c)${NC} Custom path"
                                echo -e -n "${Y}Select storage for ZIP: ${NC}"
                                read RAW_INPUT
                                Z_ST_C=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                                if [[ "$Z_ST_C" =~ ^[0-9]+$ ]] && [ "$Z_ST_C" -ge 1 ] && [ "$Z_ST_C" -le "${#STORAGES[@]}" ]; then
                                    ZIP_DEST_BASE="${STORAGES[$((Z_ST_C-1))]}"
                                    break
                                elif [[ "$Z_ST_C" =~ ^[cC]$ ]]; then
                                    echo -e -n "${Y}Enter path: ${NC}"
                                    read Z_CUSTOM_PATH
                                    if [ -n "$Z_CUSTOM_PATH" ]; then mkdir -p "$Z_CUSTOM_PATH"; ZIP_DEST_BASE="$Z_CUSTOM_PATH"; break; fi
                                else
                                    echo -e "${R}[ERROR] Invalid choice! Try again.${NC}\n"
                                fi
                            fi
                        done

                        ZIP_FILE="${ZIP_DEST_BASE}/${CLEAN_BASE_NAME}.zip"

                        echo -e "${Y}Compressing Linux rootfs contents to ZIP format at $ZIP_FILE... Please wait...${NC}"
                        cd "$OUT_IMG_DIR" || true
                        zip -r -q "$ZIP_FILE" .
                        cd /tmp || true

                        if [ -f "$ZIP_FILE" ]; then
                            echo -e "${G}[SUCCESS] ZIP Archive created: $ZIP_FILE${NC}"
                        else
                            echo -e "${R}[ERROR] Compression failed! Check free disk space.${NC}"
                        fi
                    else
                        echo -e "${R}[ERROR] 'zip' command is missing on this receiver!${NC}"
                    fi
                fi

                while true; do
                    echo -e -n "\n${B}Do you want to delete the extracted source folder ($OUT_IMG_DIR)? (y/n): ${NC}"
                    read RAW_INPUT
                    ASK_UNPACK_DEL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$ASK_UNPACK_DEL" =~ ^[yYnN]$ ]]; then break; else echo -e "${R}[ERROR] Type 'y' or 'n'.${NC}"; fi
                done

                if [[ "$ASK_UNPACK_DEL" =~ ^[yY]$ ]]; then
                    echo -e -n "${R}To confirm deletion, type 'del': ${NC}"
                    read RAW_INPUT
                    DEL_UNPACK_CONFIRM=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$DEL_UNPACK_CONFIRM" =~ ^(del|DEL)$ ]]; then
                        if [ -d "$OUT_IMG_DIR" ]; then
                            echo -e "${Y}Unlocking permissions and deleting $OUT_IMG_DIR...${NC}"
                            chmod -R 777 "$OUT_IMG_DIR" 2>/dev/null
                            rm -rf -- "$OUT_IMG_DIR"
                            sync
                            
                            if [ ! -d "$OUT_IMG_DIR" ]; then
                                echo -e "${G}[SUCCESS] Extracted folder successfully deleted!${NC}"
                            else
                                echo -e "${R}[ERROR] Could not delete folder! Check if directory is mounted read-only.${NC}"
                            fi
                        fi
                    else
                        echo -e "${Y}Confirmation failed. Folder was NOT deleted.${NC}"
                    fi
                fi
            else
                echo -e "${R}[ERROR] Image extraction failed!${NC}"
            fi

        elif [[ "$IMG_ACTION" == "2" ]]; then
            echo -e "\n${Y}Scanning /tmp/ and storage locations for directories...${NC}"
            
            DIRS=()
            while IFS= read -r -d '' d; do
                if [ "$d" != "/tmp" ] && [ "$d" != "/media" ]; then
                    DIRS+=("$d")
                fi
            done < <(find /tmp /media -maxdepth 3 -type d \( -name "*_extracted*" -o -name "*rootfs*" -o -name "*image*" -o -name "*decomp*" \) -print0 2>/dev/null)

            RAW_COMP_DIR=""

            if [ ${#DIRS[@]} -gt 0 ]; then
                while true; do
                    echo -e "${B}Found directories:${NC}"
                    for idx in "${!DIRS[@]}"; do echo -e "  ${C}$((idx+1)))${NC} ${DIRS[$idx]}"
                    done
                    echo -e "  ${C}m)${NC} Custom path"
                    echo -e "  ${C}b)${NC} Back to Main Menu"
                    echo -e -n "${Y}Select directory number, 'm' or 'b': ${NC}"
                    read RAW_INPUT
                    D_SEL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$D_SEL" =~ ^[0-9]+$ ]] && [ "$D_SEL" -ge 1 ] && [ "$D_SEL" -le "${#DIRS[@]}" ]; then
                        RAW_COMP_DIR="${DIRS[$((D_SEL-1))]}"
                        break
                    elif [[ "$D_SEL" =~ ^[mM]$ ]]; then
                        echo -e -n "${Y}Enter full directory path (or 'b' to back): ${NC}"
                        read RAW_COMP_DIR
                        if [[ "$RAW_COMP_DIR" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                        if [ -d "$RAW_COMP_DIR" ]; then break; else echo -e "${R}[ERROR] Directory not found!${NC}"; fi
                    elif [[ "$D_SEL" =~ ^[bB]$ ]]; then
                        BACK_TO_MAIN=1
                        break
                    else
                        echo -e "${R}[ERROR] Invalid input! Try again.${NC}\n"
                    fi
                done
            else
                while true; do
                    echo -e -n "${Y}Enter full directory path to compress (or 'b' to back): ${NC}"
                    read RAW_COMP_DIR
                    if [[ "$RAW_COMP_DIR" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                    if [ -d "$RAW_COMP_DIR" ]; then break; else echo -e "${R}[ERROR] Directory not found! Try again.${NC}"; fi
                done
            fi

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            if command -v readlink >/dev/null 2>&1; then
                COMP_DIR=$(readlink -f "$RAW_COMP_DIR")
            else
                COMP_DIR="$RAW_COMP_DIR"
            fi

            while true; do
                echo -e "\n${B}Select archive format:${NC}"
                echo -e "${B}  1) .zip${NC}"
                echo -e "${B}  2) .tar${NC}"
                echo -e "${B}  3) .tar.gz${NC}"
                echo -e "${B}  4) .tar.xz${NC}"
                echo -e "${B}  5) .tar.bz2${NC}"
                echo -e "${B}  b) Back to Main Menu${NC}"
                echo -e -n "${Y}Select choice (1-5 or 'b'): ${NC}"
                read RAW_INPUT
                C_FMT=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                if [[ "$C_FMT" =~ ^[1-5]$ ]]; then
                    break
                elif [[ "$C_FMT" =~ ^[bB]$ ]]; then
                    BACK_TO_MAIN=1
                    break
                else
                    echo -e "${R}[ERROR] Enter a number from 1 to 5 or 'b'.${NC}";
                fi
            done

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            echo -e "\n${Y}Select destination storage for saving the compressed file:${NC}"
            STORAGES=()
            for candidate in /media/hdd /media/usb /media/sdcard /media/mmc /media/* /tmp; do
                if [ -d "$candidate" ] && [ "$candidate" != "/media/autofs" ]; then
                    if [[ ! " ${STORAGES[*]} " =~ " ${candidate} " ]]; then STORAGES+=("$candidate"); fi
                fi
            done

            SAVE_DEST_BASE=$(dirname "$COMP_DIR")
            if [ ${#STORAGES[@]} -gt 0 ]; then
                while true; do
                    for idx in "${!STORAGES[@]}"; do echo -e "  ${C}$((idx+1)))${NC} ${STORAGES[$idx]}"; done
                    echo -e "  ${C}c)${NC} Custom path"
                    echo -e "  ${C}b)${NC} Back to Main Menu"
                    echo -e -n "${Y}Select storage choice: ${NC}"
                    read RAW_INPUT
                    SAVE_ST_C=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                    if [[ "$SAVE_ST_C" =~ ^[0-9]+$ ]] && [ "$SAVE_ST_C" -ge 1 ] && [ "$SAVE_ST_C" -le "${#STORAGES[@]}" ]; then
                        SAVE_DEST_BASE="${STORAGES[$((SAVE_ST_C-1))]}"
                        break
                    elif [[ "$SAVE_ST_C" =~ ^[cC]$ ]]; then
                        echo -e -n "${Y}Enter path (or 'b' to back): ${NC}"
                        read S_CUSTOM_PATH
                        if [[ "$S_CUSTOM_PATH" =~ ^[bB]$ ]]; then BACK_TO_MAIN=1; break; fi
                        if [ -n "$S_CUSTOM_PATH" ]; then mkdir -p "$S_CUSTOM_PATH"; SAVE_DEST_BASE="$S_CUSTOM_PATH"; break; fi
                    elif [[ "$SAVE_ST_C" =~ ^[bB]$ ]]; then
                        BACK_TO_MAIN=1
                        break
                    else
                        echo -e "${R}[ERROR] Invalid input! Try again.${NC}\n"
                    fi
                done
            fi

            [ "$BACK_TO_MAIN" -eq 1 ] && continue

            B_NAME=$(basename "$COMP_DIR")
            NAME_NO_EXT="${B_NAME%_extracted}"
            NAME_NO_TAR="${NAME_NO_EXT%.tar}"

            while true; do
                echo -e -n "\n${B}Do you want to clean up temporary files (.pyc, .pyo, /tmp/*) before packing? (y/n) [n]: ${NC}"
                read RAW_INPUT
                CLEAN_IMG_CHOICE=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                [ -z "$CLEAN_IMG_CHOICE" ] && CLEAN_IMG_CHOICE="n"
                if [[ "$CLEAN_IMG_CHOICE" =~ ^[yYnN]$ ]]; then break; else echo -e "${R}[ERROR] Type 'y' or 'n'.${NC}"; fi
            done

            if [[ "$CLEAN_IMG_CHOICE" =~ ^[yY]$ ]]; then
                echo -e "${Y}Cleaning up temporary and cache files...${NC}"
                find "$COMP_DIR" -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete 2>/dev/null
                if [ -d "$COMP_DIR/tmp" ]; then
                    rm -rf "$COMP_DIR/tmp/"* 2>/dev/null
                fi
            else
                echo -e "${G}Preserving all folder contents intact.${NC}"
            fi

            cd "$COMP_DIR" || true

            PACK_OK=0
            TARGET_FILE=""

            case "$C_FMT" in
                1)
                    TARGET_FILE="${SAVE_DEST_BASE}/${NAME_NO_EXT}.zip"
                    if command -v zip >/dev/null 2>&1; then
                        zip -r -q "$TARGET_FILE" . && PACK_OK=1
                    else
                        echo -e "${R}[ERROR] 'zip' is not installed!${NC}"
                    fi
                    ;;
                2)
                    TARGET_FILE="${SAVE_DEST_BASE}/${NAME_NO_TAR}.tar"
                    tar --owner=0 --group=0 --numeric-owner -cf "$TARGET_FILE" . && PACK_OK=1
                    ;;
                3)
                    TARGET_FILE="${SAVE_DEST_BASE}/${NAME_NO_TAR}.tar.gz"
                    tar --owner=0 --group=0 --numeric-owner -czf "$TARGET_FILE" . && PACK_OK=1
                    ;;
                4)
                    TARGET_FILE="${SAVE_DEST_BASE}/${NAME_NO_TAR}.tar.xz"
                    if command -v xz >/dev/null 2>&1; then
                        nice -n 19 tar --owner=0 --group=0 --numeric-owner -cJf "$TARGET_FILE" . && PACK_OK=1
                    else
                        echo -e "${R}[ERROR] 'xz' is not installed!${NC}"
                    fi
                    ;;
                5)
                    TARGET_FILE="${SAVE_DEST_BASE}/${NAME_NO_TAR}.tar.bz2"
                    if command -v bzip2 >/dev/null 2>&1; then
                        tar --owner=0 --group=0 --numeric-owner -cjf "$TARGET_FILE" . && PACK_OK=1
                    else
                        echo -e "${R}[ERROR] 'bzip2' is not installed!${NC}"
                    fi
                    ;;
            esac

            cd /tmp || true

            if [ "$PACK_OK" -eq 1 ] && [ -f "$TARGET_FILE" ]; then
                echo -e "${G}[SUCCESS] File saved: ${TARGET_FILE}${NC}"
            else
                echo -e "${R}[ERROR] Packing failed or ended unexpectedly!${NC}"
                if [ -n "$TARGET_FILE" ] && [ -f "$TARGET_FILE" ]; then
                    echo -e "${Y}Removing incomplete/corrupted file: $TARGET_FILE${NC}"
                    rm -f "$TARGET_FILE"
                fi
            fi

            while true; do
                echo -e -n "\n${B}Do you want to delete the source extracted folder ($COMP_DIR)? (y/n): ${NC}"
                read RAW_INPUT
                ASK_DEL=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                if [[ "$ASK_DEL" =~ ^[yYnN]$ ]]; then break; else echo -e "${R}[ERROR] Type 'y' or 'n'.${NC}"; fi
            done

            if [[ "$ASK_DEL" =~ ^[yY]$ ]]; then
                echo -e -n "${R}To confirm deletion, type 'del': ${NC}"
                read RAW_INPUT
                DEL_CONFIRM=$(echo "$RAW_INPUT" | tr -d '\r\n ')
                if [[ "$DEL_CONFIRM" =~ ^(del|DEL)$ ]]; then
                    if [ -d "$COMP_DIR" ]; then
                        echo -e "${Y}Unlocking permissions and deleting $COMP_DIR...${NC}"
                        chmod -R 777 "$COMP_DIR" 2>/dev/null
                        rm -rf -- "$COMP_DIR"
                        sync
                        
                        if [ ! -d "$COMP_DIR" ]; then
                            echo -e "${G}[SUCCESS] Folder successfully deleted!${NC}"
                        else
                            echo -e "${R}[ERROR] Could not delete folder! Check if directory is mounted read-only.${NC}"
                        fi
                    else
                        echo -e "${R}[ERROR] Folder $COMP_DIR was not found or already deleted.${NC}"
                    fi
                else
                    echo -e "${Y}Confirmation failed. Folder was NOT deleted.${NC}"
                fi
            fi
        fi

    elif [[ "$SECTION_CHOICE" == "3" ]]; then
        echo -e "${G}Exiting ${APP_NAME}. Goodbye!${NC}"
        break
    fi

    echo -e "\n${C}------------------------------------------${NC}"
    echo -e -n "${Y}Press Enter to return to main menu, or 'q' to quit: ${NC}"
    read RAW_INPUT
    NEXT_STEP=$(echo "$RAW_INPUT" | tr -d '\r\n ')
    if [[ "$NEXT_STEP" == "q" || "$NEXT_STEP" == "Q" ]]; then
        echo -e "${G}Goodbye!${NC}"
        break
    fi
done
