# SOUL.md Verification Checklist

## After Backup Restoration

### 1. Reporting Lines
```bash
# Check all agents report to correct master
grep -i "report" ~/.hermes/profiles/*/SOUL.md

# Expected: "report directly to 米宝 (Master Control Agent)"
# NOT: "report directly to Kellen"
```

### 2. Document Paths
```bash
# Check document management paths
grep -i "tushuguan\|projects" ~/.hermes/profiles/*/SOUL.md

# Expected: "~/.hermes/tushuguan/"
# NOT: "/home/kellen/mibao/projects/<project>/"
```

### 3. Four Mechanisms Coverage
```bash
# Check each agent has all four mechanisms
for p in ~/.hermes/profiles/*/; do
  name=$(basename "$p")
  soul="$p/SOUL.md"
  echo "$name:"
  echo "  马诺防线: $(grep -c '马诺防线' "$soul") 处"
  echo "  图书馆: $(grep -c '图书馆' "$soul") 处"
  echo "  Memory管理: $(grep -c 'Memory管理' "$soul") 处"
  echo "  子Agent超时: $(grep -c '子Agent超时' "$soul") 处"
done
```

### 4. Cross-Reference with Mechanism Documents
- Document paths MUST match `~/.hermes/tushuguan/` (from 图书馆文档管理机制)
- Reporting lines MUST match current agent hierarchy
- All four mechanisms MUST be referenced (from four-mechanisms SKILL.md)

### 5. Common Fixes

| Issue | Detection | Fix Command |
|-------|-----------|-------------|
| Wrong document path | `grep -r "mibao/projects" ~/.hermes/profiles/` | `sed -i 's\|/home/kellen/mibao/projects/<project>/\|~/.hermes/tushuguan/\|g' SOUL.md` |
| Wrong reporting line | `grep -i "kellen" ~/.hermes/profiles/*/SOUL.md` | `sed -i 's/report directly to Kellen/report directly to 米宝/g' SOUL.md` |
| Missing mechanisms | `grep -c '马诺防线' SOUL.md` returns 0 | Add four mechanisms section to SOUL.md |
