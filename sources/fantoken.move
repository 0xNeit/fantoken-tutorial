address admin {

module fanv4token {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct FANV4{}

    struct CoinCapabilities<phantom FANV4> has key {
        mint_capability: coin::MintCapability<FANV4>,
        burn_capability: coin::BurnCapability<FANV4>,
        freeze_capability: coin::FreezeCapability<FANV4>,
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_fanv4(account: &signer) {
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<FANV4>(
            account,
            string::utf8(b"Fan V4 Token"),
            string::utf8(b"FANV4"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
        assert!(!exists<CoinCapabilities<FANV4>>(@admin), E_HAS_CAPABILITIES);

        move_to<CoinCapabilities<FANV4>>(account, CoinCapabilities<FANV4>{mint_capability, burn_capability, freeze_capability});
    }

    public entry fun mint<FANV4>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, E_NO_ADMIN);
        assert!(exists<CoinCapabilities<FANV4>>(account_address), E_NO_CAPABILITIES);
        let mint_capability = &borrow_global<CoinCapabilities<FANV4>>(account_address).mint_capability;
        let coins = coin::mint<FANV4>(amount, mint_capability);
        coin::deposit(user, coins)
    }

    public entry fun burn<FANV4>(coins: coin::Coin<FANV4>) acquires CoinCapabilities {
        let burn_capability = &borrow_global<CoinCapabilities<FANV4>>(@admin).burn_capability;
        coin::burn<FANV4>(coins, burn_capability);
    }
}
}
