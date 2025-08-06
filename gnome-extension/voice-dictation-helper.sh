#!/bin/bash
# Helper script para la extensión de dictado por voz

SCRIPT_PATH="$HOME/bin/voice-dictation"
DURATION=""
MODEL="tiny"

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -l|--language)
            # Ignorar por ahora, el script usa español por defecto
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Cambiar modelo si es necesario
if [[ "$MODEL" != "tiny" ]]; then
    "$SCRIPT_PATH" config "$MODEL" >/dev/null 2>&1
fi

if [[ -n "$DURATION" ]]; then
    # Grabación con duración fija
    notify-send "🎤 Dictado por voz" "Grabando ${DURATION} segundos..." -t 1000
    
    # Iniciar grabación
    "$SCRIPT_PATH" start >/dev/null 2>&1 &
    START_PID=$!
    
    # Esperar duración
    sleep "$DURATION"
    
    # Parar y transcribir
    "$SCRIPT_PATH" stop
    
else
    # Grabación manual (usar el script directamente)
    "$SCRIPT_PATH"
fi