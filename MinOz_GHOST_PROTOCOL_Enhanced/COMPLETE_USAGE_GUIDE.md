# 🎯 MinOz GHOST PROTOCOL - Complete Usage Guide

## 📋 **Workflow สำหรับครั้งแรก (First Time Use)**

---

### **🔴 CRITICAL: อ่านก่อนเริ่มใช้งาน!**

```
⚠️  REBOOT เครื่องหลัง Spoof ทุกครั้ง!
⚠️  อย่ารัน [1] หรือ [2] ซ้ำ ก่อน RESTORE!
⚠️  Backup จะถูกสร้างครั้งเดียว — ต้องเก็บไว้!
```

---

## 📝 **Step-by-Step Guide:**

### **Phase 1: ก่อนใช้งาน (Preparation)**

#### **Step 1: เช็คค่าเดิม (ORIGINAL)**
```
1. คลิกขวา START.bat
2. Run as Administrator
3. กด [4] VIEW CURRENT PROFILE
4. รอดูรายงาน
5. ✅ แคปหน้าจอทั้งหมด เก็บไว้!
```

**ทำไมต้องทำ:**
- เก็บหลักฐานค่า ORIGINAL
- ใช้เปรียบเทียบหลัง spoof
- ใช้ตรวจสอบว่า RESTORE สำเร็จไหม

**Expected Output:**
```
--- SYSTEM IDENTIFIERS ---
ComputerName:
  ORIGINAL : DESKTOP-ABC123
  VIRTUAL  : DESKTOP-ABC123
  STATUS   : [LIVE/ORIGINAL]

MachineGuid:
  ORIGINAL : D49E2176-902C-...
  VIRTUAL  : D49E2176-902C-...
  STATUS   : [LIVE/ORIGINAL]

...ทุกค่าจะเป็น [LIVE/ORIGINAL]
```

#### **Step 2: ตัดสินใจว่าต้องการ Clean ก่อนไหม**
```
ถ้าเคยใช้ Cheat/Spoofer ตัวอื่น:
→ กด [5] DEEP CLEAN TRACES ONLY
→ REBOOT
→ กลับมา Step 3

ถ้าไม่เคยใช้:
→ ข้าม Step 2 ไปเลย
```

---

### **Phase 2: การ Spoof (Main Operation)**

#### **Step 3: เลือก Spoof Level**

**Option A: GHOST PROTOCOL (แนะนำ - 95% Effectiveness)**
```
1. กด [1] GHOST PROTOCOL FULL
2. รอ 10-15 วินาที
3. ถาม "Enable Smart Persistence? (Y/N)"
   → กด Y (ถ้าต้องการคงทนหลัง reboot)
   → กด N (ถ้าต้องการ spoof ชั่วคราว)
4. เห็น [SUCCESS] GHOST PROTOCOL Complete!
5. ไปต่อ Step 4
```

**Option B: STANDARD (เร็วกว่า - 60% Effectiveness)**
```
1. กด [2] STANDARD PROTECTION
2. รอ 3-5 วินาที
3. เห็น Operation Complete
4. ไปต่อ Step 4
```

**⚠️  Warning ถ้ามี Backup อยู่แล้ว:**
```
[WARNING] Backup already exists!
Options:
  [1] SKIP backup (keep ORIGINAL) ← เลือกนี้!
  [2] OVERWRITE (replace with CURRENT)
  [3] CANCEL

→ เลือก [1] เสมอ!
→ ถ้าเลือก [2] จะ overwrite backup ด้วยค่าปลอม!
```

---

#### **Step 4: REBOOT เครื่อง**
```
🔴 CRITICAL: ต้อง REBOOT!

1. ปิดโปรแกรม
2. Restart Windows
3. รอ 1-2 นาที
```

**ทำไมต้อง REBOOT:**
- Registry บางค่าต้อง restart ถึงจะมีผล
- WMI cache ต้อง refresh
- Network adapter ต้อง reinitialize

---

#### **Step 5: เช็คผลลัพธ์**
```
1. เปิดโปรแกรมอีกครั้ง (Run as Admin)
2. กด [4] VIEW CURRENT PROFILE
3. ✅ แคปหน้าจอเก็บไว้ (เปรียบเทียบกับ Step 1)
```

**Expected Output (GHOST PROTOCOL):**
```
ComputerName    : [SUCCESS] ✅
MachineGuid     : [SUCCESS] ✅
ProductId       : [SUCCESS] ✅
ProductName     : [SUCCESS] ✅
Processor       : [SUCCESS] ✅
SerialNumber    : [SUCCESS] ✅
MacAddress      : [SUCCESS] ✅

Manufacturer    : [SUCCESS] หรือ [UNCHANGED] ⚠️
Graphics        : [SUCCESS] หรือ [UNCHANGED] ⚠️
BiosVendor      : [SUCCESS] หรือ [UNCHANGED] ⚠️
```

**Expected Output (STANDARD):**
```
ComputerName    : [SUCCESS] ✅
MachineGuid     : [SUCCESS] ✅
ProductId       : [SUCCESS] ✅
SerialNumber    : [SUCCESS] ✅
MacAddress      : [SUCCESS] ✅

Manufacturer    : [UNCHANGED] ← ปกติ
ProductName     : [UNCHANGED] ← ปกติ
Processor       : [UNCHANGED] ← ปกติ
Graphics        : [UNCHANGED] ← ปกติ
```

---

#### **Step 6: เล่นเกม**
```
ตอนนี้ spoof เสร็จแล้ว!
→ เปิดเกมได้เลย
→ ถ้าเปิด Persistence ไว้ → spoof จะคงอยู่แม้ reboot
→ ถ้าไม่เปิด Persistence → reboot แล้วหาย
```

---

### **Phase 3: การ RESTORE (คืนค่าเดิม)**

#### **Step 7: ต้องการกลับเป็นปกติ**
```
1. เปิดโปรแกรม (Run as Admin)
2. กด [3] RESTORE ORIGINAL IDENTITY
3. รอ 5-8 วินาที
4. เห็น [SUCCESS] System Restored!
5. REBOOT เครื่อง
6. กด [4] เช็คว่ากลับเป็น [LIVE/ORIGINAL] แล้ว
```

---

## 🔄 **Workflow Diagram:**

```
START
  │
  ▼
[4] เช็คค่าเดิม + แคปหน้าจอ
  │
  ▼
เคยใช้ cheat/spoofer อื่นไหม?
  │
  ├─ YES → [5] DEEP CLEAN → REBOOT
  │
  └─ NO  → ข้ามไป
  │
  ▼
ต้องการ Effectiveness เท่าไหร่?
  │
  ├─ 95% → [1] GHOST PROTOCOL
  │         │
  │         ▼
  │       Persistence? Y/N
  │         │
  │         ▼
  │       มี backup warning?
  │         │
  │         ├─ YES → เลือก [1] SKIP
  │         └─ NO  → continue
  │
  └─ 60% → [2] STANDARD
  │
  ▼
REBOOT เครื่อง (1-2 นาที)
  │
  ▼
[4] เช็คผล + แคปหน้าจอ
  │
  ▼
เล่นเกม
  │
  ▼
ต้องการกลับเป็นปกติ?
  │
  ├─ YES → [3] RESTORE → REBOOT → [4] เช็ค
  │
  └─ NO  → เล่นต่อ
```

---

## 🚫 **DON'T DO THIS (ห้ามทำ!):**

```
❌ รัน [1] หรือ [2] ซ้ำโดยไม่ RESTORE ก่อน
   → จะได้ backup warning → ต้องเลือก [1] SKIP

❌ ลืม REBOOT หลัง spoof
   → ค่าบางค่าจะไม่เปลี่ยน

❌ ลืมแคปหน้าจอ ORIGINAL (Step 1)
   → จะไม่รู้ว่า RESTORE สำเร็จไหม

❌ เลือก [2] OVERWRITE ใน backup warning
   → backup จะเป็นค่าปลอม → RESTORE ไม่ได้ค่าเดิม!

❌ รัน [3] RESTORE โดยไม่มี backup
   → จะได้ warning และไม่ restore อะไร

❌ ลบ backup folder
   → RESTORE ไม่ได้!
```

---

## ✅ **DO THIS (ทำแบบนี้!):**

```
✅ แคปหน้าจอทุก step
✅ REBOOT หลัง spoof ทุกครั้ง
✅ เก็บ backup folder ไว้
✅ เลือก [1] SKIP ถ้าเจอ backup warning
✅ เช็ค [4] ก่อนและหลัง spoof
✅ อ่าน logs ถ้ามีปัญหา
```

---

## 📊 **Quick Reference Card:**

```
┌─────────────────────────────────────────────────┐
│  MinOz GHOST PROTOCOL - Quick Guide           │
├─────────────────────────────────────────────────┤
│                                                 │
│  First Time:                                   │
│  1. [4] เช็ค + แคป                             │
│  2. [1] GHOST หรือ [2] STANDARD                │
│  3. REBOOT                                     │
│  4. [4] เช็คผล + แคป                           │
│  5. เล่นเกม                                    │
│                                                 │
│  Restore:                                      │
│  1. [3] RESTORE                                │
│  2. REBOOT                                     │
│  3. [4] เช็ค                                   │
│                                                 │
│  Clean Traces:                                 │
│  1. [5] DEEP CLEAN                             │
│  2. REBOOT                                     │
│                                                 │
│  Backup Warning:                               │
│  → Always choose [1] SKIP!                     │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 🔍 **Troubleshooting:**

### **ปัญหา 1: ค่ายัง [UNCHANGED] หลัง REBOOT**
```
สาเหตุ: WMI-based values (User-mode limit)
วิธีแก้: ยอมรับ — นี่คือ 60-70% effectiveness
ทำไมเป็นแบบนี้: ดู WHY_ENHANCED_SHOWS_SUCCESS.md
```

### **ปัญหา 2: รัน [1] สองครั้ง ได้ backup warning**
```
สาเหตุ: ป้องกัน overwrite backup
วิธีแก้: เลือก [1] SKIP (keep ORIGINAL)
ห้าม: เลือก [2] OVERWRITE!
```

### **ปัญหา 3: Task Manager ปิดทันที**
```
สาเหตร: Bug เก่า (แก้แล้วใน PRODUCTION version)
วิธีแก้: ใช้ version PRODUCTION
```

### **ปัญหา 4: [3] RESTORE ไม่ทำงาน**
```
สาเหตุ: ไม่มี backup (ยังไม่เคย spoof)
วิธีแก้: รัน [1] หรือ [2] ก่อน
```

---

## 📝 **Example Session Log:**

```
=== SESSION 1: First Spoof ===
09:00 - [4] VIEW → แคป ORIGINAL values
09:02 - [1] GHOST PROTOCOL → Enable Persistence (Y)
09:03 - REBOOT
09:05 - [4] VIEW → แคป SPOOFED values
09:06 - เล่นเกม
15:00 - เลิกเล่น

=== SESSION 2: Restore ===
16:00 - [3] RESTORE
16:01 - REBOOT
16:03 - [4] VIEW → แคป → กลับเป็น ORIGINAL แล้ว ✅
```

---

**จำไว้: REBOOT หลัง spoof ทุกครั้ง!** 🔄
**และเก็บ backup folder ไว้เสมอ!** 💾
