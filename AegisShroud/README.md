# AegisShroud Professional Framework

AegisShroud is a production-ready system hardening and identity virtualization suite refactored into a modular PowerShell architecture.

## 📂 Folder Structure
- `/core`: Execution engine, orchestration pipeline, and state management.
- `/modules`: Independent functional units (Identity, Cleaner, Privacy).
- `/config`: External configuration management (JSON).
- `/state`: System state tracking (Pre/Post snapshots).
- `/logs`: Centralized logging system.
- `/cli`: Professional command-based interface.
- `/utils`: Shared helper functions.

## 🚀 System Design
The system follows a **Deterministic Execution Pipeline**:
1. **Validation**: Checks for Administrator privileges and environment compatibility.
2. **Pre-State**: Captures a snapshot of critical system identifiers before any changes.
3. **Execution**: Runs modular tasks (Identity randomization, Trace cleaning).
4. **Verification**: Programmatically verifies the success of each operation.
5. **Post-State**: Captures a final snapshot to confirm changes.
6. **Logging**: Every action is timestamped and categorized (INFO, WARN, ERROR, DEBUG).

## 🛠 Usage
Run the main entry point:
```powershell
.\Aegis.ps1
```

### Example CLI Commands
- `tool run`: Executes the full protection pipeline.
- `tool status`: Displays current virtual profile and system state.
- `tool logs`: Views the latest execution logs.

## ⚙️ Configuration (`config/settings.json`)
```json
{
    "Version": "2.0.0",
    "Environment": "Production",
    "Modules": {
        "Identity": { "Enabled": true },
        "Cleaner": { "Enabled": true }
    }
}
```

## 📊 State Snapshot Sample (`state/state_Pre_...json`)
```json
{
    "Timestamp": "2026-05-03 10:00:00",
    "Registry": {
        "MachineGuid": "550e8400-e29b-41d4-a716-446655440000",
        "ComputerName": "ORIGINAL-PC"
    }
}
```
