/* Voice Dictation Extension for GNOME Shell
 * Botón en el panel para activar dictado por voz
 */

import GObject from 'gi://GObject';
import St from 'gi://St';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

const VoiceDictationIndicator = GObject.registerClass(
class VoiceDictationIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Voice Dictation');
        
        // Estado de grabación
        this._isRecording = false;
        this._recordingProcess = null;
        
        // Crear el ícono del botón
        this._icon = new St.Icon({
            icon_name: 'audio-input-microphone-symbolic',
            style_class: 'system-status-icon'
        });
        
        this.add_child(this._icon);
        
        // Crear menú
        this._createMenu();
        
        // Click en el botón principal
        this.connect('button-press-event', (actor, event) => {
            if (event.get_button() === 1) { // Click izquierdo
                this._toggleRecording();
                return Clutter.EVENT_STOP;
            }
            return Clutter.EVENT_PROPAGATE;
        });
    }
    
    _createMenu() {
        // Ítem del menú para grabación rápida (5 segundos)
        let quickRecordItem = new PopupMenu.PopupMenuItem('🎤 Grabación rápida (5 seg)');
        quickRecordItem.connect('activate', () => {
            this.menu.close();
            this._startQuickRecording();
        });
        this.menu.addMenuItem(quickRecordItem);
        
        // Ítem para grabación de 10 segundos
        let longRecordItem = new PopupMenu.PopupMenuItem('⏱️ Grabación larga (10 seg)');
        longRecordItem.connect('activate', () => {
            this.menu.close();
            this._startLongRecording();
        });
        this.menu.addMenuItem(longRecordItem);
        
        // Ítem para tiempo real
        let realtimeRecordItem = new PopupMenu.PopupMenuItem('🎙️ Tiempo real (experimental)');
        realtimeRecordItem.connect('activate', () => {
            this.menu.close();
            this._startRealtimeRecording();
        });
        this.menu.addMenuItem(realtimeRecordItem);
        
        // Separador
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        
        // Opción de modelo
        let modelSection = new PopupMenu.PopupSubMenuMenuItem('🧠 Modelo Whisper');
        
        this._selectedModel = 'tiny';
        let models = ['tiny', 'small', 'medium', 'large'];
        
        models.forEach(model => {
            let item = new PopupMenu.PopupMenuItem(model);
            item.connect('activate', () => {
                this._selectedModel = model;
                this._updateModelLabel();
            });
            modelSection.menu.addMenuItem(item);
        });
        
        this.menu.addMenuItem(modelSection);
        
        // Opción de idioma
        let langSection = new PopupMenu.PopupSubMenuMenuItem('🌍 Idioma');
        
        this._selectedLang = 'es';
        let languages = [
            ['es', 'Español'],
            ['en', 'English'],
            ['fr', 'Français'],
            ['de', 'Deutsch'],
            ['it', 'Italiano'],
            ['pt', 'Português']
        ];
        
        languages.forEach(([code, name]) => {
            let item = new PopupMenu.PopupMenuItem(name);
            item.connect('activate', () => {
                this._selectedLang = code;
            });
            langSection.menu.addMenuItem(item);
        });
        
        this.menu.addMenuItem(langSection);
        
        // Separador
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        
        // Estado
        this._statusItem = new PopupMenu.PopupMenuItem('Estado: Listo', {
            reactive: false
        });
        this.menu.addMenuItem(this._statusItem);
    }
    
    _toggleRecording() {
        if (!this._isRecording) {
            this._startManualRecording();
        } else {
            this._stopRecording();
        }
    }
    
    _startManualRecording() {
        this._isRecording = true;
        this._updateIcon(true);
        this._showNotification('🔴 Grabando...', 'Haz click de nuevo para detener');
        
        // Ejecutar el script de dictado actual (toggle manual)
        let cmd = [GLib.get_home_dir() + '/bin/voice-dictation'];
        
        this._recordingProcess = Gio.Subprocess.new(
            cmd,
            Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        );
        
        // Cuando termine el proceso
        this._recordingProcess.wait_async(null, (proc, res) => {
            try {
                proc.wait_finish(res);
                this._isRecording = false;
                this._updateIcon(false);
                this._showNotification('✅ Transcripción completada', 'Texto copiado al portapapeles');
            } catch (e) {
                this._showNotification('❌ Error', 'No se pudo completar la transcripción');
                this._isRecording = false;
                this._updateIcon(false);
            }
        });
    }
    
    _stopRecording() {
        if (this._recordingProcess) {
            // Enviar señal de interrupción al proceso
            this._recordingProcess.send_signal(2); // SIGINT
            this._recordingProcess = null;
        }
        this._isRecording = false;
        this._updateIcon(false);
    }
    
    _startQuickRecording() {
        this._showNotification('🎤 Grabación rápida', 'Habla ahora (5 segundos)...');
        this._runDictation(5);
    }
    
    _startLongRecording() {
        this._showNotification('🎤 Grabación larga', 'Habla ahora (10 segundos)...');
        this._runDictation(10);
    }
    
    _startRealtimeRecording() {
        this._showNotification('🎙️ Tiempo real', 'Abre terminal para ver progreso');
        
        let cmd = [
            'gnome-terminal', '--',
            GLib.get_home_dir() + '/bin/voice-realtime',
            '-m', this._selectedModel || 'tiny',
            '-d', '3'
        ];
        
        let proc = Gio.Subprocess.new(
            cmd,
            Gio.SubprocessFlags.NONE
        );
    }
    
    _runDictation(duration) {
        this._updateIcon(true);
        
        // Usar el script helper que maneja los parámetros
        let cmd = [
            GLib.get_home_dir() + '/.local/share/gnome-shell/extensions/voice-dictation@miguel/voice-dictation-helper.sh',
            '-d', duration.toString(),
            '-m', this._selectedModel || 'tiny',
            '-l', this._selectedLang || 'es'
        ];
        
        let proc = Gio.Subprocess.new(
            cmd,
            Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        );
        
        proc.wait_async(null, (proc, res) => {
            try {
                proc.wait_finish(res);
                this._updateIcon(false);
                this._showNotification('✅ Transcripción completada', 'Texto copiado al portapapeles');
            } catch (e) {
                this._showNotification('❌ Error', 'No se pudo completar la transcripción');
                this._updateIcon(false);
            }
        });
    }
    
    _updateIcon(recording) {
        if (recording) {
            this._icon.icon_name = 'media-record-symbolic';
            this._icon.add_style_class_name('recording-active');
        } else {
            this._icon.icon_name = 'audio-input-microphone-symbolic';
            this._icon.remove_style_class_name('recording-active');
        }
    }
    
    _updateModelLabel() {
        // Actualizar el estado mostrado
        this._statusItem.label.text = `Modelo: ${this._selectedModel}`;
    }
    
    _showNotification(title, message) {
        Main.notify(title, message);
    }
    
    destroy() {
        if (this._recordingProcess) {
            this._recordingProcess.send_signal(2);
        }
        super.destroy();
    }
});

class Extension {
    constructor() {
        this._indicator = null;
    }
    
    enable() {
        this._indicator = new VoiceDictationIndicator();
        Main.panel.addToStatusArea('voice-dictation', this._indicator);
    }
    
    disable() {
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}

export default Extension;