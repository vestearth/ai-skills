rules/evidence-required.md

อันนี้ควรเป็น global rule มากกว่า skill

ใจความ:

When making claims about the codebase, the agent must provide evidence:
- file path
- symbol/function/type name
- line range if available
- command/tool used
- result summary

ตัวอย่าง claim ที่ต้องมี evidence:

This function is unused.
This endpoint is already implemented.
This service is safe to refactor.
This dependency is not needed.
This bug comes from X.

ห้ามตอบลอย ๆ แบบ:

Looks like this is unused.

เพราะ “looks like” ในปาก AI บางทีก็แปลว่า “ผมเดาอย่างมั่นใจและหวังว่าคุณจะไม่เปิด grep เช็ก”