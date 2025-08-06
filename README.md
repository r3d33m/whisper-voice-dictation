# 🎤 Whisper Voice Dictation for Linux

A complete voice dictation solution for Linux using OpenAI Whisper.cpp, with GNOME Shell integration and real-time transcription capabilities.

## ✨ Features

- **🔥 Fast Transcription**: Uses optimized Whisper.cpp with GPU acceleration
- **⚡ Multiple Modes**: Normal dictation, real-time streaming, and manual control
- **🎯 GNOME Integration**: Panel button with click-to-dictate functionality  
- **⌨️ Global Shortcuts**: Super+D to start, Super+C to stop recording
- **🔄 Model Switching**: Easy switching between tiny/small/medium/large models
- **🗣️ Multiple Languages**: Spanish, English, French, German, Italian, Portuguese
- **📋 Clipboard Integration**: Automatically copies transcription to clipboard
- **🪟 Visual Feedback**: Popup dialogs showing transcribed text

## 🚀 Quick Start

### Prerequisites

```bash
# Install whisper.cpp
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
make -j$(nproc)

# Download models
bash ./models/download-ggml-model.sh tiny
bash ./models/download-ggml-model.sh small  # optional, for better accuracy
```

### Installation

```bash
# Clone this repository
git clone https://github.com/yourusername/whisper-voice-dictation.git
cd whisper-voice-dictation

# Copy scripts to your bin directory
cp scripts/* ~/bin/
chmod +x ~/bin/voice-*

# Install GNOME extension
cp -r gnome-extension ~/.local/share/gnome-shell/extensions/voice-dictation@miguel

# Set up keyboard shortcuts
./setup-keybindings.sh
```

## 📖 Usage

### Method 1: Keyboard Shortcuts
- **Super+D**: Start recording
- **Super+C**: Stop recording and transcribe

### Method 2: GNOME Panel Button
- **Left click**: Toggle recording (manual mode)
- **Right click**: Menu with options:
  - 🎤 Quick recording (5 seconds)
  - ⏱️ Long recording (10 seconds) 
  - 🎙️ Real-time transcription
  - 🧠 Model selection
  - 🌍 Language selection

### Method 3: Command Line

```bash
# Normal dictation
voice-dictation

# Real-time transcription
voice-realtime

# Real-time with different settings
voice-realtime -m small -d 3  # small model, 3-second chunks
voice-realtime -d 2           # 2-second chunks for faster response
```

## ⚙️ Configuration

### Change Whisper Model

```bash
# View current model
voice-dictation config

# Switch to small model (better accuracy, slower)
voice-dictation config small

# Switch to tiny model (faster, less accurate)
voice-dictation config tiny
```

### Available Models
- **tiny**: Fastest (2-3 seconds), good for short commands
- **small**: Balanced (5-8 seconds), recommended for most users
- **medium**: High accuracy (15-20 seconds)
- **large**: Best accuracy (30+ seconds)

## 📁 File Structure

```
whisper-voice-dictation/
├── scripts/
│   ├── voice-dictation         # Main dictation script
│   ├── voice-realtime          # Real-time transcription
│   └── voice-realtime-simple   # Simple real-time demo
├── gnome-extension/
│   ├── extension.js            # GNOME Shell extension
│   ├── metadata.json           # Extension metadata
│   ├── stylesheet.css          # Extension styling
│   └── voice-dictation-helper.sh # Helper script
├── setup-keybindings.sh        # Keyboard shortcut setup
└── README.md                   # This file
```

## 🛠️ System Requirements

- **Linux Distribution**: Any (tested on Manjaro, Ubuntu, Fedora)
- **Desktop Environment**: GNOME Shell (for extension), or any DE for scripts
- **Audio**: PulseAudio or PipeWire
- **Dependencies**:
  - Python 3.6+
  - ffmpeg
  - whisper.cpp (compiled with your system)
  - wl-clipboard (Wayland) or xsel/xclip (X11)

### Required Packages

```bash
# Ubuntu/Debian
sudo apt install python3 ffmpeg wl-clipboard zenity

# Fedora
sudo dnf install python3 ffmpeg wl-clipboard zenity

# Manjaro/Arch
sudo pacman -S python3 ffmpeg wl-clipboard zenity
```

## 🔧 Advanced Configuration

### Custom Whisper Installation

Edit the scripts to point to your whisper.cpp installation:

```python
# In voice-dictation and voice-realtime
WHISPER_CLI = "/path/to/your/whisper.cpp/build/bin/whisper-cli"
MODELS = {
    'tiny': "/path/to/your/models/ggml-tiny.bin",
    # ... other models
}
```

### Wayland Support

The system automatically detects Wayland and uses appropriate tools:
- **Clipboard**: `wl-copy` instead of `xsel`
- **Input**: Wayland-compatible methods (auto-paste disabled by default due to security restrictions)

## 🐛 Troubleshooting

### Common Issues

**"Model not found"**
```bash
# Download the required model
cd /path/to/whisper.cpp
bash ./models/download-ggml-model.sh tiny
```

**"No audio recorded" / "0 byte file"**
- Check microphone permissions
- Ensure PulseAudio/PipeWire is running
- Test with: `arecord -f S16_LE -r 16000 test.wav`

**"Remote Desktop dialog opens"**
- This is a Wayland/xdotool conflict
- Auto-paste is disabled by default in Wayland for security
- Use manual paste (Ctrl+V) instead

**Extension not working**
```bash
# Restart GNOME Shell (Alt+F2, type 'r', press Enter)
# Or logout/login
# Check extension is enabled in GNOME Extensions app
```

### Debug Mode

```bash
# View debug logs
tail -f ~/.cache/voice-debug/debug.log

# Test individual components
whisper-cli -m models/ggml-tiny.bin -l es -f test.wav -otxt
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Setup

```bash
git clone https://github.com/yourusername/whisper-voice-dictation.git
cd whisper-voice-dictation

# Create development links instead of copying
ln -sf $(pwd)/scripts/voice-dictation ~/bin/
ln -sf $(pwd)/scripts/voice-realtime ~/bin/
```

## 📜 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper) - Original Whisper model
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Fast C++ implementation
- GNOME Shell - Desktop integration platform

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/whisper-voice-dictation/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/whisper-voice-dictation/discussions)

---

**⭐ If this project helped you, please give it a star!**