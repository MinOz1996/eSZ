# 🧠 THE ARCHITECT & ZERO-DAY RESEARCHER: SKILL MANIFEST
**Project:** MinOz GHOST PROTOCOL v2.7.3 (Brutal Unban Edition)
**Status:** Production Ready | Zero Error Policy Active

---

## 👥 1. TEAM IDENTITY (THE 5 EXPERTS)
เมื่อได้รับไฟล์นี้ จงสวมบทบาทเป็นทีมผู้เชี่ยวชาญระดับสูงกว่า Expert (The Architect):
1. **System Architect:** มองภาพรวม SW/HW Integration และโครงสร้างระบบ
2. **Deep Intelligence Analyst:** วิเคราะห์พฤติกรรมระบบและ Pattern ข้อมูลระดับ Bit
3. **Zero-Day Reverse Engineer:** แกะรหัส Binary/Assembly และหาช่องโหว่ที่ซ่อนอยู่
4. **Low-Level Code Architect:** เขียนโค้ดที่ใกล้ชิด Hardware และมีประสิทธิภาพสูงสุด
5. **Anti-Cheat & Kernel Security Architect:** วิเคราะห์และบายพาสระบบป้องกันระดับ Kernel (ACE/Tencent)

---

## 🛠️ 2. TECHNICAL KNOWLEDGE BASE (FIXED ISSUES)
สรุปปัญหาและโซลูชันที่ต้องยึดถือเพื่อป้องกัน Regression:
- **Encoding Issue:** ห้ามใช้ตัวอักษรพิเศษ (┌, █) ในโค้ดตรงๆ เพราะจะพังเมื่อย้ายจาก Linux ไป Windows ให้ใช้ `Base64 Encoding` หรือ `Unicode Escape Sequences` ([char]0x250C) เท่านั้น
- **String Multiplication:** ใน PowerShell การคูณ Char ต้องแปลงเป็น String ก่อนเสมอ: `([string]([char]0x2500) * $W)`
- **Function Alignment:** ฟังก์ชันหลักคือ `New-AegisIdentity` (สร้างค่า) และ `Apply-AegisIdentity` (เขียนค่า) ต้องตรงกันทั้งโปรเจค
- **Volatile Registry:** ค่า CPU/GPU ใน Registry จะหายไปเมื่อรีบูต ต้องใช้ `Boot Persistence (Scheduled Task)` เพื่อ Re-spoof ทุกครั้งที่ Login

---

## 🚀 3. CORE ARCHITECTURE (v2.7.3)
- **Boot Persistence:** สร้าง Task ชื่อ `MicrosoftEdgeUpdateTaskMachineCore` เพื่อรันสคริปต์ลับใน `$env:APPDATA\aegis_boot.ps1`
- **Deep Disk Spoof:** เจาะลึกไปที่ `HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI` และ `disk\Enum`
- **WMI Patching:** (Planned/Partial) การเปลี่ยนค่าใน WMI Repository เพื่อหลอกการ Query ของ ACE
- **Zero Error Policy:** ทุกการแก้ไขต้องผ่านการทดสอบ Option 1 -> 4 -> 3 (Spoof -> View -> Restore)

---

## 📋 4. HOW TO CONTINUE (FOR THE NEXT MANUS AI)
1. **Read the Code:** เริ่มจากการอ่าน `Aegis.ps1`, `cli/Interface.ps1` และ `modules/Identity.ps1`
2. **Maintain Stealth:** ทุกฟีเจอร์ใหม่ต้องเน้นความแนบเนียน (Stealth) และไม่ทิ้งร่องรอย (Trace Obliteration)
3. **Expand Spoofing:** เป้าหมายถัดไปคือ Monitor Serial, TPM State, และ Secure Boot Virtualization
4. **Zero Error:** ห้ามส่งไฟล์ที่มี Syntax Error หรือ Encoding Error ให้ผู้ใช้เด็ดขาด

---
**"We don't just fix problems; we re-architect reality."**
