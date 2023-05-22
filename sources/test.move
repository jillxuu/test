module contract_test::test {
    use std::vector;

    struct RunFunctionStruct has key {
        sum: u8
    }

    #[view]
    public fun test_view_function(v: vector<u8>): u8 {
        let sum: u8 = 0;
        foreach<u8>(&v, |e| sum = sum + *e);
        sum
    }

    public entry fun test_run_function(owner: &signer, v: vector<u8>) {
        let sum: u8 = 0;
        foreach<u8>(&v, |e| sum = sum + *e);

        let s = RunFunctionStruct {
            sum: sum,
        };

        move_to(owner, s);
    }

    public inline fun foreach<X>(v: &vector<X>, action: |&X|) {
        let i = 0;
        while (i < vector::length(v)) {
            action(vector::borrow(v, i));
            i = i + 1;
        }
    }

    #[test()]
    fun test_view() {
        let v = vector::empty<u8>();
        vector::push_back<u8>(&mut v, 1);
        vector::push_back<u8>(&mut v, 2);
        vector::push_back<u8>(&mut v, 3);
        let result = test_view_function(v);

        assert!(result == 6, 1);
    }

    #[test(owner = @0x123)]
    fun test_run(owner: &signer) acquires RunFunctionStruct {
        let v = vector::empty<u8>();
        vector::push_back<u8>(&mut v, 1);
        vector::push_back<u8>(&mut v, 2);
        vector::push_back<u8>(&mut v, 3);
        test_run_function(owner, v);

        assert!(exists<RunFunctionStruct>(signer::address_of(owner)), 1);

        let struct_sum = &borrow_global<RunFunctionStruct>(signer::address_of(owner)).sum;
        assert!(*struct_sum == 6, 1);
    }

    #[test_only]
    use std::signer;
}