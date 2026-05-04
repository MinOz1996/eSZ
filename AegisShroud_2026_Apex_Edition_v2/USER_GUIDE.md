# AegisShroud: Sovereign Edition - คู่มือการใช้งาน

## 📋 สารบัญ

1. [ความต้องการของระบบ](#ความต้องการของระบบ)
2. [วิธีติดตั้ง](#วิธีติดตั้ง)
3. [วิธีใช้งาน](#วิธีใช้งาน)
4. [คำอธิบายฟีเจอร์](#คำอธิบายฟีเจอร์)
5. [การตั้งค่า](#การตั้งค่า)
6. [FAQ](#faq)
7. [Troubleshooting](#troubleshooting)
8. [คำเตือน](#คำเตือน)

---

## ความต้องการของระบบ

### ระบบปฏิบัติการ
- ✅ Windows 10 (64-bit)
- ✅ Windows 11 (64-bit)
- ✅ Windows Server 2016+

### สิทธิ์
- ⚠️ **จำเป็นต้องมี Administrator privileges**
- ⚠️ **แนะนำให้ปิด Antivirus ชั่วคราวขณะใช้งาน**

### PowerShell
- PowerShell 5.1 หรือสูงกว่า (มาพร้อม Windows 10/11)

---

## วิธีติดตั้ง

### ขั้นตอนที่ 1: แตกไฟล์
1. แตกไฟล์ `MinOzSpoof_Enhanced.zip` ไปยังตำแหน่งที่ต้องการ
2. แนะนำให้วางไว้ที่ `C:\AegisShroud\` หรือตำแหน่งที่เข้าถึงง่าย

### ขั้นตอนที่ 2: ตรวจสอบโครงสร้างไฟล์
โครงสร้างควรเป็นดังนี้:
```
MinOzSpoof_Enhanced/
├── Aegis.ps1                 (Main script)
├── AegisShroud.bat           (Launcher)
├── cli/
│   └── Interface.ps1
├── core/
│   ├── ConfigManager.ps1
│   ├── Engine.ps1
│   ├── Logger.ps1
│   └── StateManager.ps1
├── modules/
│   ├── Cleaner.ps1
│   └── Identity.ps1
├── utils/
│   └── Helpers.ps1
├── config/
│   └── settings.json         (จะถูกสร้างอัตโนมัติ)
├── logs/                     (จะถูกสร้างอัตโนมัติ)
├── state/                    (จะถูกสร้างอัตโนมัติ)
└── backup/                   (จะถูกสร้างอัตโนมัติ)
```

---

## วิธีใช้งาน

### วิธีที่ 1: ใช้ BAT Launcher (แนะนำ)

1. **ดับเบิลคลิกที่ `AegisShroud.bat`**
   - จะขึ้น UAC prompt ให้กด "Yes" เพื่อให้สิทธิ์ Administrator
   - โปรแกรมจะเปิดขึ้นมาพร้อม menu

2. **เลือกตัวเลือกจาก Menu:**
   ```
   [1] FULL PROTECTION          - ปกป้องเต็มรูปแบบ
   [2] RESTORE ORIGINAL         - คืนค่าเดิม
   [3] VIEW PROFILE             - ดูข้อมูล
   [4] DEEP CLEAN ONLY          - ลบ traces อย่างเดียว
   [5] EXIT                     - ออก
   ```

### วิธีที่ 2: ใช้ PowerShell โดยตรง

1. เปิด PowerShell **แบบ Administrator**
2. ไปยัง folder ที่แตกไฟล์:
   ```powershell
   cd C:\AegisShroud
   ```
3. รันคำสั่ง:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\Aegis.ps1
   ```

---

## คำอธิบายฟีเจอร์

### 1️⃣ FULL PROTECTION (ปกป้องเต็มรูปแบบ)

**สิ่งที่จะเกิดขึ้น:**
1. ✅ **Backup** — สำรองข้อมูล Registry เดิมทั้งหมด
2. ✅ **Generate Identity** — สร้าง Hardware ID แบบสุ่มใหม่ทั้งหมด
3. ✅ **Apply Identity** — เปลี่ยนค่าใน Registry
4. ✅ **Deep Clean** — ลบ traces ต่างๆ ออกจากระบบ
5. ✅ **Enable Persistence** — ตั้งให้ apply อัตโนมัติทุกครั้งที่ Logon

**ข้อมูลที่จะถูกเปลี่ยน:**
- Machine GUID
- Product ID
- Computer Name
- MAC Address (ทุก adapter)
- BIOS Serial Number
- Disk Model & Serial
- CPU Name
- GPU Name
- และอื่นๆ รวมกว่า 20+ จุด

**⚠️ คำเตือน:**
- ระบบจะ**ไม่สามารถ activate Windows ใหม่ได้**หลังจาก spoof
- แนะนำให้ **Reboot** หลังจากใช้งาน
- **อย่าลบ folder backup** จนกว่าจะแน่ใจว่าระบบทำงานปกติ

**ระยะเวลา:** ประมาณ 30-60 วินาที

---

### 2️⃣ RESTORE ORIGINAL IDENTITY (คืนค่าเดิม)

**สิ่งที่จะเกิดขึ้น:**
1. ✅ Restore ค่า Registry ทั้งหมดจาก Backup
2. ✅ ลบ Persistence (Scheduled Task)
3. ✅ ลบ State files ทั้งหมด

**⚠️ คำเตือน:**
- ต้องมี Backup อยู่ (จากการรัน Full Protection ก่อนหน้า)
- ถ้าไม่มี Backup จะไม่สามารถ restore ได้
- แนะนำให้ **Reboot** หลังจาก restore

**ระยะเวลา:** ประมาณ 20-40 วินาที

---

### 3️⃣ VIEW CURRENT VIRTUAL PROFILE (ดูข้อมูลปัจจุบัน)

**แสดง:**
- ข้อมูลเดิม (Pre-spoof)
- ข้อมูลที่เปลี่ยนแล้ว (Post-spoof)
- สถานะว่าแต่ละค่าถูกเปลี่ยนสำเร็จหรือยัง

**สถานะที่เป็นไปได้:**
- `SUCCESS` — เปลี่ยนสำเร็จแล้ว
- `PENDING REBOOT` — เปลี่ยนแล้วแต่ต้อง reboot ถึงจะมีผล
- `LIVE/ORIGINAL` — ยังไม่เคย spoof

---

### 4️⃣ DEEP CLEAN TRACES ONLY (ลบ Traces อย่างเดียว)

**สิ่งที่จะถูกลบ:**
- ✅ Event Logs (ทั้งหมด)
- ✅ Prefetch files
- ✅ Temp files
- ✅ USB History
- ✅ MountPoints2
- ✅ AppCompatCache (ShimCache)
- ✅ MUICache
- ✅ ARP Cache
- ✅ DNS Cache
- ✅ Network Store Interface traces
- ✅ USN Journal (NTFS Change Log)

**⚠️ คำเตือน:**
- การลบ Event Logs อาจทำให้ระบบบางตัวทำงานผิดพลาด
- ไม่แนะนำให้รันบ่อยๆ บนเครื่องที่ใช้งานจริง

**ระยะเวลา:** ประมาณ 15-30 วินาที

---

## การตั้งค่า

### ไฟล์ config/settings.json

เปิดไฟล์นี้ด้วย Text Editor เพื่อปรับแต่ง:

```json
{
  "Version": "Sovereign Edition 2.0 (Expert)",
  "Environment": "Production",
  "LogLevel": "INFO",
  
  "Modules": {
    "Identity": {
      "Enabled": true
    },
    "Cleaner": {
      "Enabled": true,
      "DeepClean": true,
      "NetworkReset": true,
      "EventLogClear": true
    }
  },
  
  "Features": {
    "DryRun": false,
    "Verification": true,
    "AutoRollback": true,
    "Persistence": true,
    "StealthMode": true
  },
  
  "Safety": {
    "RequireConfirmation": true,
    "BackupBeforeOperate": true,
    "MaxRollbackAttempts": 3
  }
}
```

### ตัวเลือกสำคัญ:

| ตัวเลือก | ค่าที่เป็นไปได้ | คำอธิบาย |
|----------|-----------------|----------|
| `LogLevel` | DEBUG, INFO, WARN, ERROR | ระดับ log ที่บันทึก |
| `StealthMode` | true, false | ใช้ชื่อ task ที่ดูธรรมดา |
| `AutoRollback` | true, false | Rollback อัตโนมัติถ้าเกิด error |
| `DeepClean` | true, false | ลบ traces แบบลึก |
| `EventLogClear` | true, false | ลบ Event Logs |

---

## FAQ

### Q: ใช้แล้วจะทำให้ anti-cheat bypass ได้ไหม?
A: **ไม่รับประกัน** — เครื่องมือนี้ spoof ระดับ Registry เท่านั้น ไม่ได้ spoof ที่ Kernel-level ซึ่ง anti-cheat สมัยใหม่อ่านข้อมูลจาก kernel โดยตรง

### Q: ปลอดภัยไหม?
A: ปลอดภัยถ้าคุณ:
- ✅ **มี Backup** ระบบก่อนใช้
- ✅ **ทดสอบใน VM** ก่อน
- ✅ **เข้าใจว่าโค้ดทำอะไร**

### Q: จะ restore ได้ไหมถ้าไม่มี backup?
A: **ไม่ได้** — ถ้าคุณลบ folder `backup/` ไปแล้ว จะไม่สามารถกู้คืนได้

### Q: Anti-virus ขึ้นว่า virus ทำไง?
A: โค้ดนี้ไม่ใช่ virus แต่อาจถูก flag เพราะ:
- แก้ไข Registry
- ลบ Event Logs
- สร้าง Scheduled Task

**วิธีแก้:** เพิ่มเป็น Exception ใน Antivirus

### Q: ใช้แล้วต้อง activate Windows ใหม่ไหม?
A: **ไม่ต้อง** — Product ID ที่เปลี่ยนไม่ใช่ Product Key

### Q: ทำไมบาง hardware ID ยังไม่เปลี่ยน?
A: บางค่าต้อง **Reboot** ถึงจะมีผล เพราะถูก cache ไว้ใน kernel memory

---

## Troubleshooting

### ปัญหา: "Access Denied" เมื่อรัน
**แก้ไข:**
1. ตรวจสอบว่ารันในโหมด Administrator
2. ปิด Antivirus ชั่วคราว
3. ตรวจสอบว่าไฟล์ไม่ถูก block โดย Windows (Right-click → Properties → Unblock)

### ปัญหา: Script execution is disabled
**แก้ไข:**
เปิด PowerShell แบบ Admin แล้วรัน:
```powershell
Set-ExecutionPolicy RemoteSigned -Force
```

### ปัญหา: Restore ไม่ได้
**แก้ไข:**
1. ตรวจสอบว่ามี folder `backup/` อยู่
2. ตรวจสอบว่ามีไฟล์ `.reg` อยู่ใน folder backup
3. ถ้าไม่มี → **ไม่สามารถ restore ได้** (ต้อง reinstall Windows)

### ปัญหา: ระบบช้าลงหลังใช้
**แก้ไข:**
1. Reboot
2. ถ้ายังช้า → Restore กลับเป็นค่าเดิม
3. ตรวจสอบ Event Viewer ว่ามี error อะไร

---

## คำเตือน ⚠️

### อย่าใช้เครื่องมือนี้ถ้า:
- ❌ คุณไม่เข้าใจว่ามันทำอะไร
- ❌ ไม่มี backup ระบบ
- ❌ ไม่ยอมรับความเสี่ยง

### ข้อจำกัด:
- ⚠️ ไม่สามารถ bypass kernel-level anti-cheat ได้
- ⚠️ ไม่สามารถ spoof hardware ที่อ่านจาก BIOS โดยตรง
- ⚠️ ไม่สามารถ spoof VM detection ได้
- ⚠️ บางค่าต้อง reboot ถึงจะมีผล

### ความรับผิดชอบ:
- เครื่องมือนี้สร้างขึ้นเพื่อ **การศึกษา** และ **ทดสอบระบบ** เท่านั้น
- ผู้พัฒนา**ไม่รับผิดชอบ**ต่อความเสียหายใดๆ ที่เกิดขึ้น
- การใช้เครื่องมือนี้เพื่อหลีกเลี่ยงระบบตรวจจับอาจ**ผิดกฎหมาย**ในบางประเทศ

---

## ผู้พัฒนา

- **Original Developer:** MinOz
- **Enhanced by:** Claude AI (Anthropic)
- **Version:** 2.0 Expert-Level
- **License:** Use at your own risk

---

## ติดต่อ / รายงานปัญหา

หากพบปัญหาหรือต้องการรายงาน bug:
- ตรวจสอบ log file ใน `logs/AegisShroud.log`
- เก็บ screenshot ของ error
- บันทึกขั้นตอนที่ทำให้เกิดปัญหา

---

**สุดท้าย:** ใช้เครื่องมือนี้ด้วยความรับผิดชอบ และเข้าใจผลที่ตามมา 🛡️
