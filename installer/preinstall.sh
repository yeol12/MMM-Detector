#!/bin/bash
# +--------------------------------+
# | npm pre install                |
# | Rev 1.0.0                      |
# +--------------------------------+

# get the installer directory
Installer_get_current_dir () {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  done
  echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

Installer_dir="$(Installer_get_current_dir)"

# move to installler directory
cd "$Installer_dir"

source utils.sh
CurrentNpmVer="$(npm -v)"
MinRequireNpmVer="6.14.15"
MaxRequireNpmVer="7.0.0"
CurrentNodeVer="$(node -v)"
RequireNodeVer="v12.0.0"

# del last log
rm installer.log 2>/dev/null

# logs in installer.log file
Installer_log

# Let's start !
Installer_info "Welcome to MMM-Detector installer!"

echo

# Check not run as root
if [ "$EUID" -eq 0 ]; then
  Installer_error "npm install must not be used as root"
  exit 1
fi

# Check platform compatibility
Installer_info "Checking OS..."
Installer_checkOS
if  [ "$platform" == "osx" ]; then
  Installer_error "OS Detected: $OSTYPE ($os_name $os_version $arch)"
  Installer_error "You need to do Manual Install"
  exit 0
else
  Installer_success "OS Detected: $OSTYPE ($os_name $os_version $arch)"
fi

echo
Installer_info "NPM Version testing:"
 if [ "$(printf '%s\n' "$MinRequireNpmVer" "$CurrentNpmVer" | sort -V | head -n1)" = "$MinRequireNpmVer" ]; then 
        Installer_warning "Require: >= ${MinRequireNpmVer} < ${MaxRequireNpmVer}"
        if [[ "$(printf '%s\n' "$MaxRequireNpmVer" "$CurrentNpmVer" | sort -V | head -n1)" < "$MaxRequireNpmVer" ]]; then
          Installer_success "Current: ${CurrentNpmVer} ✓"
        else
          Installer_error "Current: ${CurrentNpmVer} 𐄂"
          Installer_error "Failed: incorrect version!"
          echo
          exit 255
        fi
 else
        Installer_warning "Require: ${RequireNpmVer}"
        Installer_error "Current: ${CurrentNpmVer} 𐄂"
        Installer_error "Failed: incorrect version!"
        exit 255
 fi
echo
Installer_info "NODE Version testing:"
 if [ "$(printf '%s\n' "$RequireNodeVer" "$CurrentNodeVer" | sort -V | head -n1)" = "$RequireNodeVer" ]; then 
        Installer_warning "Require: >= ${RequireNodeVer}"
        Installer_success "Current: ${CurrentNodeVer} ✓"
 else
        Installer_warning "Require: >= ${RequireNodeVer}"
        Installer_error "Current: ${CurrentNodeVer} 𐄂"
        Installer_error "Failed: incorrect version!"
        exit 255
 fi
echo
Installer_success "Passed: perfect!"
echo

# check dependencies
dependencies=(libmagic-dev libatlas-base-dev sox libsox-fmt-all build-essential)
Installer_info "Checking all dependencies..."
Installer_check_dependencies
Installer_success "All Dependencies needed are installed !"

# switch branch
Installer_info "Installing Sources..."
git checkout -f master 2>/dev/null || Installer_error "Installing Error !"
git pull 2>/dev/null

echo
Installer_info "Installing npm libraries..."
npm prune
