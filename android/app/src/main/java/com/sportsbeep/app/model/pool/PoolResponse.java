package com.sportsbeep.app.model.pool;

import java.util.List;

public class PoolResponse {

    private List<Pool> pools;

    private String balance;

    public List<Pool> getPools() {
        return pools;
    }

    public void setPools(List<Pool> pools) {
        this.pools = pools;
    }

    public String getBalance() {
        return balance;
    }

    public void setBalance(String balance) {
        this.balance = balance;
    }
}
