ชื่อที่เหมาะ:

skills/change-impact-analysis/SKILL.md

ใจความ:

Before modifying shared code, API contracts, DB schema, proto, service methods, or middleware:
1. Identify direct callers.
2. Identify imports/dependents.
3. Identify tests affected.
4. Identify API / gRPC / frontend/mobile impact.
5. Identify migration or backward compatibility risk.
6. Summarize impact before editing.

อันนี้ผูกกับ SocratiCode graph commands ได้เลย:

codebase_graph_query
codebase_graph_stats
codebase_symbol
codebase_search

นี่คือจุดที่ repo คุณจะ “production-aware” ไม่ใช่แค่ prompt สวย ๆ ให้บอททำท่าคิดลึกเหมือนกำลังประชุมสถาปัตยกรรมจักรวาล