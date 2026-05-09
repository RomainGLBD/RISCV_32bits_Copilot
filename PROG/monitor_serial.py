#!/usr/bin/env python3
"""
Script pour monitorer le port série et afficher les données en format little-endian
Usage: python3 monitor_serial.py <port_serie>
Exemple: python3 monitor_serial.py /dev/ttyUSB4
"""

import sys
import serial
import time

def monitor_serial(serial_port, baudrate=115200):
    """
    Monitore le port série et affiche les octets regroupés par mots de 16 bits
    Les données arrivent en little-endian mais sont affichées avec poids fort à gauche
    
    Args:
        serial_port: nom du port série (ex: /dev/ttyUSB4)
        baudrate: vitesse de transmission (défaut: 115200)
    """
    try:
        with serial.Serial(serial_port, baudrate, timeout=1) as ser:
            print(f"Monitoring port série {serial_port} à {baudrate} bauds")
            print("Format: affichage avec poids fort à gauche (données reçues en little-endian)")
            print("Appuyez sur Ctrl+C pour arrêter\n")
            
            buffer = []
            word_count = 0
            
            while True:
                if ser.in_waiting > 0:
                    byte = ser.read(1)
                    buffer.append(byte[0])
                    
                    # Afficher par paires (mots de 16 bits)
                    if len(buffer) == 2:
                        # Données reçues: buffer[0] = poids faible, buffer[1] = poids fort
                        # Affichage inversé pour avoir poids fort à gauche
                        print(f"Mot {word_count:3d}: {buffer[1]:02X}{buffer[0]:02X} ({buffer[1]:02X} | {buffer[0]:02X})", end="")
                        
                        # Valeur décimale
                        value = buffer[0] | (buffer[1] << 8)
                        print(f"  = {value:5d} (décimal)")
                        
                        buffer = []
                        word_count += 1
                    
                time.sleep(0.001)
                    
    except KeyboardInterrupt:
        print("\n\nMonitoring arrêté")
    except serial.SerialException as e:
        print(f"Erreur port série: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Erreur: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 monitor_serial.py <port_serie>")
        print("Exemple: python3 monitor_serial.py /dev/ttyUSB4")
        sys.exit(1)
    
    serial_port = sys.argv[1]
    monitor_serial(serial_port)

if __name__ == "__main__":
    main()
