import csv,math
def r1(x): return math.floor(x*10+0.5)/10.0
def r2(x): return math.floor(x*100+0.5)/100.0
def clamp(x,a,b): return max(a,min(b,x))
def fatV2(g,H,age,W,rA,rB):
    if g:
        fA=37.088-0.528*H+0.067*age+0.05*rA+0.668*W;fB=64.22-0.58*H-0.01*age-0.12*rA+0.19*rB+0.51*W
        d=fA-5 if fA-fB>5 else fB; res=min(fA,d) if rB!=0 else fA
    else:
        fA=55.478-0.623*H+0.058*age+0.042*rA+0.831*W;fB=36.23-0.37*H+0.19*age+0.05*rA-0.02*rB+0.53*W
        res=min(fA,fB) if rB!=0 else fA
    return clamp(res,5.1,75.0)
def bmiScore(b):
    if b==22: return 100.0
    if b>22: return 100+abs(22-b)*(-3.8461538461538463) if b<35 else 50.0
    if b>15: return 100+abs(22-b)*(-3.8461538461538463)
    if b>=10: return 40.0
    if b>=5: return 30.0
    if b>=0: return 20.0
    return 0.0
def fatScore(fat,g):
    std=16.0 if g else 26.0
    if fat==std: return 100.0
    if fat>std: return (100+abs(std-fat)*(-50.0/abs(std-45))) if fat<=45 else 50.0
    if fat<=5: return 10.0 if fat>0 else 0.0
    return 100+abs(std-fat)*(-50.0/abs(std-5))
def weightScore(w,H,g):
    std=(H-80)*0.7 if g else (1.37*H-110)*0.45
    if std==w: return 100.0
    if std<w: return (100+abs(std-w)*(-50.0/abs(std-1.3*std))) if 1.3*std>=w else 50.0
    if 0.7*std>=w:
        if 0.6*std>=w:
            if 0.5*std>=w:
                if 0.4*std>=w:
                    if 0.3*std>=w: return 0.0 if w==0 else 10.0
                    return 20.0
                return 30.0
            return 40.0
        return 50.0
    return 100+abs(std-w)*(-50.0/abs(std-0.7*std))
AGE_TBL=[50,60,65,67.5,70,72.5,75,80,85,87.5,90,92.5,95,96.5,98,99,101]
def bodyAge(age,raw):
    r=-8;cnt=0
    for t in AGE_TBL:
        if t>raw: break
        r+=1;cnt+=1
    ba=age if cnt==len(AGE_TBL) else age-r
    return 18 if ba<=18 else ba
def bodyShape(bmi,fat,g):
    std=16.0 if g else 26.0
    bb=0 if bmi<18.5 else (1 if bmi<25 else 2)
    if bb==0:
        if fat<std-5: return 3
        if fat<=std+5: return 2
        return 1
    if bb==1:
        if fat<std-5: return 5
        if fat<=std+5: return 4
        if fat<=std+20: return 1
        return 6
    if fat<std-5: return 5
    if fat<std-3: return 4
    if fat<=std+5: return 8
    if fat<=std+10: return 7
    return 6
rows=list(csv.DictReader(open('reference.csv')))
E={}
for r in rows:
    g=int(r['gender']);H=float(r['heightCm']);age=int(r['ageYears']);W=float(r['weightKg']);rA=int(r['r50']);rB=int(r['r500'])
    fat=fatV2(g,H,age,W,rA,rB);fatR=r1(fat);LBMr=r1(W*(1-fat/100.0));Wr=r1(W);BMI=r1(W/((H/100.0)**2))
    boneRaw=(0.05 if g else 0.06)*LBMr; bone=r2(boneRaw)
    waterC=clamp((0.76 if g else 0.73)*(LBMr-boneRaw)/Wr*100,10,80); water=r1(waterC)
    sm=r1((0.68 if g else 0.62)*(LBMr-boneRaw)/Wr*100)
    musM=r1(Wr*(1-fatR/100.0)-boneRaw)
    bmr=int(clamp(370+0.216*Wr*(100-fatR),900,2500))
    if g: visc=clamp(0.0082*fatR+0.8666*(Wr/((H/100.0)**2))+0.026*(Wr-LBMr)-14.2692,1,30); subc=r1(-0.22*visc+0.965*fatR)
    else: visc=clamp(0.0943*fatR+0.8895*(Wr/((H/100.0)**2))-0.0534*(Wr-LBMr)-16.215,1,30); subc=r1(-0.303*visc+0.983*fatR)
    kf=1.0 if g else 1.05
    prot=r1(max(100-kf*fatR-100*boneRaw/Wr-waterC,5.0))
    raw=(weightScore(Wr,H,g)+fatScore(fatR,g)+bmiScore(BMI))/3.0
    score=r1(raw); bage=bodyAge(age,raw); shape=bodyShape(BMI,fatR,g)
    m={'BMI':BMI,'fatPct':fatR,'leanMassKg':LBMr,'subcutFatPct':subc,'visceral':visc,'waterPct':water,
       'BMR':bmr,'skelMusclePct':sm,'muscleMassKg':musM,'boneMassKg':bone,'proteinPct':prot,
       'bodyScore':score,'bodyAge':bage,'bodyShape':shape}
    for k in m:
        ref=float(r[k]); e=abs(m[k]-ref)
        E.setdefault(k,[]).append((e,m[k],ref,r['gender'],H,age,W,rA,rB))
for k in E:
    a=sorted(E[k],reverse=True)
    print(f"{k:14s} EXACT" if a[0][0]<1e-9 else f"{k:14s} maxerr={a[0][0]:.4f} n_bad={sum(1 for x in E[k] if x[0]>1e-9)} worst={a[0][1:3]} @ {a[0][3:]}")
