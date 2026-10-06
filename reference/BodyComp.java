package local.myscale;

/**
 * On-device body-composition calculator — a pure-Java port of the original
 * Qingniu native routine {@code algorithm()} from libyolanda_calc.so.
 *
 * The formulas, constants and rounding order were recovered by disassembling
 * the native library and verified bit-for-bit against the library's own output
 * (run under emulation) across a 40-row reference set + a 7360-point grid: all
 * 14 computed fields reproduce exactly, so these numbers match what the
 * discontinued MyKronoz / Yolanda cloud produced.
 *
 * Being pure Java, it is ABI-independent and runs on any device (including
 * 64-bit-only phones where the 32-bit native lib cannot load). The scale no
 * longer needs to recognise the user: we read raw weight + bioimpedance over
 * BLE and compute everything locally from the active app profile.
 *
 * gender: 1 = male, 0 = female (native convention — the OPPOSITE of the BLE
 * wire convention used elsewhere in the app).
 *
 * CRITICAL ordering (verified): fat is computed raw, then STORED rounded; most
 * downstream fields re-read the rounded values (fatR, Wr, LBMr). The two
 * exceptions — water and protein — use the UNROUNDED clamped water value.
 */
public final class BodyComp {

    private BodyComp() {}

    public static boolean isAvailable() { return true; }

    /** round to 1 decimal, half-up (matches the lib's floor(x*10+0.5)/10). */
    private static double r1(double x) { return Math.floor(x * 10 + 0.5) / 10.0; }
    /** round to 2 decimals, half-up. */
    private static double r2(double x) { return Math.floor(x * 100 + 0.5) / 100.0; }
    private static double clamp(double x, double a, double b) { return Math.max(a, Math.min(b, x)); }

    /** Body fat % — dual-frequency, per gender; clamped to [5.1, 75]. */
    private static double fat(int g, double H, int age, double W, int rA, int rB) {
        double res;
        if (g != 0) {
            double fA = 37.088 - 0.528 * H + 0.067 * age + 0.05 * rA + 0.668 * W;
            double fB = 64.22 - 0.58 * H - 0.01 * age - 0.12 * rA + 0.19 * rB + 0.51 * W;
            double d = (fA - fB > 5) ? fA - 5 : fB;
            res = (rB != 0) ? Math.min(fA, d) : fA;
        } else {
            double fA = 55.478 - 0.623 * H + 0.058 * age + 0.042 * rA + 0.831 * W;
            double fB = 36.23 - 0.37 * H + 0.19 * age + 0.05 * rA - 0.02 * rB + 0.53 * W;
            res = (rB != 0) ? Math.min(fA, fB) : fA;
        }
        return clamp(res, 5.1, 75.0);
    }

    private static double bmiScore(double b) {
        if (b == 22) return 100.0;
        if (b > 22) return (b < 35) ? 100 + Math.abs(22 - b) * (-3.8461538461538463) : 50.0;
        if (b > 15) return 100 + Math.abs(22 - b) * (-3.8461538461538463);
        if (b >= 10) return 40.0;
        if (b >= 5) return 30.0;
        if (b >= 0) return 20.0;
        return 0.0;
    }

    private static double fatScore(double fat, int g) {
        double std = (g != 0) ? 16.0 : 26.0;
        if (fat == std) return 100.0;
        if (fat > std) return (fat <= 45) ? 100 + Math.abs(std - fat) * (-50.0 / Math.abs(std - 45)) : 50.0;
        if (fat <= 5) return (fat > 0) ? 10.0 : 0.0;
        return 100 + Math.abs(std - fat) * (-50.0 / Math.abs(std - 5));
    }

    private static double weightScore(double w, double H, int g) {
        double std = (g != 0) ? (H - 80) * 0.7 : (1.37 * H - 110) * 0.45;
        if (std == w) return 100.0;
        if (std < w) return (1.3 * std >= w) ? 100 + Math.abs(std - w) * (-50.0 / Math.abs(std - 1.3 * std)) : 50.0;
        if (0.7 * std >= w) {
            if (0.6 * std >= w) {
                if (0.5 * std >= w) {
                    if (0.4 * std >= w) {
                        if (0.3 * std >= w) return (w == 0) ? 0.0 : 10.0;
                        return 20.0;
                    }
                    return 30.0;
                }
                return 40.0;
            }
            return 50.0;
        }
        return 100 + Math.abs(std - w) * (-50.0 / Math.abs(std - 0.7 * std));
    }

    private static final double[] AGE_TBL =
        {50, 60, 65, 67.5, 70, 72.5, 75, 80, 85, 87.5, 90, 92.5, 95, 96.5, 98, 99, 101};

    private static int bodyAge(int age, double raw) {
        int r = -8, cnt = 0;
        for (double t : AGE_TBL) {
            if (t > raw) break;
            r++; cnt++;
        }
        int ba = (cnt == AGE_TBL.length) ? age : age - r;
        return (ba <= 18) ? 18 : ba;
    }

    private static int bodyShape(double bmi, double fat, int g) {
        double std = (g != 0) ? 16.0 : 26.0;
        int bb = (bmi < 18.5) ? 0 : (bmi < 25 ? 1 : 2);
        if (bb == 0) {
            if (fat < std - 5) return 3;
            if (fat <= std + 5) return 2;
            return 1;
        }
        if (bb == 1) {
            if (fat < std - 5) return 5;
            if (fat <= std + 5) return 4;
            if (fat <= std + 20) return 1;
            return 6;
        }
        if (fat < std - 5) return 5;
        if (fat < std - 3) return 4;
        if (fat <= std + 5) return 8;
        if (fat <= std + 10) return 7;
        return 6;
    }

    /** Parsed body-composition result. */
    public static final class Result {
        public double weightKg, bmi, fatPercent, leanMassKg, subcutaneousFatPercent,
                visceralFat, waterPercent, skeletalMusclePercent, muscleMassKg,
                boneMassKg, proteinPercent, score;
        public int bmrKcal, bodyAge, shape;
    }

    /**
     * Compute full body composition. Returns null on clearly invalid input so
     * callers can fall back to whatever the scale itself reported.
     *
     * @param genderMale1Female0 1 = male, 0 = female (native convention)
     */
    public static Result calc(double heightCm, int ageYears, int genderMale1Female0,
                              double weightKg, int r50, int r500) {
        if (heightCm <= 0 || weightKg <= 0 || r50 <= 0) return null;

        // Input clamps applied by the native lib before anything else.
        int g = (genderMale1Female0 != 0) ? 1 : 0;
        double H = clamp(heightCm, 40, 240);
        int age = (int) clamp(ageYears, 3, 80);
        double W = clamp(weightKg, 40, 240);
        int rA = Math.min(r50, 1500);
        int rB = Math.min(Math.max(r500, 0), 1500);

        double fat = fat(g, H, age, W, rA, rB);
        double fatR = r1(fat);
        double LBMr = r1(W * (1 - fat / 100.0));          // lean uses RAW fat
        double Wr = r1(W);
        double BMIr = r1(W / Math.pow(H / 100.0, 2));
        double BMIin = Wr / Math.pow(H / 100.0, 2);        // inline BMI for visceral

        double boneRaw = (g != 0 ? 0.05 : 0.06) * LBMr;
        double bone = r2(boneRaw);
        double kW = (g != 0) ? 0.76 : 0.73;
        double waterC = clamp(kW * (LBMr - boneRaw) / Wr * 100, 10, 80);  // unrounded, reused
        double water = r1(waterC);
        double sm = r1((g != 0 ? 0.68 : 0.62) * (LBMr - boneRaw) / Wr * 100);
        double musM = r1(Wr * (1 - fatR / 100.0) - boneRaw);
        int bmr = (int) clamp(370 + 0.216 * Wr * (100 - fatR), 900, 2500);

        double visc, subc;
        if (g != 0) {
            visc = clamp(0.0082 * fatR + 0.8666 * BMIin + 0.026 * (Wr - LBMr) - 14.2692, 1, 30);
            subc = r1(-0.22 * visc + 0.965 * fatR);
        } else {
            visc = clamp(0.0943 * fatR + 0.8895 * BMIin - 0.0534 * (Wr - LBMr) - 16.215, 1, 30);
            subc = r1(-0.303 * visc + 0.983 * fatR);
        }
        double kf = (g != 0) ? 1.0 : 1.05;
        double prot = r1(Math.max(100 - kf * fatR - 100 * boneRaw / Wr - waterC, 5.0));

        double raw = (weightScore(Wr, H, g) + fatScore(fatR, g) + bmiScore(BMIr)) / 3.0;

        Result out = new Result();
        out.weightKg = Wr;
        out.bmi = BMIr;
        out.fatPercent = fatR;
        out.leanMassKg = LBMr;
        out.subcutaneousFatPercent = subc;
        out.visceralFat = visc;
        out.waterPercent = water;
        out.skeletalMusclePercent = sm;
        out.muscleMassKg = musM;
        out.boneMassKg = bone;
        out.proteinPercent = prot;
        out.bmrKcal = bmr;
        out.score = r1(raw);
        out.bodyAge = bodyAge(age, raw);
        out.shape = bodyShape(BMIr, fatR, g);
        return out;
    }
}
