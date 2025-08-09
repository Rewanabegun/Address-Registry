module rezwana_address::AddressRegistry {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::table::{Self, Table};

    const E_NAME_ALREADY_EXISTS: u64 = 1;
    const E_NAME_NOT_FOUND: u64 = 2;
    const E_REGISTRY_NOT_INITIALIZED: u64 = 3;

    struct Registry has key {
        name_to_address: Table<String, address>,
        address_to_name: Table<address, String>,
    }

    public fun initialize_registry(account: &signer) {
        let registry = Registry {
            name_to_address: table::new(),
            address_to_name: table::new(),
        };
        move_to(account, registry);
    }

    public fun register_name(
        registry_owner: &signer, 
        name: String, 
        target_address: address
    ) acquires Registry {
        let registry_address = signer::address_of(registry_owner);
        
        assert!(exists<Registry>(registry_address), E_REGISTRY_NOT_INITIALIZED);
        
        let registry = borrow_global_mut<Registry>(registry_address);
        
        assert!(!table::contains(&registry.name_to_address, name), E_NAME_ALREADY_EXISTS);
        
        table::add(&mut registry.name_to_address, name, target_address);
        table::add(&mut registry.address_to_name, target_address, name);
    }

    public fun lookup_address(registry_address: address, name: String): address acquires Registry {
        assert!(exists<Registry>(registry_address), E_REGISTRY_NOT_INITIALIZED);
        
        let registry = borrow_global<Registry>(registry_address);
        
        assert!(table::contains(&registry.name_to_address, name), E_NAME_NOT_FOUND);
        
        *table::borrow(&registry.name_to_address, name)
    }

}
