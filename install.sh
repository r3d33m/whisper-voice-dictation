#!/bin/bash
# Complete installation script for Whisper Voice Dictation

set -e

echo "🎤 Installing Whisper Voice Dictation..."
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "scripts" ]; then
    print_error "Please run this script from the whisper-voice-dictation directory"
    exit 1
fi

# 1. Create directories
print_status "Creating directories..."
mkdir -p ~/bin
mkdir -p ~/.local/share/gnome-shell/extensions/
mkdir -p ~/.local/share/bash-completion/completions/

# 2. Copy scripts
print_status "Installing scripts..."
cp scripts/* ~/bin/
chmod +x ~/bin/voice-*
print_success "Scripts installed to ~/bin/"

# 3. Install GNOME extension
if command -v gnome-shell &> /dev/null; then
    print_status "Installing GNOME extension..."
    cp -r gnome-extension ~/.local/share/gnome-shell/extensions/voice-dictation@miguel
    print_success "GNOME extension installed"
    print_warning "You may need to restart GNOME Shell (Alt+F2, type 'r') and enable the extension"
else
    print_warning "GNOME Shell not detected, skipping extension installation"
fi

# 4. Setup PATH
print_status "Setting up PATH..."
SHELL_NAME=$(basename "$SHELL")
case $SHELL_NAME in
    bash)
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc; then
            echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            print_success "Added ~/bin to PATH in ~/.bashrc"
        else
            print_success "~/bin already in PATH"
        fi
        ;;
    zsh)
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc; then
            echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
            print_success "Added ~/bin to PATH in ~/.zshrc"
        else
            print_success "~/bin already in PATH"
        fi
        ;;
    fish)
        if ! fish -c 'contains $HOME/bin $fish_user_paths' 2>/dev/null; then
            fish -c 'set -U fish_user_paths $HOME/bin $fish_user_paths' 2>/dev/null || true
            print_success "Added ~/bin to PATH in fish"
        else
            print_success "~/bin already in fish PATH"
        fi
        ;;
    *)
        print_warning "Unknown shell: $SHELL_NAME. Please add ~/bin to your PATH manually"
        ;;
esac

# 5. Setup bash completion
print_status "Installing bash completion..."

# Voice-dictation completion
cat > ~/.local/share/bash-completion/completions/voice-dictation << 'EOF'
_voice_dictation() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case ${prev} in
        config)
            opts="tiny small medium large"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
        voice-dictation)
            opts="config start stop"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}
complete -F _voice_dictation voice-dictation
EOF

# Voice-realtime completion
cat > ~/.local/share/bash-completion/completions/voice-realtime << 'EOF'
_voice_realtime() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case ${prev} in
        -m|--model)
            opts="tiny small medium large"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
        -d|--duration)
            opts="2 3 5 10"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
        voice-realtime)
            opts="-m --model -d --duration -p --paste -h --help"
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}
complete -F _voice_realtime voice-realtime
EOF

print_success "Bash completion installed"

# 6. Setup keyboard shortcuts (GNOME only)
if command -v gsettings &> /dev/null && [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    print_status "Setting up keyboard shortcuts..."
    if ./setup-keybindings.sh; then
        print_success "Keyboard shortcuts configured (Super+D / Super+C)"
    else
        print_warning "Could not setup keyboard shortcuts automatically"
    fi
else
    print_warning "Not running GNOME, skipping keyboard shortcuts"
fi

# 7. Check dependencies
print_status "Checking dependencies..."
missing_deps=()

for dep in python3 ffmpeg zenity; do
    if ! command -v $dep &> /dev/null; then
        missing_deps+=($dep)
    fi
done

if command -v wl-copy &> /dev/null || command -v xsel &> /dev/null || command -v xclip &> /dev/null; then
    clipboard_ok=true
else
    missing_deps+=(wl-clipboard)
    clipboard_ok=false
fi

if [ ${#missing_deps[@]} -eq 0 ]; then
    print_success "All dependencies satisfied"
else
    print_warning "Missing dependencies: ${missing_deps[*]}"
    echo ""
    echo "Install them with:"
    echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
    echo "  Fedora: sudo dnf install ${missing_deps[*]}"  
    echo "  Arch/Manjaro: sudo pacman -S ${missing_deps[*]}"
fi

# 8. Check for whisper.cpp
print_status "Checking for whisper.cpp..."
whisper_paths=(
    "/home/$USER/src/whisper.cpp/build/bin/whisper-cli"
    "/usr/local/bin/whisper-cli"
    "/usr/bin/whisper-cli"
)

whisper_found=false
for path in "${whisper_paths[@]}"; do
    if [ -f "$path" ]; then
        print_success "Found whisper-cli at: $path"
        whisper_found=true
        break
    fi
done

if [ "$whisper_found" = false ]; then
    print_warning "whisper.cpp not found in standard locations"
    echo ""
    echo "Install whisper.cpp:"
    echo "  git clone https://github.com/ggerganov/whisper.cpp.git"
    echo "  cd whisper.cpp"
    echo "  make -j\$(nproc)"
    echo "  bash ./models/download-ggml-model.sh tiny"
fi

echo ""
echo "========================================="
print_success "Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Restart your terminal or run: source ~/.${SHELL_NAME}rc"
echo "  2. Test with: voice-dictation config"
echo "  3. Use Super+D to start, Super+C to stop recording"
echo "  4. Try real-time mode: voice-realtime"
echo ""
echo "📚 Documentation: https://github.com/r3d33m/whisper-voice-dictation"
echo ""

# Optional: Ask about system service
read -p "❓ Install system service for auto-start? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Creating system service..."
    
    mkdir -p ~/.config/systemd/user
    cat > ~/.config/systemd/user/voice-dictation.service << EOF
[Unit]
Description=Voice Dictation Service
After=graphical-session.target

[Service]
Type=simple
ExecStart=$HOME/bin/voice-dictation daemon
Restart=always
RestartSec=5
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    if systemctl --user enable voice-dictation.service; then
        print_success "System service installed and enabled"
        print_status "Service will start automatically on next login"
    else
        print_warning "Could not enable system service"
    fi
fi

print_success "🎤 Whisper Voice Dictation is ready to use!"