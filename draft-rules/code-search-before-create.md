1. code-search-before-create

ให้แตกออกมาจาก search-first

ชื่อที่เหมาะกับ:

rules/code-search-before-create.md

ใจความ:

Before creating a new service/helper/interface/DTO/middleware/hook/config:
1. Search the codebase first.
2. Check naming variants.
3. Check existing package/module conventions.
4. Reuse or extend existing implementation if possible.
5. Only create new code when evidence shows no suitable existing code.

เหมาะกับ SocratiCode มาก เพราะสั่งให้ agent ใช้ codebase_search, codebase_symbol, หรือ graph ก่อนเขียนใหม่

เพราะมันควรทำตลอด ก่อนสร้าง:

service
helper
interface
DTO
middleware
config
hook
script

ไม่ใช่เรียกเฉพาะบางครั้ง