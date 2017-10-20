/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package networkmarkov;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

class SparseMatrix
{
    public int[] iidx;
    public int[] jidx;
    public double[] values;
}
/**
 *
 * @author Krzysiek
 */
public class NetworkMarkov {
    
    Combination[] combinations;
    List<int[]>states;
    int ncomp;


    public NetworkMarkov(int n, int k) {
        combinations= new Combination[k+1];
        ncomp=n;
        for(int i=0; i < k+1;i++)
        {
            combinations[i]=new Combination(n, i);
        }
        states= new LinkedList<>();
        generateStates();
    }
    private void generateStates()
    {
        for(int i=0; i < combinations.length; i++)
        {
            Combination c = combinations[i];
           
            c.first_combination();
            //c.print();
            states.add(c.getState());
            
            if(i>0)
            {          
                while(c.next_combination())
                {
                    //c.print();
                    states.add(c.getState());
                }
            }
        }
        

    }
    public void print()
    {
        Iterator<int[]> it = states.iterator();
        while(it.hasNext())
        {
            System.out.println( Arrays.toString(it.next()));
        }
        
    }
    //odejmowanie zbiorow a/b jest w a i ie ma w b
    public int[] setDiff(int[] a, int[] b)
    {
        int[] ret = new int[a.length];
        int cut=0;
        
        for(int i=0; i<a.length; i++)
        {
            boolean found=false;
            for(int j=0; j< b.length; j++)
            {
                if(b[j]==a[i])
                    found=true;
            }
            if(!found)
            {
                ret[cut]=a[i];
                cut++;
            }
        }
        return Arrays.copyOf(ret, cut);
    }
    public SparseMatrix makeQ(double[] lambdas, double[] mus)
    {
        Iterator<int[]> first = states.iterator();
        Iterator<int[]> second = states.iterator();
        int i=0;
        int j=0;
        LinkedList<Integer> iidx= new LinkedList<>();
        LinkedList<Integer> jidx= new LinkedList<>();
        LinkedList<Double> vallist= new LinkedList<>();
        
        
        while(first.hasNext())
        {
            int[] st=first.next();
            second = states.iterator();
            while(second.hasNext())
            {
                int[] next=second.next();
                if(next.length ==  st.length+1)
                {
                    //Nowa awaria
                    int [] d=setDiff( next,st);
                    if(d.length==1)
                    {
                        vallist.add(lambdas[d[0]]);
                        iidx.add(i);
                        jidx.add(j);
                    }
                    
                    
                }
                else if (next.length ==  st.length-1)
                {
                    //naprawa
                    int [] d=setDiff( st, next);
                    if(d.length==1)
                    {
                        vallist.add(mus[d[0]]);
                        iidx.add(i);
                        jidx.add(j);
                    }
                }
                j++;
            }
            i++;
            j=0;
        }
        SparseMatrix ret = new SparseMatrix();
        
        ret.iidx = new int[iidx.size()];
        int index=0;
        Iterator<Integer> it=iidx.iterator();
        while(it.hasNext())
        {
            ret.iidx[index]=it.next().intValue();
            index++;
        }
        ret.jidx = new int[jidx.size()];
        index=0;
        it=jidx.iterator();
        while(it.hasNext())
        {
            ret.jidx[index]=it.next().intValue();
            index++;
        }
        
        ret.values = new double[iidx.size()];
        index=0;
        Iterator<Double>it2=vallist.iterator();
        while(it2.hasNext())
        {
            ret.values[index]=it2.next().doubleValue();
            index++;
        }
      return ret;
    }
    
    public int[] getWorkingStatesInProtection(int[] primaryPath, int[] backupPath)
    {
        ArrayList<Integer> tmpot = new ArrayList<>();
        Iterator<int[]> it = states.iterator();
        Arrays.sort(primaryPath);
        Arrays.sort(backupPath);
        int index=0;
        while(it.hasNext())
        {
            int[] tmp = it.next();
            boolean primaryFailed=false;
            boolean backupFailed=false;
            
            for(int i=0; i < tmp.length; i++)
            {
                primaryFailed = primaryFailed || Arrays.binarySearch(primaryPath, tmp[i]) >= 0;
                backupFailed = backupFailed || Arrays.binarySearch(backupPath, tmp[i]) >= 0;
            }
            if(!(primaryFailed && backupFailed))
                tmpot.add(index);
            
            index++;
        }
        
        int [] ret = new int[tmpot.size()];
        for(int i=0; i < ret.length; i++)
        {
            ret[i]=tmpot.get(i).intValue();
        }
        return ret;
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        //System.out.println("Test");
        int n=4;

        NetworkMarkov system= new NetworkMarkov(n, 3);
        double[] lambdas = new double[n];
        double [] mus= new double [n];
        for(int i=0; i<n; i++)
        {
            lambdas[i]=i+1;
            mus[i]=100*(i+1);
        }
                
        //SparseMatrix sp = system.makeQ(lambdas,mus);
        
        System.out.println( Arrays.toString(system.setDiff(new int[]{1}, new int[]{3})));
        system.print();
        System.out.println( Arrays.toString(system.getWorkingStatesInProtection(new int[]{0,1}, new int[]{2,3})));

        return;
    }
   
}
