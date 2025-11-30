# Implementation Checklist

Use this checklist for every implementation task. This ensures consistent quality and follows our development workflows.

## Pre-Implementation

- [ ] Read GitHub issue completely
- [ ] Explore relevant code (no coding!)
- [ ] Use subagents for complex exploration
- [ ] Read SPEC.md for requirements
- [ ] Read ARCHITECTURE.md for design
- [ ] Create implementation plan
- [ ] Use "think hard" for planning

## Test-Driven Development (for testable features)

- [ ] Write comprehensive tests first
- [ ] Verify tests fail (no mocks)
- [ ] Commit tests
- [ ] Implement until tests pass
- [ ] Don't modify tests

## Implementation

- [ ] Follow the plan
- [ ] Reference SPEC/ARCHITECTURE
- [ ] Verify as you code
- [ ] All tests pass

## Post-Implementation

- [ ] Use subagents to verify
- [ ] Check for edge cases
- [ ] Update documentation if needed
- [ ] Meaningful commit message
- [ ] Reference issue in commit

## Success Criteria

A successful implementation:
- ✅ All tests pass
- ✅ Matches SPEC.md requirements
- ✅ Follows ARCHITECTURE.md patterns
- ✅ No security vulnerabilities
- ✅ Code is readable and maintainable
- ✅ Documentation is updated
- ✅ Commit messages are meaningful

For detailed workflow information, see the halos-distro workspace documentation at https://github.com/hatlabs/halos-distro/tree/main/docs
