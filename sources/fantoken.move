address admin {

module fantoken {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct FAN{}

    struct CoinCapabilities<phantom FAN> has key {
        mint_capability: coin::MintCapability<FAN>,
        burn_capability: coin::BurnCapability<FAN>,
        freeze_capability: coin::FreezeCapability<FAN>,
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_fan(account: &signer) {
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<FAN>(
            account,
            string::utf8(b"Fan Token"),
            string::utf8(b"FAN"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
        assert!(!exists<CoinCapabilities<FAN>>(@admin), E_HAS_CAPABILITIES);

        move_to<CoinCapabilities<FAN>>(account, CoinCapabilities<FAN>{mint_capability, burn_capability, freeze_capability});
    }

    public fun mint(account: &signer, amount: u64): coin::Coin<FAN> acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, E_NO_ADMIN);
        assert!(exists<CoinCapabilities<FAN>>(account_address), E_NO_CAPABILITIES);
        let mint_capability = &borrow_global<CoinCapabilities<FAN>>(account_address).mint_capability;
        coin::mint<FAN>(amount, mint_capability)
    }

    public fun burn(coins: coin::Coin<FAN>) acquires CoinCapabilities {
        let burn_capability = &borrow_global<CoinCapabilities<FAN>>(@admin).burn_capability;
        coin::burn<FAN>(coins, burn_capability);
    }
}
}
