#!/usr/bin/env sh

# Drive to install Arch Linux.
# DUALBOOT IS NOT SUPPORTED!
DRIVE='/dev/sda'

# Set partitioning method to auto/manual
PARTITIONING='auto'

# Set boot type on efi/legacy
# if blank automaticly detect
BOOT_TYPE='efi'

# Partitions (only in use if PARTITIONING is set to auto);
# HOME (set 0 or leave blank to not create home partition).
HOME_SIZE='0' #GB (recommend 10GB)

# VAR (set 0 or leave blank to not create var partition).
VAR_SIZE='0' #GB (recommend 5GB)

# SWAP (set 0 or leave blank to not create swap partition).
SWAP_SIZE='0' #GB (recommend square root of ram)

# EFI (set 0 or leave blank to not create efi partition).
# is used if the system is to be installed on "uefi"
EFI_SIZE='512' #MB (recommend (or if not set) 512MB)

# System language.
LANG='en_US'

# System timezone (leave blank to be prompted).
TIMEZONE='Europe/Warsaw'

# System hostname (leave blank to be prompted).
HOSTNAME='Skynet'

# Root password (leave blank to be prompted).
ROOT_PASSWORD=''

# Main user to create (by default, added to wheel group, and others).
USER_NAME='eryk'

# The main user's password (leave blank to be prompted).
USER_PASSWORD=$ROOT_PASSWORD

# Choose DE.
#DE='kde'
DE='gnome'

# Choose keyboard layout (using localectl for this, see below or here: https://man.archlinux.org/man/localectl.1.en).
VCONSOLE_KEYMAP='us'
X11_KEYMAP_LAYOUT='us'
X11_KEYMAP_VARIANT='us'
X11_KEYMAP_MODEL='pc104'

# For my laptop
#VCONSOLE_KEYMAP='uk'
#X11_KEYMAP_LAYOUT='gb'
#X11_KEYMAP_VARIANT='pl'
#X11_KEYMAP_MODEL='pc105'

# Choose CPU microcode.
UCODE='intel-ucode'
#UCODE='amd-ucode'

# List of kernels to install.
KERNEL='linux-zen linux-zen-headers linux-lts linux-lts-headers'

# Choose your video driver.
# For Intel
#VIDEO_DRIVER="i915"

# For (f*cking) Nvidia 
#VIDEO_DRIVER="nouveau"
# or
#VIDEO_DRIVER="nvidia"  # remember to install kernel headers

# For ATI
#VIDEO_DRIVER="radeon"

# For generic stuff
VIDEO_DRIVER="vesa"

# virtualbox guest utils
#VIDEO_DRIVER="vbox"

# Choose mirrors.
REFLECTOR_COUNTRY="Poland"

# Choose aur helper.
AUR_HELPER="paru"
#AUR_HELPER="yay"

# Choose bootloader.
BOOTLOADER="grub"
#BOOTLOADER="refind"  # idk if it works :P

# Grub theme (from https://github.com/vinceliuice/grub2-themes).
GRUB_THEME="vimix"
GRUB_THEME_ICONS="white"
GRUB_THEME_RES="1080p"

# Choose hosts file type or leave blank for "default" hosts.
# Credit to https://github.com/StevenBlack/hosts
# Hosts file type:
# unified (adware + malware)
# fakenews
# gambling
# porn
# social
# fakenews-gambling
# fakenews-porn
# fakenews-social
# gambling-porn
# gambling-social
# porn-social
# fakenews-gambling-porn
# fakenews-gambling-social
# fakenews-porn-social
# gambling-porn-social
# fakenews-gambling-porn-social
HOSTS_FILE_TYPE=""

# Customize to install other packages.
install_packages() {

	# General utilities
	packages="reflector htop rfkill sudo unrar unzip wget zip xdg-user-dirs exa fish git update-grub"

	# Sound
	packages="$packages alsa-utils pulseaudio pulseaudio-alsa"

	# Network
	packages="$packages networkmanager"
	services="$services NetworkManager"

	# Fonts
	packages="$packages ttf-dejavu noto-fonts noto-fonts-emoji ttf-hack ttf-droid"
	
	# Theme
	packages="$packages materia-gtk-theme papirus-icon-theme"
	
	# Pamac
	#packages="$packages pamac-aur"
	
	# Browser
	packages="$packages firefox"

	# Terminal programs
	packages="$packages micro xclip wl-clipboard neofetch"

	# Multimedia
	#packages="$packages vlc"

	# Communicators
	packages="$packages discord"

	# For laptops
	packages="$packages xf86-input-libinput auto-cpufreq"
	services="$services auto-cpufreq"

	# Bluetooth
	packages="$packages bluez bluez-utils pulseaudio-bluetooth"
	services="$services bluetooth"

	# Video drivers
	if [ "$VIDEO_DRIVER" = "i915" ]; then
		packages="$packages xf86-video-intel libva-intel-driver"
	elif [ "$VIDEO_DRIVER" = "nouveau" ]; then
		packages="$packages xf86-video-nouveau"
	elif [ "$VIDEO_DRIVER" = "nvidia" ]; then
		packages="$packages nvidia-dkms nvidia-utils nvidia-settings"
	elif [ "$VIDEO_DRIVER" = "radeon" ]; then
		packages="$packages xf86-video-ati"
	elif [ "$VIDEO_DRIVER" = "vesa" ]; then
		packages="$packages xf86-video-vesa"
	elif [ "$VIDEO_DRIVER" = "vbox" ]; then
		packages="$packages virtualbox-guest-utils"
	fi
	# DE
	if [ "$DE" = "kde" ]; then
		packages="$packages xorg plasma konsole dolphin gwenview okular ark archlinux-wallpaper sddm kwalletmanager"
		services="$services sddm"
		delete="plasma-vault plasma-thunderbolt oxygen discover"
	elif [ "$DE" = "gnome" ]; then
		packages="$packages xorg gnome gnome-tweaks dconf-editor gdm-tools-git archlinux-wallpaper"
		delete="epiphany gnome-books gnome-boxes gnome-calendar gnome-clocks gnome-software gnome-characters gnome-font-viewer gnome-documents yelp simple-scan gnome-weather gnome-user-docs gnome-contacts gnome-maps"
		services="$services gdm"
	fi
	
	if [ $AUR_HELPER = "paru" ]; then
		cat >/etc/paru.conf <<EOF
#
# $PARU_CONF
# /etc/paru.conf
# ~/.config/paru/paru.conf
#
# See the paru.conf(5) manpage for options

#
# GENERAL OPTIONS
#
[options]
PgpFetch
Devel
Provides
DevelSuffixes = -git -cvs -svn -bzr -darcs -always
#BottomUp
RemoveMake
SudoLoop
UseAsk
#CombinedUpgrade
CleanAfter
UpgradeMenu
#NewsOnUpgrade
SkipReview

#LocalRepo
#Chroot
#Sign
#SignDb

#
# Binary OPTIONS
#
#[bin]
#FileManager = vifm
#MFlags = --skippgpcheck
#Sudo = doas
EOF
	fi
	
	# Install
	sudo -u $USER_NAME $AUR_HELPER --noconfirm -S $packages
	# Delete
	if [ -e "$delete" ]; then
		echo "Removing unnecessary packages"
		pacman --noconfirm -Rns $delete
	fi
	
	# Configure bluetooth
	#sudo -u $USER_NAME sed -i 's/#AutoEnable=false/AutoEnable=false/g' /etc/bluetooth/main.conf

	echo "Enabling systemd services"
	systemctl enable systemd-localed $services

	echo "Setting default shell to fish"
	chsh -s /usr/bin/fish $USER_NAME
	
	# Install Grub theme (from https://github.com/vinceliuice/grub2-themes)
	if [ "$BOOTLOADER" = "grub" ]; then
		echo "Instaling Grub theme"
		git clone https://github.com/vinceliuice/grub2-themes.git /home/$USER_NAME/grub-themes
		sudo -u $USER_NAME chown $USER_NAME:$USER_NAME /home/$USER_NAME/grub-themes
		/home/$USER_NAME/grub-themes/install.sh -b -t $GRUB_THEME -s $GRUB_THEME_RES -i $GRUB_THEME_ICONS
	fi
	
	cat >/etc/environment <<EOF
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland
EOF
	if [ "$DE" = "gnome" ]; then
		echo "QT_QPA_PLATFORMTHEME=gnome" >> /etc/environment
	fi
}

#=======
# SETUP
#=======
greeter() {	
	clear
	cat <<EOF

       /\\
      /  \\       Arch Linux install script for very lazy people ;)
     /\\   \\      Written by Cherrry9 (https://github.com/Cherrry9)
    /  ..  \\     Forked by Smuger12 (https://github.com/Smuger12)
   /  '  '  \\
  / ..'  '.. \\
 /_\`        \`_\\

EOF
}

network() {
	ping -c 1 archlinux.org >/dev/null || {
		echo "Can't connect to the Internet!"
		exit 1
	}
	timedatectl set-ntp true
}

detect_boot_type() {
	BOOT_TYPE=$(ls /sys/firmware/efi/efivars 2>/dev/null)
	[ "$BOOT_TYPE" ] &&
		BOOT_TYPE="efi" ||
		BOOT_TYPE="legacy"
}

format_and_mount() {
	# format && mount
	mkdir -p /mnt
	yes | mkfs.ext4 -L ROOT "$root"
	mount "$root" /mnt

	[ "$efi" ] && {
		mkdir -p /mnt/boot/efi
		mkfs.fat -F32 -n EFI "$efi"
		mount "$efi" /mnt/boot/efi
	}

	[ "$swap" ] && {
		mkswap -L SWAP "$swap"
		swapon "$swap"
	}

	[ "$home" ] && {
		mkdir -p /mnt/home
		yes | mkfs.ext4 -L HOME "$home"
		mount "$home" /mnt/home
	}

	[ "$var" ] && {
		mkdir -p /mnt/var
		yes | mkfs.ext4 -L VAR "$var"
		mount "$var" /mnt/var
	}
}

auto_partition() {
	# calc end
	case $(echo "$EFI_SIZE > 0" | bc) in
	1) efi_end="$((EFI_SIZE + 1))" ;;
	*) efi_end=513 ;;
	esac

	case $(echo "$SWAP_SIZE > 0" | bc) in
	1)
		swap_end=$(echo "$SWAP_SIZE * 1024 + $efi_end" | bc)
		swap=0
		;;
	*) swap_end="$efi_end" ;;
	esac

	case $(echo "$HOME_SIZE > 0" | bc) in
	1)
		home_end=$(echo "$HOME_SIZE * 1024 + $swap_end" | bc)
		home=0
		;;
	*) home_end="$swap_end" ;;
	esac

	case $(echo "$VAR_SIZE > 0" | bc) in
	1)
		var_end=$(echo "$VAR_SIZE * 1024 + $home_end" | bc)
		var=0
		;;
	*) var_end="$home_end" ;;
	esac

	# label mbr/gpt
	next_part=1
	if [ "$BOOT_TYPE" = 'efi' ]; then
		echo "Detected EFI boot"
		parted -s "$DRIVE" mklabel gpt
	else
		echo "Detected legacy boot"
		parted -s "$DRIVE" mklabel msdos
	fi

	# efi
	[ "$BOOT_TYPE" = 'efi' ] && {
		parted -s "$DRIVE" select "$DRIVE" mkpart primary fat32 1MiB "${efi_end}MiB"
		efi="${DRIVE}$next_part"
		next_part=$((next_part + 1))
	}

	# swap
	[ "$swap" ] && {
		parted -s "$DRIVE" select "$DRIVE" mkpart primary linux-swap "${efi_end}MiB" "${swap_end}MiB"
		swap="${DRIVE}$next_part"
		next_part=$((next_part + 1))
	}

	# home
	[ "$home" ] && {
		parted -s "$DRIVE" select "$DRIVE" mkpart primary ext4 "${swap_end}MiB" "${home_end}MiB"
		home="${DRIVE}$next_part"
		next_part=$((next_part + 1))
	}

	# var
	[ "$var" ] && {
		parted -s "$DRIVE" select "$DRIVE" mkpart primary ext4 "${home_end}MiB" "${var_end}MiB"
		var="${DRIVE}$next_part"
		next_part=$((next_part + 1))
	}

	# root
	parted -s "$DRIVE" select "$DRIVE" mkpart primary ext4 "${var_end}MiB" 100%
	root="${DRIVE}$next_part"
}

select_disk() {
	DISK=''
	SIZE=''
	type="$1"

	# pseudo select loop
	while [ ! "$DISK" ] && [ -s "$list" ]; do
		i=0
		echo
		while read -r line; do
			i=$((i + 1))
			echo "$i) $line"
		done <"$list"

		if [ "$type" != "root" ]; then
			i=$((i + 1))
			echo "$i) Don't create $type partitions."
			refuse="$i"
		fi

		printf "\nEnter disk number for %s: " "$type"
		read -r choice

		if [ "$refuse" ] && [ "$refuse" = "$choice" ]; then
			DISK=''
			break
		elif [ "$choice" ]; then
			DISK=$(sed -n "${choice}p" "$list" | awk '{print $1}')
			SIZE=$(sed -n "${choice}p" "$list" | awk '{print $2}')
			sed -i "${choice}d" "$list"
		fi
	done
}

manual_partition() {
	while [ ! "$next" ] || [ "$next" != "y" ]; do
		# part
		if [ "$BOOT_TYPE" = 'efi' ]; then
			cat <<EOF

Please create root partition (/) and efi partition (/boot/efi), optional home (/home), var (/var) or swap

Example:
# label
mklabel gpt
# swap
mkpart primary linux-swap 1MiB 2G
# home
mkpart primary ext4 2G 12G
# root
mkpart primary ext4 12G 100%

If finished, enter - "quit"

EOF
		else
			cat <<EOF

Please create root partition (/) and optional home (/home), var (/var) or swap

Example:
# label
mklabel msdos
# swap
mkpart primary linux-swap 1MiB 2G
# home
mkpart primary ext4 2G 12G
# root
mkpart primary ext4 12G 100%

If finished, enter - "quit"

EOF
		fi

		parted "$DRIVE"

		# select disks
		list="/disks.list"
		lsblk -nrp "$DRIVE" | awk '/part/ { print $1" "$4 }' >"$list"

		[ "$BOOT_TYPE" = 'efi' ] && {
			select_disk "efi"
			efi="$DISK"
			EFI_SIZE="$SIZE"
		}

		select_disk "root"
		root="$DISK"
		ROOT_SIZE="$SIZE"

		select_disk "home"
		home="$DISK"
		HOME_SIZE="$SIZE"

		select_disk "swap"
		swap="$DISK"
		SWAP_SIZE="$SIZE"

		select_disk "var"
		var="$DISK"
		VAR_SIZE="$SIZE"

		rm "$list"

		echo
		echo "root: $root $ROOT_SIZE"
		[ "$efi" ] && echo "efi: $efi $EFI_SIZE"
		[ "$home" ] && echo "home: $home $HOME_SIZE"
		[ "$swap" ] && echo "swap: $swap $SWAP_SIZE"
		[ "$var" ] && echo "var:  $var $VAR_SIZE"
		echo
		printf "Continue? [y/n] "
		read -r next
	done
}

set_mirrorlist() {
	pacman --noconfirm -Sy reflector
	echo "Setting mirrorlist..."
	reflector --latest 20 --age 24 --sort rate --protocol https --country $REFLECTOR_COUNTRY --save /etc/pacman.d/mirrorlist
}

install_base() {
	pacstrap /mnt base base-devel $KERNEL $UCODE linux-firmware git ntfs-3g dosfstools
	genfstab -U /mnt >/mnt/etc/fstab
}

unmount_filesystems() {
	swap=$(lsblk -nrp | awk '/SWAP/ {print $1}')
	[ "$swap" ] && swapoff "$swap"
	umount -R /mnt
}

arch_chroot() {
	cp "$0" /mnt/setup.sh
	cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
	arch-chroot /mnt bash -c "./setup.sh chroot $BOOT_TYPE"

	if [ -f /mnt/setup.sh ]; then
		echo 'ERROR: Something failed inside the chroot, not unmounting filesystems so you can investigate.'
		echo 'Make sure you unmount everything before you try to run this script again.'
	else
		echo 'Unmounting filesystems'
		unmount_filesystems
		echo 'DONE!'
		echo 'Reboot the system.'
	fi

}

#===========
# CONFIGURE
#===========
set_locale() {
	lang="$1"
	echo "${lang}.UTF-8 UTF-8" >/etc/locale.gen
	echo "LANG=${lang}.UTF-8" >/etc/locale.conf
	locale-gen
}

set_hostname() {
	hostname="$1"
	echo "$hostname" >/etc/hostname
}

set_hosts() {
	hostname="$1"
	hosts_file_type="$2"
	url="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/$hosts_file_type/hosts"
	if curl --output /dev/null --silent --head --fail "$url"; then
		curl "$url" >/etc/hosts
	elif [ "$hosts_file_type" = "unified" ]; then
		curl "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" >/etc/hosts
	else
		cat >/etc/hosts <<EOF
127.0.0.1 localhost.localdomain localhost $hostname
::1       localhost.localdomain localhost $hostname
EOF
	fi
}

set_vconsole_keymap() {
	localectl --no-ask-password --no-convert set-keymap $VCONSOLE_KEYMAP
}

set_x11_keymap() {
	localectl --no-ask-password --no-convert set-x11-keymap $X11_KEYMAP_LAYOUT $X11_KEYMAP_MODEL $X11_KEYMAP_VARIANT
}

set_timezone() {
	timezone="$1"
	ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime
	hwclock --systohc
}

set_root_password() {
	root_password="$1"
	printf "%s\n%s" "$root_password" "$root_password" | passwd >/dev/null 2>&1
}

create_user() {
	name="$1"
	password="$2"
	useradd -m -G adm,systemd-journal,wheel,rfkill,games,network,video,audio,optical,floppy,storage,scanner,power,sys,disk "$name"
	printf "%s\n%s" "$password" "$password" | passwd "$name" >/dev/null 2>&1
}

set_sudoers() {
	cat >/etc/sudoers <<EOF
# /etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
#
# See the man page for details on how to write a sudoers file.
#

Defaults env_reset
Defaults pwfeedback
Defaults passwd_timeout=0
Defaults lecture="never"
#Defaults editor=/usr/bin/micro
Defaults insults

root   ALL=(ALL) ALL
%wheel ALL=(ALL) ALL
EOF
}

# THIS IS TEMPORARY! 
set_temp_sudoers() {
	cat >/etc/sudoers <<EOF
# THIS IS TEMPORARY! 
# /etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
#
# See the man page for details on how to write a sudoers file.
#

Defaults env_reset
Defaults pwfeedback
Defaults passwd_timeout=0
Defaults lecture="never"

root   ALL=(ALL) ALL
# THIS IS TEMPORARY! 
%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman
%wheel ALL=(ALL) NOPASSWD: /usr/bin/$AUR_HELPER
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl
# THIS IS TEMPORARY! 
EOF
}

set_boot() {
	if [ "$BOOTLOADER" = "grub" ]; then
		pacman -S --noconfirm grub
		if [ "$BOOT_TYPE" = "efi" ]; then
			pacman -S --noconfirm efibootmgr
			grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB_ARCH --removable
		elif [ "$BOOT_TYPE" = "legacy" ]; then
			grub-install --target=i386-pc "$DRIVE"
		fi
		grub-mkconfig -o /boot/grub/grub.cfg
		echo "Disabling osprober"
		echo " " >> /etc/default/grub
		echo "# Disable osprober" >> /etc/default/grub
		echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
		grub-mkconfig -o /boot/grub/grub.cfg
	elif [ "$BOOTLOADER" = "refind" ]; then
		pacman -S efibootmgr refind
		cat >/boot/refind_linux.conf <<EOF
"Boot using default options"     "root=LABEL=ROOT rw add_efi_memmap initrd=boot\$UCODE.img"
#"Boot using fallback initramfs"  "root=LABEL=ROOT rw add_efi_memmap initrd=boot\$UCODE.img"
"Boot to terminal"               "root=LABEL=ROOT rw add_efi_memmap initrd=boot\$UCODE.img systemd.unit=multi-user.target"
EOF
		refind-install
	fi
}

install_aur_helper() {
	if [ "$AUR_HELPER" = "yay" ]; then
		git clone https://aur.archlinux.org/yay-bin.git /yay
		cd /yay
		chown $USER_NAME:$USER_NAME /yay
		sudo -u $USER_NAME makepkg -si --noconfirm
		cd /
		rm -rf /yay
	elif [ "$AUR_HELPER" = "paru" ]; then
		git clone https://aur.archlinux.org/paru-bin.git /paru
		cd /paru
		chown $USER_NAME:$USER_NAME /paru
		sudo -u $USER_NAME makepkg -si --noconfirm
		cd /
		rm -rf /paru
	fi
}

disable_pc_speaker() {
	echo "blacklist pcspkr" >>/etc/modprobe.d/nobeep.conf
}

clean_packages() {
	yes | $AUR_HELPER -Scc
}

set_pacman() {
	cat >/etc/pacman.conf <<EOF
#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives

[options]
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = auto

# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   =
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
Color
CheckSpace
VerbosePkgLists
ILoveCandy
ParallelDownloads = 10

SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required


#[testing]
#Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
}

set_makepkg() {
	sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/g" /etc/makepkg.conf
	sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $(nproc) -z -)/g" /etc/makepkg.conf
}

setup() {
	greeter

	echo "Setting network"
	network

	if [ -e "$DRIVE" ]; then
		printf "%s :: Are you sure? This disk will be formatted: [Type YES to confirm] " "$DRIVE"
		read -r choice
		[ ! "$choice" = "YES" ] && exit
	else
		echo "$DRIVE :: Device doesn't exist!"
		exit 1
	fi

	mkdir -p /mnt

	if [ ! "$BOOT_TYPE" ]; then
		detect_boot_type
	elif [ "$BOOT_TYPE" != 'efi' ] && [ "$BOOT_TYPE" != 'legacy' ]; then
		echo "Wrong boot type: $BOOT_TYPE"
		echo "Set to efi or legacy"
		exit
	fi

	if [ "$PARTITIONING" = auto ]; then
		auto_partition
	else
		manual_partition
	fi
	format_and_mount
	
	echo "Setting pacman.conf"
	set_pacman

	echo "Setting mirrorlist"
	set_mirrorlist

	echo "Installing base packages"
	install_base

	echo "Chrooting to new system"
	arch_chroot
}

configure() {
	echo "Setting locale"
	set_locale "$LANG"

	echo "Setting time zone"
	[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ] && TIMEZONE=$(tzselect)
	set_timezone "$TIMEZONE"

	echo "Setting hostname"
	[ ! "$HOSTNAME" ] && {
		printf "Enter the hostname: "
		read -r HOSTNAME
	}

	set_hostname "$HOSTNAME"

	echo "Setting hosts file"
	set_hosts "$HOSTNAME" "$HOSTS_FILE_TYPE"

	echo "Setting vconsole keymap"
	set_vconsole_keymap

	echo 'Instaling and configuring bootloader'
	set_boot

	echo 'Setting root password'
	[ ! "$ROOT_PASSWORD" ] && {
		printf "Enter the root password: "
		read -r ROOT_PASSWORD
	}
	set_root_password "$ROOT_PASSWORD"

	echo 'Creating initial user'
	[ ! "$USER_NAME" ] && {
		printf "Enter the user name: "
		read -r USER_NAME
	}
	[ ! "$USER_PASSWORD" ] && {
		printf "Enter the password for user %s: " "$USER_NAME"
		read -r USER_PASSWORD
	}
	create_user "$USER_NAME" "$USER_PASSWORD"

	echo 'Setting temp sudoers config'
	set_temp_sudoers
	
	echo "Setting mirrorlist"
	set_mirrorlist

	echo "Setting pacman.conf"
	set_pacman

	echo "Setting makepkg.conf"
	set_makepkg

	echo 'Installing AUR helper'
	install_aur_helper

	echo 'Installing and configuring additional packages'
	install_packages
	
	echo "Setting X11 keymap"
	set_vconsole_keymap
	
	echo 'Clearing AUR helper/pacman cache'
	clean_packages
	echo ' '
	
	echo 'Setting true sudoers config'
	set_sudoers

	#echo 'Disabling PC speaker'
	#disable_pc_speaker

	rm /setup.sh
}

if [ "$1" = "chroot" ]; then
	configure "$2"
else
	setup
fi
