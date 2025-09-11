package com.sportsbeep.app.model.pool;

public class Pool {

    private long id;

    private double prizePool;

    private double entryFee;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public double getPrizePool() {
        return prizePool;
    }

    public void setPrizePool(double prizePool) {
        this.prizePool = prizePool;
    }

    public double getEntryFee() {
        return entryFee;
    }

    public void setEntryFee(double entryFee) {
        this.entryFee = entryFee;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof Pool)) {
            return false;
        }

        Pool pool = (Pool) o;

        if (Double.compare(pool.entryFee, entryFee) != 0) {
            return false;
        }
        if (id != pool.id) {
            return false;
        }
        if (Double.compare(pool.prizePool, prizePool) != 0) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result;
        long temp;
        result = (int) (id ^ (id >>> 32));
        temp = Double.doubleToLongBits(prizePool);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(entryFee);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        return result;
    }
}
