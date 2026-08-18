# 04 — Measure Pause as the key, switch if it passes

**What to build:** a measured answer to whether Pause can replace F12 as the
push to talk key, and the switch itself if the answer is yes. Needs a
measurement, not an opinion. Some keyboards send Pause press and release
together, which makes hold to talk impossible.

Test: watch `/dev/input/event*` for code 119, hold Pause for about 3 seconds, and
check whether the release event lands on the physical release or immediately.
Hold F12 the same way as a control, so the method is known good.

If Pause passes, change `KEY` and `KEYCODE` in `ptt`'s variable block to Pause
and 119, and change both binds in `machine.lua` to match. That is the whole
switch, which is the point of the variable block. If Pause fails, F12 stays and
this ticket closes with the measurement written down.

Either way, record the result in this file. The next person should not have to
re-run it.

`~/.config/hypr` is a real repo with an unrelated dirty file. Do not stage it and
do not commit.

**Blocked by:** 02 — the variable block and the binds have to exist before the
key can be swapped.

**Status:** ready-for-agent

- [ ] Pause held ~3s, release event timing observed on `/dev/input/event*` for code 119
- [ ] F12 run as a control with the same method
- [ ] Result written into this file, pass or fail
- [ ] If pass: `KEY`/`KEYCODE` updated in `ptt`, both binds updated in `machine.lua`, hold to talk verified end to end on Pause
- [ ] If fail: F12 stays, no code changed
