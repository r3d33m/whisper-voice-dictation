#!/bin/bash
# Setup keyboard shortcuts for Whisper Voice Dictation

echo "🔧 Setting up keyboard shortcuts..."

# Check if running GNOME
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    echo "⚠️ This script is designed for GNOME. Manual setup required for other DEs."
    exit 1
fi

# Get current custom keybindings
CUSTOM_KEYS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# Add our keybindings if they don't exist
if [[ "$CUSTOM_KEYS" != *"voice-dictation-start"* ]]; then
    echo "Setting up Super+D for starting dictation..."
    
    # Add to custom keybindings list
    NEW_KEYS=$(echo "$CUSTOM_KEYS" | sed 's/]/, "\/org\/gnome\/settings-daemon\/plugins\/media-keys\/custom-keybindings\/voice-dictation-start\/", "\/org\/gnome\/settings-daemon\/plugins\/media-keys\/custom-keybindings\/voice-dictation-stop\/"]/')
    
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_KEYS"
    
    # Configure start keybinding
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-dictation-start/ name "Voice Dictation Start"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-dictation-start/ command "$HOME/bin/voice-dictation start"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-dictation-start/ binding "<Super>d"
    
    # Configure stop keybinding  
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-dictation-stop/ name "Voice Dictation Stop"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-dictation-stop/ command "$HOME/bin/voice-dictation stop"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-dictation-stop/ binding "<Super>c"
    
    echo "✅ Keyboard shortcuts configured:"
    echo "   Super+D: Start recording"
    echo "   Super+C: Stop recording and transcribe"
else
    echo "✅ Keyboard shortcuts already configured"
fi

echo ""
echo "🎤 Voice Dictation is ready to use!"
echo ""
echo "Usage:"
echo "  Super+D - Start recording"
echo "  Super+C - Stop and transcribe"
echo "  voice-dictation config - Change model"
echo "  voice-realtime - Real-time transcription"