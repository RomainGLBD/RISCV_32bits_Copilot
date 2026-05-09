#!/usr/bin/env python3
"""Envoi UART de fichiers IMEM/DMEM vers le chargeur VHDL.

Format de trame (10 octets, little-endian pour adresse et data):
  [CMD][ADDR0][ADDR1][ADDR2][ADDR3][DATA0][DATA1][DATA2][DATA3][CHECKSUM]
  CHECKSUM = XOR des 9 premiers octets.

CMD:
  - 'I' (0x49): ecriture Memoire_instructions
  - 'D' (0x44): ecriture Memoire_data
  - 'R' (0x52): lancement CPU (fin du chargement)

Modes d'utilisation:
  1) Deux fichiers en une seule commande:
       python3 send_prog.py instructions.hex data.hex /dev/ttyUSB0 --run

  2) Un seul fichier (mode historique):
       python3 send_prog.py instructions.hex /dev/ttyUSB0 --target imem --run
       python3 send_prog.py data.hex /dev/ttyUSB0 --target dmem
"""

import argparse
import sys
import time

import serial


def parse_hex_word(line: str, line_num: int) -> int:
    s = line.strip()
    if not s or s.startswith("#"):
        return -1

    if s.lower().startswith("0x"):
        s = s[2:]

    s = s.replace("_", "")
    if len(s) > 8:
        raise ValueError(f"ligne {line_num}: valeur trop longue ({line.strip()})")

    try:
        return int(s, 16) & 0xFFFFFFFF
    except ValueError as exc:
        raise ValueError(f"ligne {line_num}: hex invalide ({line.strip()})") from exc


def build_frame(cmd: int, addr: int, data: int) -> bytes:
    payload = bytearray()
    payload.append(cmd & 0xFF)
    payload.extend((addr & 0xFFFFFFFF).to_bytes(4, byteorder="little"))
    payload.extend((data & 0xFFFFFFFF).to_bytes(4, byteorder="little"))

    checksum = 0
    for b in payload:
        checksum ^= b

    payload.append(checksum)
    return bytes(payload)


def send_file_over_serial(ser: serial.Serial, file_path: str, target: str, base_addr: int, verbose: bool) -> int:
    cmd = ord("I") if target == "imem" else ord("D")
    sent_words = 0
    addr = base_addr

    with open(file_path, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            value = parse_hex_word(line, line_num)
            if value < 0:
                continue

            frame = build_frame(cmd, addr, value)
            ser.write(frame)

            if verbose:
                print(f"[{target}:{sent_words:04d}] addr=0x{addr:08X} data=0x{value:08X} chk=0x{frame[-1]:02X}")

            sent_words += 1
            addr += 4

    return sent_words


def send_run(ser: serial.Serial, verbose: bool) -> None:
    frame = build_frame(ord("R"), 0, 0)
    ser.write(frame)
    if verbose:
        print("Trame RUN envoyee")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Envoie un ou deux fichiers vers le bootloader UART VHDL"
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="1 fichier (mode historique) ou 2 fichiers (instructions puis data)",
    )
    parser.add_argument(
        "port",
        help="Port serie, ex: /dev/ttyUSB0",
    )
    parser.add_argument(
        "--target",
        choices=["imem", "dmem"],
        help="Cible en mode mono-fichier",
    )
    parser.add_argument(
        "--base-instr",
        default="0x00000000",
        help="Adresse de base pour la memoire instructions (defaut: 0x00000000)",
    )
    parser.add_argument(
        "--base-data",
        default="0x00000000",
        help="Adresse de base pour la memoire data (defaut: 0x00000000)",
    )
    parser.add_argument(
        "--baud",
        type=int,
        default=115200,
        help="Baudrate (defaut: 115200)",
    )
    parser.add_argument(
        "--run",
        action="store_true",
        help="Envoie ensuite la trame RUN",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Affichage detaille",
    )
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    try:
        if len(args.files) == 1 and args.target is None:
            parser.error("en mode mono-fichier, --target imem ou dmem est obligatoire")
        if len(args.files) not in (1, 2):
            parser.error("il faut fournir 1 fichier ou 2 fichiers")

        base_instr = int(args.base_instr, 0)
        base_data = int(args.base_data, 0)
        if base_instr < 0 or base_data < 0:
            raise ValueError("adresse de base negative")

        with serial.Serial(args.port, args.baud, timeout=1) as ser:
            print(f"Port serie {args.port} ouvert a {args.baud} bauds")
            time.sleep(0.1)

            if len(args.files) == 2:
                instr_file, data_file = args.files
                sent_i = send_file_over_serial(ser, instr_file, "imem", base_instr, args.verbose)
                print(f"{sent_i} mot(s) envoye(s) vers imem")

                sent_d = send_file_over_serial(ser, data_file, "dmem", base_data, args.verbose)
                print(f"{sent_d} mot(s) envoye(s) vers dmem")

            else:
                file_path = args.files[0]
                sent_words = send_file_over_serial(ser, file_path, args.target, base_instr if args.target == "imem" else base_data, args.verbose)
                print(f"{sent_words} mot(s) envoye(s) vers {args.target}")

            if args.run:
                time.sleep(0.05)
                send_run(ser, args.verbose)

    except FileNotFoundError:
        print(f"Erreur: fichier introuvable", file=sys.stderr)
        sys.exit(1)
    except serial.SerialException as exc:
        print(f"Erreur port serie: {exc}", file=sys.stderr)
        sys.exit(1)
    except ValueError as exc:
        print(f"Erreur: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
