# Qingniu body-composition algorithm — exact formulas

The body-composition values in MyScaleNoz come from the algorithm that the
original MyKronoz / Yolanda app ran on the phone (function `algorithm()` in the
vendor's native library `libyolanda_calc.so`). It was reconstructed by
disassembly and by running the library under ARM emulation, for
interoperability with scales whose vendor service was shut down. **No vendor
code is included in this repository** — only the recovered formulas, an
independent re-implementation, and reference numbers.

The reconstruction was verified **bit-for-bit** against the library's own
output: all 14 computed fields reproduce exactly on a 40-row reference set
(`reference.csv`) and 99.9% on a 7360-point dense grid.

Files in this folder:
- `reference.csv` — 40 rows: inputs and all 15 outputs of the original library.
- `BodyComp.java` — an independent Java implementation (matches reference.csv).
- `final_model.py` — the same model in Python.
- `JavaTest.java` — JVM harness that checks a port against reference.csv.
- `java_golden.csv` — full-precision output of `BodyComp.java` on the reference
  rows plus a ~31 000-point grid (including out-of-range inputs).

The app's Dart port is `lib/core/body_comp.dart`; `test/body_comp_test.dart`
checks it against `reference.csv` (visceral to the printed 4 decimals, all other
fields exactly) and bit-for-bit against `java_golden.csv`. All math is `double`.

## Entry signature
```
algorithm(scaleType=0, reserved=0, heightCm(double), ageYears(int),
          gender(int: 1=male, 0=female), weightKg(double),
          resistance50(int), resistance500(int)) -> QNData struct
```
NOTE: gender is **1=male / 0=female** here — the OPPOSITE of the BLE wire
convention. Invert when wiring the UI.

## Input clamps (applied first by the lib)
H∈[40,240], age∈[3,80], gender→{0,1}, r50/r500 capped at 1500, W∈[40,240].

## Rounding helpers
`r1(x)=floor(x*10+0.5)/10` ; `r2(x)=floor(x*100+0.5)/100`. BMR & bodyAge truncate
toward zero (int cast). CRITICAL order: fat is computed raw then STORED rounded;
most downstream fields re-read the rounded values (`fatR, Wr, LBMr`). Exceptions:
**water and protein use the UNROUNDED clamped water value (`waterC`)**.

## Fields

### body fat % — dual-frequency
```
MALE (g=1):
  fatA = 37.088 − 0.528·H + 0.067·age + 0.05·r50 + 0.668·W
  fatB = 64.22  − 0.58·H  − 0.01·age − 0.12·r50 + 0.19·r500 + 0.51·W
  d    = (fatA−fatB > 5) ? fatA−5 : fatB
  fat  = (r500≠0) ? min(fatA,d) : fatA
FEMALE (g=0):
  fatA = 55.478 − 0.623·H + 0.058·age + 0.042·r50 + 0.831·W
  fatB = 36.23  − 0.37·H  + 0.19·age  + 0.05·r50  − 0.02·r500 + 0.53·W
  fat  = (r500≠0) ? min(fatA,fatB) : fatA
fat = clamp(fat, 5.1, 75.0)    ;   fatR = r1(fat)
```

### derived scalars
```
Wr    = r1(W)
LBMr  = r1( W·(1 − fat/100) )          # lean/fat-free mass, uses RAW fat
BMIr  = r1( W / (H/100)^2 )            # reported BMI
BMIin = Wr / (H/100)^2                 # inline BMI used only in visceral
boneRaw = (g? 0.05 : 0.06)·LBMr        # used unrounded elsewhere
bone    = r2(boneRaw)                  # reported bone kg (clamp ≥1.0 before reuse)
waterC  = clamp( (g?0.76:0.73)·(LBMr − boneRaw)/Wr·100 , 10, 80 )   # UNROUNDED, reused
water   = r1(waterC)                                               # reported water %
skelMuscle% = r1( (g?0.68:0.62)·(LBMr − boneRaw)/Wr·100 )
muscleMass  = r1( Wr·(1 − fatR/100) − boneRaw )                     # uses ROUNDED fat
BMR = trunc( clamp( 370 + 0.216·Wr·(100 − fatR) , 900, 2500 ) )    # gender-independent
```

### visceral (stored RAW, not rounded) + subcutaneous
```
MALE:   visc = clamp(0.0082·fatR + 0.8666·BMIin + 0.026·(Wr−LBMr) − 14.2692, 1, 30)
        subc = r1(−0.22·visc  + 0.965·fatR)
FEMALE: visc = clamp(0.0943·fatR + 0.8895·BMIin − 0.0534·(Wr−LBMr) − 16.215, 1, 30)
        subc = r1(−0.303·visc + 0.983·fatR)
```

### protein (uses UNROUNDED water)
```
kf = (g? 1.0 : 1.05)
protein = r1( max( 100 − kf·fatR − 100·boneRaw/Wr − waterC , 5.0 ) )
```

### body score = average of three sub-scores
```
bodyScore = r1( (weightScore + bmiScore + bodyfatScore) / 3 )     # note: uses r1
# bodyAge uses the UNROUNDED average 'raw' (see below)
```
**bmiScore(BMIr):**
```
if BMIr==22: 100
elif BMIr>22: (BMIr<35) ? 100 − 3.84615384615·|22−BMIr| : 50
elif BMIr>15: 100 − 3.84615384615·|22−BMIr|
elif BMIr>=10: 40 ; elif BMIr>=5: 30 ; elif BMIr>=0: 20 ; else 0
```
**bodyfatScore(fatR,g):** std = 16 (male) / 26 (female)
```
if fatR==std: 100
elif fatR>std: (fatR<=45) ? 100 − 50·|std−fatR|/|std−45| : 50
elif fatR<=5:  (fatR>0 ? 10 : 0)
else:          100 − 50·|std−fatR|/|std−5|
```
**weightScore(Wr,H,g):** stdW = (H−80)·0.7 (male) / (1.37·H−110)·0.45 (female)
```
if Wr==stdW: 100
elif Wr>stdW: (1.3·stdW>=Wr) ? 100 − 50·|stdW−Wr|/(0.3·stdW) : 50
else:  # Wr<stdW
  if 0.7·stdW>=Wr:
     if 0.6·stdW>=Wr:
        if 0.5·stdW>=Wr:
           if 0.4·stdW>=Wr:
              if 0.3·stdW>=Wr: (Wr==0 ? 0 : 10)
              else: 20
           else: 30
        else: 40
     else: 50
  else: 100 − 50·|stdW−Wr|/(0.3·stdW)
```

### body age (int) — uses the UNROUNDED body-score 'raw'
```
T = [50,60,65,67.5,70,72.5,75,80,85,87.5,90,92.5,95,96.5,98,99,101]
r=-8; cnt=0
for t in T: if t>raw: break; else r+=1; cnt+=1
bodyAge = (cnt==len(T)) ? age : age − r
bodyAge = max(bodyAge, 18)
```

### body shape (int 1..9) — function of BMIr, fatR, gender; std=16 male/26 female
```
band = (BMIr<18.5) ? thin : (BMIr<25 ? standard : overweight)
thin:        fat<std−5 →3 ; fat<=std+5 →2 ; else →1
standard:    fat<std−5 →5 ; fat<=std+5 →4 ; fat<=std+20 →1 ; else →6
overweight:  fat<std−5 →5 ; fat<std−3 →4 ; fat<=std+5 →8 ; fat<=std+10 →7 ; else →6
```

## reference.csv columns
`gender,heightCm,ageYears,weightKg,r50,r500,` then outputs:
`weight,BMI,fatPct,leanMassKg,subcutFatPct,visceral,waterPct,BMR,skelMusclePct,muscleMassKg,boneMassKg,proteinPct,bodyScore,bodyAge,bodyShape`
Ground-truth row: `1,180.0,48,78.60,467,427, 78.60,24.30,21.10,62.00,18.70,7.3585,57.00,1709,51.00,58.90,3.10,18.00,87.30,47,1`
