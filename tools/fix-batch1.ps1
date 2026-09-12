# Batch 1 fixes: surgical raw-text replacements with assertion counts.
# Run from anywhere; paths are absolute.
$ErrorActionPreference = 'Stop'
$base = "D:\XOS\Desktop\跑团进行中\classpack\dnd5e_classpack\packs"
$utf8 = New-Object System.Text.UTF8Encoding($false)

$fixes = @()

# Helper: each fix = @{ File = <absolute path or null for glob>; Glob = <glob under base>; Find = regex; Replace = string; Expect = int; Name = description }
function Add-Fix($name, $glob, $find, $replace, $expect) {
    $script:fixes += @{ Name = $name; Glob = $glob; Find = $find; Replace = $replace; Expect = $expect }
}

# 1. Bladesong: advantage.skills.acr -> advantage.skill.acr
Add-Fix 'Bladesong skills.acr' 'extra-ability\法师_EMv6nD43KyKEGCH0\剑咏者_p6wdRXK9aVCbH0eK\*.json' 'flags\.midi-qol\.advantage\.skills\.acr' 'flags.midi-qol.advantage.skill.acr' 1

# 2. Fiendish Spirit x3: advantage.ability.save.all "" -> magicResistance.all 1
Add-Fix 'Fiendish Spirit magicResistance' 'summons\邪魔召唤术Summon Fiend (TCE)_2X2TLfg93T64W1Xr\*.json' '"key": "flags\.midi-qol\.advantage\.ability\.save\.all",\s*\r?\n\s*"mode": 2,\s*\r?\n\s*"value": ""' "`"key`": `"flags.midi-qol.magicResistance.all`",`r`n          `"mode`": 2,`r`n          `"value`": `"1`"" 3

# 3. Slaadi x6: disadvantage.ability.check.all -> disadvantage.check.all
Add-Fix 'Slaadi check.all' 'monster\MM14 怪物 需汉化_fMal9OEom9YXkKMD\异怪_AjUHdLOzzEfNN7Jd\*.json' 'flags\.midi-qol\.disadvantage\.ability\.check\.all' 'flags.midi-qol.disadvantage.check.all' 6

# 4. Eclipse of Ill Omen: disadvantage.attack.save -> disadvantage.save.all
Add-Fix 'Eclipse save.all' 'extra-ability\牧师_8pfcG1qRw4Ec0oT2\月亮领域_P1ZcWSWwfGiocbre\*月蚀*.json' 'flags\.midi-qol\.disadvantage\.attack\.save' 'flags.midi-qol.disadvantage.save.all' 1

# 5. Stroke of Luck: check.fail.all -> check.all
Add-Fix 'Stroke of Luck check.all' 'class-abilityphb\游荡者_Q5XSze3MoXgziMQq\*.json' 'flags\.midi-qol\.optional\.幸运一击\.check\.fail\.all' 'flags.midi-qol.optional.幸运一击.check.all' 1

# 8. Trickery Divine Strike: NAME.criticalDamage -> proper name
Add-Fix 'Trickery DS criticalDamage' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\诡术领域_WaCmhhAMFhZvj3Od\*.json' 'flags\.midi-qol\.optional\.NAME\.criticalDamage' 'flags.midi-qol.optional.神圣打击（诡术）.criticalDamage' 1

# 10. Empowered Evocation: sourceClass -> sourceItem
Add-Fix 'Empowered Evocation sourceItem' 'class-abilityphb\法师_rqhKfWIjbYxdIi6T\塑能学派_E2Z5FZNCPpp2Es13\*.json' [regex]::Escape("item.sourceClass === 'wizard'") "item.sourceItem === 'class:wizard'" 1

# 11. Potent Spellcasting
Add-Fix 'Potent Spellcasting force' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\*.json' [regex]::Escape('item.level === 0 && item.sourceClass === ''cleric''&& item.itemType === "spell"') "item.level === 0 && item.sourceItem === 'class:cleric'" 1

# 12. Arcane Firearm
Add-Fix 'Arcane Firearm force' 'extra-ability\奇械师_rVoqmwb7mLMxqe4c\魔炮师_zBGtsIBKuneeh8zh\*.json' [regex]::Escape('item.itemType === "spell" && item.sourceClass === ''artificer''') "item.sourceItem === 'class:artificer'" 1

# 13. Supreme Healing typo
Add-Fix 'Supreme Healing force' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\生命领域_ekBsIjtT8dTU1Hdy\*极效治疗*.json' [regex]::Escape('item.itenType === "spell"') 'item.level > 0' 1

# 14a. Disciple of Life activation
Add-Fix 'Disciple of Life activation' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\生命领域_ekBsIjtT8dTU1Hdy\*生命门徒*.json' [regex]::Escape('item.level > 0 && item.itemType === "spell"') 'item.level > 0' 1

# 15a. Overchannel count
Add-Fix 'Overchannel count' 'class-abilityphb\法师_rqhKfWIjbYxdIi6T\塑能学派_E2Z5FZNCPpp2Es13\*.json' '"value": "ItemUses\.超限导能"' '"value": "ItemUses.超限导能 Overchannel"' 1

# 15b. Overchannel activation harden
Add-Fix 'Overchannel activation' 'class-abilityphb\法师_rqhKfWIjbYxdIi6T\塑能学派_E2Z5FZNCPpp2Es13\*.json' [regex]::Escape("item.school === 'evo' && item.sourceClass === 'wizard' && workflow.castData.castLevel <= 5 && item.level > 0") "item.school === 'evo' && item.sourceItem === 'class:wizard' && (workflow.castData?.castLevel ?? 9) <= 5 && item.level > 0" 1

# 16. Indomitable count
Add-Fix 'Indomitable count' 'class-abilityphb\战士_0Iyyl84LrEbKBK1I\*.json' '"value": "ItemUses\.buqu"' '"value": "ItemUses.不屈 Indomitable"' 1

# 17. Guided Strike + Destructive Wrath count
Add-Fix 'Cleric CD counts' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\*.json' '"value": "ItemUses\.引导神力 Channel Divinity"' '"value": "ItemUses.引导神力 (牧师)"' 2

# 18. Tempest Divine Strike count
Add-Fix 'Tempest DS count' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\风暴领域_69kHgFUkU3qQZigm\*.json' '"value": "ItemUses\.神圣打击（风暴）"' '"value": "ItemUses.神圣打击（风暴）Divine Strike"' 1

# 19. Mind Sharpener count
Add-Fix 'Mind Sharpener count' 'extra-ability\奇械师_rVoqmwb7mLMxqe4c\奇械师注法_wzUdvMZs4LPV4ShM\*.json' '"value": "itemUse\.思维砥石"' '"value": "ItemUses.partialNameMatch.注法：思维砥石"' 1

# 20. Divine Strike x4: +1@scale -> +@scale ; and [poisoned] -> [poison] in trickery
Add-Fix 'Divine Strike scale prefix' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\*.json' '\+1@scale\.cleric\.divine-strike\[' '+@scale.cleric.divine-strike[' 6
Add-Fix 'Trickery DS poison type' 'class-abilityphb\牧师_r8VWrLGF90xOOzOA\诡术领域_WaCmhhAMFhZvj3Od\*.json' '\+@scale\.cleric\.divine-strike\[poisoned\]' '+@scale.cleric.divine-strike[poison]' 2

# 25a. OverTime DC path fix (spelldc removed in dnd5e 4.x+)
Add-Fix 'OverTime spelldc' '*' 'saveDC=@attributes\.spelldc' 'saveDC=@attributes.spell.dc' 4

# 25b. Nature''s Wrath multi-ability save
Add-Fix "Nature's Wrath saveAbility" 'class-abilityphb\圣武士_w0ZwAIAMmfHw8zKQ\古贤之誓_vwDvCpIHYZNhOxTd\*.json' 'saveAbility=str,dex' 'saveAbility=str|dex' 1

# 25c. Wrathful Smite stray damageType
Add-Fix 'Wrathful Smite damageType' 'spell\PHB 玩家手册_hSoScUNgYYqpKuFk\1环_UpyidlPmP73pCiWN\*Wrathful Smite*.json' 'damageType=fire, ' '' 1

# 25d. saveRemove=true -> saveCount=1 (deprecated key migration)
Add-Fix 'OverTime saveRemove=true' '*' 'saveRemove=true' 'saveCount=1' 5

# 22c. Contagion Filth Fever: attack.mwak -> attack.str (Str-based attacks)
Add-Fix 'Filth Fever attack.str' 'spell\PHB 玩家手册_hSoScUNgYYqpKuFk\5环_dP07MxenLzAZwePt\*Contagion*.json' 'flags\.midi-qol\.disadvantage\.attack\.mwak' 'flags.midi-qol.disadvantage.attack.str' 1

# 22d. Contagion Seizure: advantage.attack.dex -> disadvantage.attack.dex
Add-Fix 'Seizure disadvantage dex' 'spell\PHB 玩家手册_hSoScUNgYYqpKuFk\5环_dP07MxenLzAZwePt\*Contagion*.json' 'flags\.midi-qol\.advantage\.attack\.dex' 'flags.midi-qol.disadvantage.attack.dex' 1

# 22a/22b. Contagion empty save flags
Add-Fix 'Mindfire save.int value' 'spell\PHB 玩家手册_hSoScUNgYYqpKuFk\5环_dP07MxenLzAZwePt\*Contagion*.json' '"key": "flags\.midi-qol\.disadvantage\.save\.int",\s*\r?\n\s*"mode": 2,\s*\r?\n\s*"value": ""' "`"key`": `"flags.midi-qol.disadvantage.save.int`",`r`n          `"mode`": 2,`r`n          `"value`": `"1`"" 1
Add-Fix 'Slimy Doom save.con value' 'spell\PHB 玩家手册_hSoScUNgYYqpKuFk\5环_dP07MxenLzAZwePt\*Contagion*.json' '"key": "flags\.midi-qol\.disadvantage\.save\.con",\s*\r?\n\s*"mode": 2,\s*\r?\n\s*"value": ""' "`"key`": `"flags.midi-qol.disadvantage.save.con`",`r`n          `"mode`": 2,`r`n          `"value`": `"1`"" 1

# 24. Spirit Shroud damage formula + description (TCE: +1d8 per level above 3rd)
Add-Fix 'Spirit Shroud formula' 'spell\TCE 塔莎的万事坩埚_eKWjH0NyoSjvzeog\3环_AxRx3cjmq2V2NJQQ\*Spirit Shroud*.json' '\(\(@scaling\+1\)\/2\)d8' '(@scaling+1)d8' 12
Add-Fix 'Spirit Shroud desc' 'spell\TCE 塔莎的万事坩埚_eKWjH0NyoSjvzeog\3环_AxRx3cjmq2V2NJQQ\*Spirit Shroud*.json' '每比三环高 2 环，其伤害就增加 1d8' '每比三环高 1 环，其伤害就增加 1d8' 1

$report = New-Object System.Collections.Generic.List[string]
foreach ($fx in $fixes) {
    $files = Get-ChildItem (Join-Path $base $fx.Glob) -Filter *.json -File | Select-Object -Unique FullName
    $total = 0; $touched = 0
    foreach ($f in $files) {
        $t = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $ms = [regex]::Matches($t, $fx.Find)
        if ($ms.Count -eq 0) { continue }
        $total += $ms.Count; $touched++
        $t = [regex]::Replace($t, $fx.Find, $fx.Replace)
        [System.IO.File]::WriteAllText($f.FullName, $t, $utf8)
        try { Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null } catch { $report.Add("JSON INVALID: $($f.Name) - $($_.Exception.Message)") }
    }
    $status = if ($total -eq $fx.Expect) { 'OK' } else { "MISMATCH (expected $($fx.Expect))" }
    $report.Add(("{0,-34} files={1} count={2}  {3}" -f $fx.Name, $touched, $total, $status))
}
$report
