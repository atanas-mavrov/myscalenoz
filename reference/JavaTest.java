import local.myscale.BodyComp;
import java.io.*; import java.util.*;
public class Test {
  public static void main(String[] a) throws Exception {
    BufferedReader br=new BufferedReader(new FileReader("reference.csv"));
    String header=br.readLine(); String[] cols=header.split(",");
    Map<String,Integer> ci=new HashMap<>(); for(int i=0;i<cols.length;i++) ci.put(cols[i],i);
    String[] fields={"BMI","fatPct","leanMassKg","subcutFatPct","visceral","waterPct","BMR","skelMusclePct","muscleMassKg","boneMassKg","proteinPct","bodyScore","bodyAge","bodyShape"};
    Map<String,Double> maxerr=new LinkedHashMap<>(); Map<String,Integer> nbad=new LinkedHashMap<>();
    for(String f:fields){maxerr.put(f,0.0);nbad.put(f,0);}
    String line; int n=0; String worst="";
    while((line=br.readLine())!=null){ if(line.trim().isEmpty())continue; n++;
      String[] v=line.split(",");
      int g=Integer.parseInt(v[ci.get("gender")]);
      double H=Double.parseDouble(v[ci.get("heightCm")]);
      int age=Integer.parseInt(v[ci.get("ageYears")]);
      double W=Double.parseDouble(v[ci.get("weightKg")]);
      int r50=Integer.parseInt(v[ci.get("r50")]);
      int r500=Integer.parseInt(v[ci.get("r500")]);
      BodyComp.Result r=BodyComp.calc(H,age,g,W,r50,r500);
      Map<String,Double> got=new HashMap<>();
      got.put("BMI",r.bmi); got.put("fatPct",r.fatPercent); got.put("leanMassKg",r.leanMassKg);
      got.put("subcutFatPct",r.subcutaneousFatPercent); got.put("visceral",r.visceralFat);
      got.put("waterPct",r.waterPercent); got.put("BMR",(double)r.bmrKcal);
      got.put("skelMusclePct",r.skeletalMusclePercent); got.put("muscleMassKg",r.muscleMassKg);
      got.put("boneMassKg",r.boneMassKg); got.put("proteinPct",r.proteinPercent);
      got.put("bodyScore",r.score); got.put("bodyAge",(double)r.bodyAge); got.put("bodyShape",(double)r.shape);
      for(String f:fields){ double ref=Double.parseDouble(v[ci.get(f)]); double e=Math.abs(got.get(f)-ref);
        double tol = f.equals("visceral")?1e-3:1e-9;
        if(e>tol){ nbad.put(f,nbad.get(f)+1); if(e>maxerr.get(f)){maxerr.put(f,e);} }
      }
    }
    System.out.println("rows="+n);
    boolean allgood=true;
    for(String f:fields){ if(nbad.get(f)==0) System.out.printf("%-14s EXACT%n",f);
      else { allgood=false; System.out.printf("%-14s maxerr=%.4f n_bad=%d%n",f,maxerr.get(f),nbad.get(f)); } }
    System.out.println(allgood?"ALL FIELDS MATCH ✓":"MISMATCHES ✗");
  }
}
