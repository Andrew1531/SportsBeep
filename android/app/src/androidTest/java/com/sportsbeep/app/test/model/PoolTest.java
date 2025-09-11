package com.sportsbeep.app.test.model;

import com.sportsbeep.app.model.pool.Pool;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

public class PoolTest extends TestCase {

    private static final String JSON = "{\n"
            + "      \"id\" : 1,\n"
            + "      \"prize_pool\" : 20,\n"
            + "      \"entry_fee\" : 2.2\n"
            + "    }";

    public static Pool getTestPool() {
        Pool pool = new Pool();
        pool.setId(1);
        pool.setPrizePool(20);
        pool.setEntryFee(2.2);

        return pool;
    }

    public void testParse() {
        assertEquals(getTestPool(),
                NetworkModule.createGsonForConverter().fromJson(JSON, Pool.class));
    }
}
