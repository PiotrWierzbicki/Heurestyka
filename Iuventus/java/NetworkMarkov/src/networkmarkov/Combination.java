/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package networkmarkov;

import java.util.Arrays;

/**
 *http://stackoverflow.com/questions/5076695/how-can-i-iterate-throught-every-possible-combination-of-n-playing-cards
 * @author Krzysiek
 */
public class Combination {
    int[] item;
    int n;
    int k;

    Combination(int n, int k) 
    {
        item=new int[k];
        this.n=n;
        this.k=k;
    }
    void first_combination()
    {
        for (int i = 0; i < item.length; ++i) {
            item[i] = i;
        }
    }
    boolean next_combination()
    {
        for (int i = 1; i <= k; ++i) {
            if (item[k-i] < n-i) {
                ++item[k-i];
                for (int j = k-i+1; j < k; ++j) {
                    item[j] = item[j-1] + 1;
                }
                return true;
            }
        }
        return false;
    }    
    public void print()
    {
        System.out.println(Arrays.toString(item));
    }
    public int[] getState()
    {
        return item.clone();
    }
}
