"""Conversor ASM->binario para MIPS"""
import tkinter as tk
from tkinter import filedialog, messagebox

# Mapa de instrucciones ampliado con JAL
inst_map = {
    # Tipo R
    "ADD": {"opcode": "000000", "funct": "100000", "type": "R"},
    "SUB": {"opcode": "000000", "funct": "100010", "type": "R"},
    "SLT": {"opcode": "000000", "funct": "101010", "type": "R"},
    "NOP": {"opcode": "000000", "funct": "000000", "type": "R"},
    
    # Tipo I
    "ADDI": {"opcode": "001000", "type": "I"},
    "ORI": {"opcode": "001101", "type": "I"},
    "ANDI": {"opcode": "001100", "type": "I"},
    "LW": {"opcode": "100011", "type": "I"},
    "SW": {"opcode": "101011", "type": "I"},
    "BEQ": {"opcode": "000100", "type": "I"},
    "BNE": {"opcode": "000101", "type": "I"},
    "BGTZ": {"opcode": "000111", "type": "I"},
    
    # Tipo J
    "J": {"opcode": "000010", "type": "J"},
    "JAL": {"opcode": "000011", "type": "J"}
}

def preprocess_asm(lines):
    """Primera pasada: Resuelve etiquetas y elimina comentarios"""
    labels = {}
    clean_lines = []
    address = 0
    
    for line in lines:
        # Eliminar comentarios y espacios
        line = line.split('#')[0].strip()
        if not line:
            continue
        
        # Manejar etiquetas
        if ':' in line:
            label_part, instruction_part = line.split(':', 1)
            label = label_part.strip()
            instruction = instruction_part.strip()
            
            # Solo agregar la dirección si es una etiqueta nueva
            if label not in labels:
                labels[label] = address
            
            if instruction:
                clean_lines.append(instruction)
                address += 4
        else:
            clean_lines.append(line)
            address += 4
    
    return clean_lines, labels

def calculate_branch_offset(target_addr, current_addr):
    """Calcula el offset para instrucciones de branch"""
    return (target_addr - (current_addr + 4)) // 4

def convert_asm_to_bin(asm_line, current_addr, labels):
    asm_line = asm_line.strip()
    if not asm_line:
        return None
    
    parts = [p.replace(',', '').strip() for p in asm_line.split()]
    inst = parts[0].upper()
    
    if inst not in inst_map:
        return None
    
    try:
        if inst_map[inst]["type"] == "R":
            if inst == "NOP":
                return "00000000000000000000000000000000"
            rd = f"{int(parts[1][1:]):05b}"
            rs = f"{int(parts[2][1:]):05b}"
            rt = f"{int(parts[3][1:]):05b}"
            return f"{inst_map[inst]['opcode']}{rs}{rt}{rd}00000{inst_map[inst]['funct']}"
        
        elif inst_map[inst]["type"] == "I":
            if inst in ["LW", "SW"]:
                rt = f"{int(parts[1][1:]):05b}"
                offset_rs = parts[2].split('(')
                imm = f"{int(offset_rs[0]):016b}"
                rs = f"{int(offset_rs[1][1:-1]):05b}"
                return f"{inst_map[inst]['opcode']}{rs}{rt}{imm}"
            
            elif inst in ["ADDI", "ORI", "ANDI"]:
                rt = f"{int(parts[1][1:]):05b}"
                rs = f"{int(parts[2][1:]):05b}"
                imm = f"{int(parts[3]):016b}"
                return f"{inst_map[inst]['opcode']}{rs}{rt}{imm}"
            
            elif inst in ["BEQ", "BNE", "BGTZ"]:
                rs = f"{int(parts[1][1:]):05b}"
                rt = f"{int(parts[2][1:]):05b}" if inst in ["BEQ", "BNE"] else "00000"
                target_label = parts[3] if inst in ["BEQ", "BNE"] else parts[2]
                offset = calculate_branch_offset(labels[target_label], current_addr)
                imm = f"{offset & 0xFFFF:016b}"
                return f"{inst_map[inst]['opcode']}{rs}{rt}{imm}"
        
        elif inst_map[inst]["type"] == "J":
            target_label = parts[1]
            target_addr = labels[target_label]
            target_bits = f"{(target_addr >> 2) & 0x03FFFFFF:026b}"
            return f"{inst_map[inst]['opcode']}{target_bits}"
    
    except Exception as e:
        print(f"Error en línea: {asm_line} - {str(e)}")
        return None

def split_to_4_lines(binary_str):
    """Divide una instrucción de 32 bits en 4 líneas de 8 bits"""
    if len(binary_str) != 32:
        return []
    return [binary_str[i*8:(i+1)*8] for i in range(4)]

def convert_file():
    input_file = entry_path.get()
    if not input_file:
        messagebox.showwarning("Error", "Seleccione un archivo primero")
        return
    
    try:
        with open(input_file) as f:
            lines = f.readlines()
        
        # Preprocesamiento (2 pasadas)
        clean_lines, labels = preprocess_asm(lines)
        binary_lines = []
        
        # Segunda pasada: conversión
        current_addr = 0
        for line in clean_lines:
            binary = convert_asm_to_bin(line, current_addr, labels)
            if binary:
                # Dividir cada instrucción en 4 líneas
                binary_lines.extend(split_to_4_lines(binary))
                current_addr += 4
        
        output_file = filedialog.asksaveasfilename(
            defaultextension=".mem",
            filetypes=[("Memory files", "*.mem"), ("All files", "*.*")]
        )
        
        if output_file:
            with open(output_file, "w") as f:
                # Escribir 4 líneas por instrucción
                for i in range(0, len(binary_lines), 4):
                    for j in range(4):
                        if i+j < len(binary_lines):
                            f.write(binary_lines[i+j] + "\n")
                        else:
                            f.write("00000000\n")  # Padding si es necesario
            messagebox.showinfo("Éxito", f"Archivo convertido:\n{output_file}")
    
    except Exception as e:
        messagebox.showerror("Error", f"Error en conversión:\n{str(e)}")

def seleccionar_archivo():
    ruta = filedialog.askopenfilename(
        filetypes=[("Archivos ASM", "*.asm"), ("Todos los archivos", "*.*")]
    )
    if ruta:
        entry_path.delete(0, tk.END)
        entry_path.insert(0, ruta)
        try:
            with open(ruta, "r") as f:
                contenido = f.read()
                text_area.delete("1.0", tk.END)
                text_area.insert(tk.END, contenido)
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo leer el archivo:\n{str(e)}")

# Interfaz gráfica
root = tk.Tk()
root.title("Conversor ASM a Binario - MIPS (4 líneas por instrucción)")

tk.Label(root, text="Archivo ASM:").pack(pady=5)
entry_path = tk.Entry(root, width=50)
entry_path.pack(padx=10, pady=5)
tk.Button(root, text="Seleccionar", command=seleccionar_archivo).pack(pady=5)
tk.Button(root, text="Convertir", command=convert_file).pack(pady=10)

text_area = tk.Text(root, height=15, width=60)
text_area.pack(padx=10, pady=5)

root.mainloop()